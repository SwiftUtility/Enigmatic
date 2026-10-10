import Foundation

@usableFromInline
final class EnigmaEncoder {
  let userInfo: [CodingUserInfoKey: Any]
  private var nodes: [Node] = [Node(link: nil)]
  private var fails: [Link?] = [nil]
  private var keyed: [[String: Int]] = []
  private var unkeyed: [[Int]] = []

  private init(userInfo: [CodingUserInfoKey: Any]) {
    self.userInfo = userInfo
  }

  func codingPath(ref: Ref, key: (any CodingKey)? = nil) -> [any CodingKey] {
    guard ref.failId >= 0 else { return codingPath(nodeId: ref.nodeId, key: key) }
    return codingPath(nodeId: ref.nodeId, key: nil) + codingPath(failId: ref.failId, key: key)
  }

  func count(ref: Ref) -> Int {
    guard ref.failId < 0, case .unkeyedId(let unkeyedId) = nodes[ref.nodeId].storage else { return 0 }
    return unkeyed[unkeyedId].count
  }

  func asKeyed<Key: CodingKey>(ref: Ref) -> Keyed<Key> {
    guard ref.failId < 0 else { return Keyed<Key>(state: self, ref: ref) }
    switch nodes[ref.nodeId].storage {
    case .keyedId:
      return Keyed<Key>(state: self, ref: ref)
    case .unset:
      defer { keyed.append([:]) }
      nodes[ref.nodeId].storage = .keyedId(keyed.count)
      return Keyed<Key>(state: self, ref: ref)
    case .value, .unkeyedId:
      return Keyed<Key>(state: self, ref: Ref(nodeId: ref.nodeId, failId: 0))
    }
  }

  func asUnkeyed(ref: Ref) -> Unkeyed {
    guard ref.failId < 0 else { return Unkeyed(state: self, ref: ref) }
    switch nodes[ref.nodeId].storage {
    case .unset:
      defer { unkeyed.append([]) }
      nodes[ref.nodeId].storage = .unkeyedId(unkeyed.count)
      return Unkeyed(state: self, ref: ref)
    case .unkeyedId, .keyedId, .value:
      return Unkeyed(state: self, ref: Ref(nodeId: ref.nodeId, failId: 0))
    }
  }

  func nestedRef(ref: Ref, key: (any CodingKey)?) -> Ref {
    if ref.failId >= 0 {
      defer { fails.append(Link(prev: ref.failId, key: key ?? Enigma.Pin.int(0))) }
      return Ref(nodeId: ref.nodeId, failId: fails.count)
    } else if let key {
      guard case .keyedId(let keyedId) = nodes[ref.nodeId].storage else {
        defer { fails.append(Link(prev: 0, key: key)) }
        return Ref(nodeId: ref.nodeId, failId: fails.count)
      }
      let string = key.stringValue
      guard keyed[keyedId][string] == nil else {
        defer { fails.append(Link(prev: 0, key: key)) }
        return Ref(nodeId: ref.nodeId, failId: fails.count)
      }
      defer { nodes.append(Node(link: Link(prev: ref.nodeId, key: key))) }
      keyed[keyedId][string] = nodes.count
      return Ref(nodeId: nodes.count, failId: -1)
    } else {
      guard case .unkeyedId(let unkeyedId) = nodes[ref.nodeId].storage else {
        defer { fails.append(Link(prev: 0, key: Enigma.Pin.int(0))) }
        return Ref(nodeId: ref.nodeId, failId: fails.count)
      }
      let nodeId = nodes.count
      nodes.append(Node(link: Link(prev: ref.nodeId, key: Enigma.Pin.int(unkeyed[unkeyedId].count))))
      unkeyed[unkeyedId].append(nodeId)
      return Ref(nodeId: nodeId, failId:  -1)
    }
  }

  func store(_ value: Enigma, ref: Ref) throws {
    if ref.failId >= 0 {
      let failPath = codingPath(failId: ref.failId, key: nil)
      let nodePath = codingPath(nodeId: ref.nodeId, key: nil)
      let encoded = materialize(nodeId: ref.nodeId).asAny
      throw EncodingError.invalidValue(value.asAny, EncodingError.Context(
        codingPath: nodePath + failPath,
        debugDescription: "attempt to overwrite \(encoded) at \(nodePath)"
      ))
    } else if case .unset = nodes[ref.nodeId].storage {
      nodes[ref.nodeId].storage = .value(value)
    } else {
      throw EncodingError.invalidValue(value.asAny, EncodingError.Context(
        codingPath: codingPath(nodeId: ref.nodeId, key: nil),
        debugDescription: "attempt to overwrite \(materialize(nodeId: ref.nodeId).asAny)"
      ))
    }
  }

  func encodeSpecial<T: Encodable>(_ value: T, ref: Ref) throws -> Bool {
    if let value = value as? Data {
      try store(.data(value), ref: ref)
    } else if let value = value as? Date {
      try store(.date(value), ref: ref)
    } else {
      return false
    }
    return true
  }

  private func codingPath(nodeId: Int, key: (any CodingKey)?) -> [any CodingKey] {
    var path: [any CodingKey] = []
    if let key { path.append(key) }
    var link = nodes[nodeId].link
    while let current = link {
      path.append(current.key)
      link = nodes[current.prev].link
    }
    path.reverse()
    return path
  }

  private func codingPath(failId: Int, key: (any CodingKey)?) -> [any CodingKey] {
    var path: [any CodingKey] = []
    if let key { path.append(key) }
    var link = fails[failId]
    while let current = link {
      path.append(current.key)
      link = fails[current.prev]
    }
    path.reverse()
    return path
  }

  private func materialize(nodeId: Int) -> Enigma {
    switch nodes[nodeId].storage {
    case .unset: .dictionary([:])
    case .value(let value): value
    case .keyedId(let keyedId): .dictionary(keyed[keyedId].mapValues(materialize(nodeId:)))
    case .unkeyedId(let unkeyedId): .array(unkeyed[unkeyedId].map(materialize(nodeId:)))
    }
  }

  @usableFromInline
  static func encode(value: some Encodable, userInfo: [CodingUserInfoKey: Any]) throws -> Enigma {
    let state = EnigmaEncoder(userInfo: userInfo)
    let ref = Ref(nodeId: 0, failId: -1)
    if try !state.encodeSpecial(value, ref: ref) {
      try value.encode(to: Single(state: state, ref: ref))
    }
    if case .unset = state.nodes[0].storage {
      throw EncodingError.invalidValue(value, EncodingError.Context(
        codingPath: [],
        debugDescription: "top level encoded to nothing"
      ))
    } else {
      return state.materialize(nodeId: 0)
    }
  }

  enum Storage {
    case unset
    case value(Enigma)
    case keyedId(Int)
    case unkeyedId(Int)
  }

  struct Node {
    var storage: Storage = .unset
    let link: Link?
  }

  struct Link {
    let prev: Int
    let key: any CodingKey
  }

  struct Ref {
    var nodeId: Int
    var failId: Int
  }
}
