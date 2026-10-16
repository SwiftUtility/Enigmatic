import Foundation

@usableFromInline
final class EnigmaEncoder {
  let userInfo: [CodingUserInfoKey: Any]
  private var nodes: [Node] = [Node()]
  private var links: [Link] = []
  private var keyed: [[String: Int]] = []
  private var unkeyed: [[Int]] = []
  private var inconsistency: EncodingError?

  private init(userInfo: [CodingUserInfoKey: Any]) {
    self.userInfo = userInfo
  }

  func codingPath(ref: Ref, key: (any CodingKey)? = nil) -> [any CodingKey] {
    if ref.nodeId < 0 {
      codingPath(linkId: -(ref.nodeId + 1), key: key)
    } else {
      codingPath(linkId: nodes[ref.nodeId].linkId, key: key)
    }
  }

  func count(ref: Ref) -> Int {
    guard ref.containerId >= 0 else { return 0 }
    return unkeyed[ref.containerId].count
  }

  func asKeyed<Key: CodingKey>(ref: Ref) -> Keyed<Key> {
    guard inconsistency == nil else { return Keyed<Key>(state: self, ref: ref) }
    switch nodes[ref.nodeId].storage {
    case .unset:
      defer { keyed.append([:]) }
      nodes[ref.nodeId].storage = .keyed(keyed.count)
      return Keyed<Key>(state: self, ref: Ref(nodeId: ref.nodeId, containerId: keyed.count))
    case .single:
      inconsistency = EncodingError.invalidValue(
        KeyedEncodingContainer<Key>.self,
        EncodingError.Context(
          codingPath: codingPath(ref: ref),
          debugDescription: "attempt to acquire keyed container after encoding value"
        )
      )
      return Keyed<Key>(state: self, ref: ref)
    case .keyed(let keyedId):
      return Keyed<Key>(state: self, ref: Ref(nodeId: ref.nodeId, containerId: keyedId))
    case .unkeyed:
      inconsistency = EncodingError.invalidValue(
        KeyedEncodingContainer<Key>.self,
        EncodingError.Context(
          codingPath: codingPath(ref: ref),
          debugDescription: "attempt to acquire keyed container after acquiring unkeyed"
        )
      )
      return Keyed<Key>(state: self, ref: ref)
    }
  }

  func asUnkeyed(ref: Ref) -> Unkeyed {
    guard inconsistency == nil else { return Unkeyed(state: self, ref: ref) }
    let message: String
    switch nodes[ref.nodeId].storage {
    case .unset:
      defer { unkeyed.append([]) }
      nodes[ref.nodeId].storage = .unkeyed(unkeyed.count)
      return Unkeyed(state: self, ref: Ref(nodeId: ref.nodeId, containerId: unkeyed.count))
    case .unkeyed: message = "attempt to acquire unkeyed container again"
    case .keyed: message = "attempt to acquire unkeyed container after acquiring keyed"
    case .single: message = "attempt to acquire unkeyed container after encoding value"
    }
    inconsistency = EncodingError.invalidValue(
      UnkeyedEncodingContainer.self,
      EncodingError.Context(
        codingPath: codingPath(ref: ref),
        debugDescription: message
      )
    )
    return Unkeyed(state: self, ref: ref)
  }

  func nestedKeyed<Key: CodingKey>(ref: Ref, key: (any CodingKey)?) -> Keyed<Key> {
    guard inconsistency == nil else { return Keyed(state: self, ref: invalid(ref: ref, key: key)) }
    guard let key else {
      let key = Enigma.Pin.int(count(ref: ref))
      defer { links.append(Link(prevId: nodes[ref.nodeId].linkId, key: key)) }
      defer { keyed.append([:]) }
      defer { nodes.append(Node(linkId: links.count, storage: .keyed(keyed.count))) }
      unkeyed[ref.containerId].append(nodes.count)
      return Keyed(state: self, ref: Ref(nodeId: nodes.count, containerId: keyed.count))
    }
    let string = key.stringValue
    guard keyed[ref.containerId][string] == nil else {
      inconsistency = EncodingError.invalidValue(
        KeyedEncodingContainer<Key>.self,
        EncodingError.Context(
          codingPath: codingPath(ref: ref, key: key),
          debugDescription: "collision during acquiring nested container"
        )
      )
      return Keyed(state: self, ref: invalid(ref: ref, key: key))
    }
    defer { links.append(Link(prevId: nodes[ref.nodeId].linkId, key: key)) }
    defer { keyed.append([:]) }
    defer { nodes.append(Node(linkId: links.count, storage: .keyed(keyed.count))) }
    keyed[ref.containerId][string] = nodes.count
    return Keyed(state: self, ref: Ref(nodeId: nodes.count, containerId: keyed.count))
  }

