import Foundation

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
    case .unkeyedId:
      return Unkeyed(state: self, ref: ref)
    case .keyedId, .value:
      return Unkeyed(state: self, ref: Ref(nodeId: ref.nodeId, failId: 0))
    }
  }

  func nestedRef(ref: Ref, key: (any CodingKey)?) -> Ref {
    if ref.failId >= 0 {
      let pin: Enigma.Pin = if let key { .str(key.stringValue) } else { .int(0) }
      defer { fails.append(Link(prev: ref.failId, pin: pin)) }
      return Ref(nodeId: ref.nodeId, failId: fails.count)
    } else if let key {
      let key = key.stringValue
      guard case .keyedId(let keyedId) = nodes[ref.nodeId].storage else {
        defer { fails.append(Link(prev: 0, pin: .str(key))) }
        return Ref(nodeId: ref.nodeId, failId: fails.count)
      }
      if let nodeId = keyed[keyedId][key] {
        return Ref(nodeId: nodeId, failId: -1)
      } else {
        defer { nodes.append(Node(link: Link(prev: ref.nodeId, pin: .str(key)))) }
        keyed[keyedId][key] = nodes.count
        return Ref(nodeId: nodes.count, failId: -1)
      }
    } else {
      guard case .unkeyedId(let unkeyedId) = nodes[ref.nodeId].storage else {
        defer { fails.append(Link(prev: 0, pin: .int(0))) }
        return Ref(nodeId: ref.nodeId, failId: fails.count)
      }
      let nodeId = nodes.count
      nodes.append(Node(link: Link(prev: ref.nodeId, pin: .int(unkeyed[unkeyedId].count))))
      unkeyed[unkeyedId].append(nodeId)
      return Ref(nodeId: nodeId, failId:  -1)
    }
  }

  func store(_ value: Enigma, ref: Ref) throws {
    if ref.failId >= 0 {
      let failPath = codingPath(failId: ref.failId, key: nil)
      let nodePath = codingPath(nodeId: ref.nodeId, key: nil)
      let encoded = materialize(nodeId: ref.nodeId).asSwiftAny
      throw EncodingError.invalidValue(value.asSwiftAny, EncodingError.Context(
        codingPath: nodePath + failPath,
        debugDescription: "attempt to overwrite \(encoded) at \(nodePath)"
      ))
    } else if case .unset = nodes[ref.nodeId].storage {
      nodes[ref.nodeId].storage = .value(value)
    } else {
      throw EncodingError.invalidValue(value.asSwiftAny, EncodingError.Context(
        codingPath: codingPath(nodeId: ref.nodeId, key: nil),
        debugDescription: "attempt to overwrite \(materialize(nodeId: ref.nodeId).asSwiftAny)"
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
      path.append(current.pin)
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
      path.append(current.pin)
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

  static func encode(value: any Encodable, userInfo: [CodingUserInfoKey: Any]) throws -> Enigma {
    let state = EnigmaEncoder(userInfo: userInfo)
    let ref = Ref(nodeId: 0, failId: -1)
    if try !state.encodeSpecial(value, ref: ref) {
      try value.encode(to: Single(state: state, ref: ref))
    }
    if case .unset = state.nodes[0].storage {
      throw EncodingError.invalidValue(nil as Enigma?, EncodingError.Context(
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
    let pin: Enigma.Pin
  }

  struct Ref {
    var nodeId: Int
    var failId: Int
  }
}