  func nestedUnkeyed(ref: Ref, key: (any CodingKey)?) -> Unkeyed {
    guard inconsistency == nil else { return Unkeyed(state: self, ref: invalid(ref: ref, key: key)) }
    guard let key else {
      let key = Enigma.Pin.int(count(ref: ref))
      defer { links.append(Link(prevId: nodes[ref.nodeId].linkId, key: key)) }
      defer { unkeyed.append([]) }
      defer { nodes.append(Node(linkId: links.count, storage: .unkeyed(unkeyed.count))) }
      unkeyed[ref.containerId].append(nodes.count)
      return Unkeyed(state: self, ref: Ref(nodeId: nodes.count, containerId: unkeyed.count))
    }
    let string = key.stringValue
    guard keyed[ref.containerId][string] == nil else {
      inconsistency = EncodingError.invalidValue(
        UnkeyedEncodingContainer.self,
        EncodingError.Context(
          codingPath: codingPath(ref: ref, key: key),
          debugDescription: "collision during acquiring nested container"
        )
      )
      return Unkeyed(state: self, ref: invalid(ref: ref, key: key))
    }
    defer { links.append(Link(prevId: nodes[ref.nodeId].linkId, key: key)) }
    defer { unkeyed.append([]) }
    defer { nodes.append(Node(linkId: links.count, storage: .unkeyed(unkeyed.count))) }
    keyed[ref.containerId][string] = nodes.count
    return Unkeyed(state: self, ref: Ref(nodeId: nodes.count, containerId: unkeyed.count))
  }

  func nestedSingle(ref: Ref, key: (any CodingKey)?, type: Any.Type) -> Single {
    guard inconsistency == nil else { return Single(state: self, ref: invalid(ref: ref, key: key)) }
    guard let key else {
      let key = Enigma.Pin.int(count(ref: ref))
      defer { links.append(Link(prevId: nodes[ref.nodeId].linkId, key: key)) }
      defer { nodes.append(Node(linkId: links.count)) }
      unkeyed[ref.containerId].append(nodes.count)
      return Single(state: self, ref: Ref(nodeId: nodes.count, containerId: -1))
    }
    let string = key.stringValue
    guard keyed[ref.containerId][string] == nil else {
      inconsistency = EncodingError.invalidValue(type, EncodingError.Context(
        codingPath: codingPath(ref: ref, key: key),
        debugDescription: "collision during acquiring nested container"
      ))
      return Single(state: self, ref: invalid(ref: ref, key: key))
    }
    defer { links.append(Link(prevId: nodes[ref.nodeId].linkId, key: key)) }
    defer { nodes.append(Node(linkId: links.count)) }
    keyed[ref.containerId][string] = nodes.count
    return Single(state: self, ref: Ref(nodeId: nodes.count, containerId: -1))
  }

  private func invalid(ref: Ref, key: (any CodingKey)?) -> Ref {
    let prevId = ref.nodeId < 0 ? -ref.nodeId - 1 : nodes[ref.nodeId].linkId
    let key = key ?? Enigma.Pin.int(count(ref: ref))
    defer { links.append(Link(prevId: prevId, key: key)) }
    return Ref(nodeId: -links.count - 1, containerId: -1)
  }

  func store(_ value: Enigma, ref: Ref, key: (any CodingKey)?) throws {
    if let inconsistency {
      throw inconsistency
    } else if let key {
      let string = key.stringValue
      if keyed[ref.containerId][string] == nil {
        defer { nodes.append(Node(linkId: .max, storage: .single(value))) }
        keyed[ref.containerId][string] = nodes.count
      } else {
        throw EncodingError.invalidValue(value.asAny, EncodingError.Context(
          codingPath: codingPath(ref: ref, key: key),
          debugDescription: "value already encoded"
        ))
      }
    } else if ref.containerId < 0 {
      let message: String
      switch nodes[ref.nodeId].storage {
      case .unset: return nodes[ref.nodeId].storage = .single(value)
      case .single: message = "attempt to encode value again"
      case .keyed: message = "attempt to encode value after accuiring keyed container"
      case .unkeyed: message = "attempt to encode value after accuiring unkeyed container"
      }
      throw EncodingError.invalidValue(value.asAny, EncodingError.Context(
        codingPath: codingPath(ref: ref),
        debugDescription: message
      ))
    } else {
      defer { nodes.append(Node(linkId: .max, storage: .single(value))) }
      unkeyed[ref.containerId].append(nodes.count)
    }
  }

  func encodeSpecial<T: Encodable>(_ value: T, ref: Ref, key: (any CodingKey)?) throws -> Bool {
    if let inconsistency {
      throw inconsistency
    } else if T.self == Data.self, let value = value as? Data {
      try store(.data(value), ref: ref, key: key)
    } else if T.self == Date.self, let value = value as? Date {
      try store(.date(value), ref: ref, key: key)
    } else if T.self == Enigma.self, let enigma = value as? Enigma {
      guard ref.containerId < 0 else {
        try store(enigma, ref: ref, key: key)
        return true
      }
      switch nodes[ref.nodeId].storage {
      case .unset:
        switch enigma {
        case .array(let array):
          let offset = nodes.count
          var container: [Int] = []
          nodes.reserveCapacity(offset + array.count)
          container.reserveCapacity(array.count)
          for item in array.enumerated() {
            container.append(item.offset + offset)
            nodes.append(Node(storage: .single(item.element)))
          }
          defer { unkeyed.append(container) }
          nodes[ref.nodeId].storage = .unkeyed(unkeyed.count)
        case .dictionary(let dictionary):
          let offset = nodes.count
          nodes.reserveCapacity(offset + dictionary.count)
          let container = dictionary.mapValues { value in
            defer { nodes.append(Node(storage: .single(value))) }
            return nodes.count
          }
          defer { keyed.append(container) }
          nodes[ref.nodeId].storage = .keyed(keyed.count)
        default:
          nodes[ref.nodeId].storage = .single(enigma)
          return true
        }
      case .keyed(let keyedId):
        guard case .dictionary(let dictionary) = enigma else {
          throw EncodingError.invalidValue(enigma, EncodingError.Context(
            codingPath: codingPath(ref: ref),
            debugDescription: "attempt to encode value after accuiring keyed container"
          ))
        }
        nodes.reserveCapacity(nodes.count + dictionary.count)
        for (key, value) in dictionary {
          guard keyed[keyedId][key] == nil else {
            throw EncodingError.invalidValue(enigma, EncodingError.Context(
              codingPath: codingPath(ref: ref, key: Enigma.Pin.str(key)),
              debugDescription: "attempt to encode value again"
            ))
          }
          defer { nodes.append(Node(storage: .single(value))) }
          keyed[keyedId][key] = nodes.count
        }
      case .single:
        throw EncodingError.invalidValue(enigma, EncodingError.Context(
          codingPath: codingPath(ref: ref),
          debugDescription: "attempt to encode value again"
        ))
      case .unkeyed:
        throw EncodingError.invalidValue(enigma, EncodingError.Context(
          codingPath: codingPath(ref: ref),
          debugDescription: "attempt to encode value after accuiring unkeyed container"
        ))
      }
    } else {
      return false
    }
    return true
  }

  private func codingPath(linkId: consuming Int, key: (any CodingKey)?) -> [any CodingKey] {
    var linkId = consume linkId
    var path: [any CodingKey] = if let key { [key] } else { [] }
    while linkId < .max {
      path.append(links[linkId].key)
      linkId = links[linkId].prevId
    }
    path.reverse()
    return path
  }

  private func materialize(nodeId: Int) -> Enigma {
    switch nodes[nodeId].storage {
    case .unset: .dictionary([:])
    case .single(let single): single
    case .keyed(let keyedId): .dictionary(keyed[keyedId].mapValues(materialize(nodeId:)))
    case .unkeyed(let unkeyedId): .array(unkeyed[unkeyedId].map(materialize(nodeId:)))
    }
  }

  @usableFromInline
  static func encode(value: some Encodable, userInfo: [CodingUserInfoKey: Any]) throws -> Enigma {
    let state = EnigmaEncoder(userInfo: userInfo)
    let ref = Ref(nodeId: 0, containerId: -1)
    if try !state.encodeSpecial(value, ref: ref, key: nil) {
      try value.encode(to: Single(state: state, ref: ref))
    }
    if let error = state.inconsistency {
      throw error
    } else if case .unset = state.nodes[0].storage {
      throw EncodingError.invalidValue(value, EncodingError.Context(
        codingPath: [],
        debugDescription: "top level encoded to nothing"
      ))
    } else {
      return state.materialize(nodeId: 0)
    }
  }

  struct Node {
    var linkId: Int = .max
    var storage: Storage = .unset
  }

  enum Storage {
    case unset
    case single(Enigma)
    case keyed(Int)
    case unkeyed(Int)
  }

  struct Link {
    // linkId ?? Int.max
    let prevId: Int
    let key: any CodingKey
  }

  struct Ref {
    // valid ? nodeId : -1 - linkId
    let nodeId: Int
    let containerId: Int
  }
}
