import Foundation

extension OtherEnigmaEncoder {
  struct Keyed<Key: CodingKey>: KeyedEncodingContainerProtocol {
    let state: State
    let ref: Ref

    var codingPath: [CodingKey] {
      state.codingPath(ref: ref)
    }

    mutating func encodeNil(forKey key: Key) throws {
      try state.store(.null, ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: Bool, forKey key: Key) throws {
      try state.store(.bool(value), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: String, forKey key: Key) throws {
      try state.store(.string(value), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: Double, forKey key: Key) throws {
      try state.store(.double(value), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: Float, forKey key: Key) throws {
      try state.store(.float(value), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: Int, forKey key: Key) throws {
      try state.store(.int(value), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: Int8, forKey key: Key) throws {
      try state.store(.int8(value), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: Int16, forKey key: Key) throws {
      try state.store(.int16(value), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: Int32, forKey key: Key) throws {
      try state.store(.int32(value), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: Int64, forKey key: Key) throws {
      try state.store(.int64(value), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: UInt, forKey key: Key) throws {
      try state.store(.uint(value), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: UInt8, forKey key: Key) throws {
      try state.store(.uint8(value), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: UInt16, forKey key: Key) throws {
      try state.store(.uint16(value), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: UInt32, forKey key: Key) throws {
      try state.store(.uint32(value), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: UInt64, forKey key: Key) throws {
      try state.store(.uint64(value), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
      let ref = state.nestedRef(ref: ref, key: key)
      guard try !state.encodeSpecial(value, ref: ref) else { return }
      try value.encode(to: Single(state: state, ref: ref))
    }

    mutating func nestedContainer<NestedKey: CodingKey>(
      keyedBy _: NestedKey.Type,
      forKey key: Key
    ) -> KeyedEncodingContainer<NestedKey> {
      KeyedEncodingContainer(state.asKeyed(ref: state.nestedRef(ref: ref, key: key)))
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
      state.asUnkeyed(ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func superEncoder() -> Encoder {
      Single(state: state, ref: state.nestedRef(ref: ref, key: Enigma.Pin.super))
    }

    mutating func superEncoder(forKey key: Key) -> Encoder {
      Single(state: state, ref: state.nestedRef(ref: ref, key: key))
    }
  }
}

//final class EncoderContext {
//  let userInfo: [CodingUserInfoKey: Any]
//  private var nodes: [Node] = [Node(link: nil)]
//  private var fails: [Fail] = []
//  private var dicts: [[String: Int]] = []
//  private var arrays: [[Int]] = []
//
//  private init(userInfo: [CodingUserInfoKey: Any]) {
//    self.userInfo = userInfo
//  }
//
//  func codingPath(ref: Ref, key: (any CodingKey)? = nil) -> [any CodingKey] {
//    if ref.failed {
//      codingPath(nodeId: fails[ref.id].nodeId, key: nil) + codingPath(failId: ref.id, key: key)
//    } else {
//      codingPath(nodeId: ref.id, key: key)
//    }
//  }
//
//  func count(ref: Ref) -> Int {
//    guard !ref.failed, case .arrayId(let arrayId) = nodes[ref.id].storage else { return 0 }
//    return arrays[arrayId].count
//  }
//
//  func asKeyed<Key: CodingKey>(ref: Ref) -> KeyedEncoder<Key> {
//    guard !ref.failed else { return KeyedEncoder<Key>(context: self, ref: ref) }
//    switch nodes[ref.id].storage {
//    case .dictId:
//      return KeyedEncoder<Key>(context: self, ref: ref)
//    case .unset:
//      defer { dicts.append([:]) }
//      nodes[ref.id].storage = .dictId(dicts.count)
//      return KeyedEncoder<Key>(context: self, ref: ref)
//    case .value, .arrayId:
//      defer { fails.append(Fail(nodeId: ref.id, link: nil)) }
//      return KeyedEncoder<Key>(context: self, ref: Ref(id: fails.count, failed: true))
//    }
//  }
//
//  func asUnkeyed(ref: Ref) -> UnkeyedEncoder {
//    guard !ref.failed else { return UnkeyedEncoder(context: self, ref: ref) }
//    switch nodes[ref.id].storage {
//    case .unset:
//      defer { arrays.append([]) }
//      nodes[ref.id].storage = .arrayId(arrays.count)
//      return UnkeyedEncoder(context: self, ref: ref)
//    case .arrayId, .dictId, .value:
//      defer { fails.append(Fail(nodeId: ref.id, link: nil)) }
//      return UnkeyedEncoder(context: self, ref: Ref(id: fails.count, failed: true))
//    }
//  }
//
//  private func codingPath(nodeId: Int, key: (any CodingKey)?) -> [any CodingKey] {
//    var path: [any CodingKey] = []
//    if let key { path.append(key) }
//    var link: Link? = nodes[nodeId].link
//    while let current = link {
//      path.append(current.codingKey)
//      link = nodes[current.prev].link
//    }
//    path.reverse()
//    return path
//  }
//
//  private func codingPath(failId: Int, key: (any CodingKey)?) -> [any CodingKey] {
//    var path: [any CodingKey] = []
//    if let key { path.append(key) }
//    var link: Link? = fails[failId].link
//    while let current = link {
//      path.append(current.codingKey)
//      link = fails[current.prev].link
//    }
//    path.reverse()
//    return path
//  }
//
////  private func error(
////    value: Any,
////    nodeId: Int,
////    key: (any CodingKey)? = nil,
////  ) -> EncodingError {
////    let underlyingError = if let deferred {
////      EncodingError.invalidValue((nil as Any?) as Any, EncodingError.Context(
////        codingPath: codingPath(nodeId: underlyingError.nodeId),
////        debugDescription: deferred.fail.deferred,
////        underlyingError: suberror
////      ))
////    } else {
////      nil
////    }
////    return EncodingError.invalidValue(value, EncodingError.Context(
////      codingPath: codingPath(nodeId: nodeId, key: key),
////      debugDescription: fail.error,
////      underlyingError: underlyingError
////    ))
////  }
//
//
//
////  func ensureKeyed(at entry: EntryID) {
////    switch nodes[entry].storage {
////    case .failure:
////      return
////    case .success(.unset):
////      let storage = keyedStorages.count
////      keyedStorages.append([:])
////      nodes[entry].storage = .success(.keyed(storage))
////    case .success(.keyed):
////      return
////    case .success(let storage):
////      poison(
////        entry,
////        value: (),
////        description: "cannot create a keyed container because this path already contains \(description(of: storage))"
////      )
////    }
////  }
//
////  func createUnkeyed(nodeId: EntryID) {
////    switch nodes[nodeId].storage {
////    case .failure:
////      return
////    case .unset:
////      let storage = unkeyedStorages.count
////      unkeyedStorages.append([])
////      nodes[nodeId].storage = .success(.unkeyed(storage))
////    case .success(.unkeyed):
////      poison(
////        nodeId,
////        value: (),
////        description: "an unkeyed container has already been created at this coding path"
////      )
////    case .success(let storage):
////      poison(
////        nodeId,
////        value: (),
////        description: "cannot create an unkeyed container because this path already contains \(description(of: storage))"
////      )
////    }
////  }
//
//  // MARK: - Throwing storage operations
//
////  func store(_ value: Enigma, at entry: EntryID) throws {
////    switch nodes[entry].storage {
////    case .failure(let error):
////      throw error
////    case .success(.unset):
////      nodes[entry].storage = .success(.value(value))
////    case .success(let storage):
////      throw poison(
////        entry,
////        value: value,
////        description: "cannot encode a value because this path already contains \(description(of: storage))"
////      )
////    }
////  }
////
////  func keyedChild<Key: CodingKey>(at parent: EntryID, for key: Key) throws -> EntryID {
////    let storage = try existingKeyedStorage(at: parent)
////    let stringKey = key.stringValue
////
////    if let child = keyedStorages[storage][stringKey] {
////      return child
////    }
////
////    let child = makeEntry(parent: parent, codingKey: Enigma.Pin(key))
////    keyedStorages[storage][stringKey] = child
////    return child
////  }
////
////  func appendUnkeyedChild(at parent: EntryID) throws -> EntryID {
////    let storage = try existingUnkeyedStorage(at: parent)
////    let index = unkeyedStorages[storage].count
////    let child = makeEntry(parent: parent, codingKey: Enigma.Pin.int(index))
////    unkeyedStorages[storage].append(child)
////    return child
////  }
//
//  // MARK: - Non-throwing nested-container helpers
//
////  func ensureKeyedChild<Key: CodingKey>(at parent: EntryID, for key: Key) -> EntryID {
////    let child = keyedChildForEncoder(at: parent, for: key)
////    guard child != parent || !isFailed(parent) else { return child }
////    ensureKeyed(at: child)
////    return child
////  }
////
////  func createUnkeyedChild<Key: CodingKey>(at parent: EntryID, for key: Key) -> EntryID {
////    let child = keyedChildForEncoder(at: parent, for: key)
////    guard child != parent || !isFailed(parent) else { return child }
////    createUnkeyed(nodeId: child)
////    return child
////  }
////
////  func keyedChildForEncoder<Key: CodingKey>(at parent: EntryID, for key: Key) -> EntryID {
////    switch nodes[parent].storage {
////    case .failure:
////      return parent
////    case .success(.keyed(let storage)):
////      let stringKey = key.stringValue
////      if let child = keyedStorages[storage][stringKey] {
////        return child
////      }
////      let child = makeEntry(parent: parent, codingKey: Enigma.Pin(key))
////      keyedStorages[storage][stringKey] = child
////      return child
////    case .success(let storage):
////      poison(
////        parent,
////        value: (),
////        description: "expected a keyed container, found \(description(of: storage))"
////      )
////      return parent
////    }
////  }
////
////  func appendChildForEncoder(at parent: EntryID) -> EntryID {
////    switch nodes[parent].storage {
////    case .failure:
////      return parent
////    case .success(.unkeyed(let storage)):
////      let index = unkeyedStorages[storage].count
////      let child = makeEntry(parent: parent, codingKey: Enigma.Pin.int(index))
////      unkeyedStorages[storage].append(child)
////      return child
////    case .success(let storage):
////      poison(
////        parent,
////        value: (),
////        description: "expected an unkeyed container, found \(description(of: storage))"
////      )
////      return parent
////    }
////  }
////
////  func appendKeyedChildForEncoder(at parent: EntryID) -> EntryID {
////    let child = appendChildForEncoder(at: parent)
////    guard child != parent || !isFailed(parent) else { return child }
////    ensureKeyed(at: child)
////    return child
////  }
////
////  func appendUnkeyedChildForEncoder(at parent: EntryID) -> EntryID {
////    let child = appendChildForEncoder(at: parent)
////    guard child != parent || !isFailed(parent) else { return child }
////    createUnkeyed(nodeId: child)
////    return child
////  }
//
//  // MARK: - Special values
//
//
//  // MARK: - Materialization
//
//  // MARK: - Private
//
////  private func makeEntry(parent: EntryID, codingKey: any CodingKey) -> EntryID {
////    let id = nodes.count
////    nodes.append(Node(link: Link(parent: parent, codingKey: codingKey)))
////    return id
////  }
////
////  private func existingKeyedStorage(at entry: EntryID) throws -> KeyedStorageID {
////    switch nodes[entry].storage {
////    case .failure(let error):
////      throw error
////    case .success(.keyed(let storage)):
////      return storage
////    case .success(let storage):
////      throw poison(
////        entry,
////        value: (),
////        description: "expected a keyed container, found \(description(of: storage))"
////      )
////    }
////  }
////
////  private func existingUnkeyedStorage(at entry: EntryID) throws -> UnkeyedStorageID {
////    switch nodes[entry].storage {
////    case .failure(let error):
////      throw error
////    case .success(.unkeyed(let storage)):
////      return storage
////    case .success(let storage):
////      throw poison(
////        entry,
////        value: (),
////        description: "expected an unkeyed container, found \(description(of: storage))"
////      )
////    }
////  }
////
////  private func isFailed(_ entry: EntryID) -> Bool {
////    if case .failure = nodes[entry].storage { true } else { false }
////  }
////
////  @discardableResult
////  private func poison(_ entry: EntryID, value: Any, description: String) -> Error {
////    if case .failure(let error) = nodes[entry].storage {
////      return error
////    }
////
////    let error = EncodingError.invalidValue(
////      value,
////      .init(codingPath: codingPath(nodeId: entry), debugDescription: description)
////    )
////    nodes[entry].storage = .failure(error)
////    return error
////  }
////
////  private func description(of storage: Storage) -> String {
////    switch storage {
////    case .unset: "unset storage"
////    case .value: "an encoded value"
////    case .keyed: "a keyed container"
////    case .unkeyed: "an unkeyed container"
////    }
////  }
//
////  typealias EntryID = Int
////  typealias KeyedStorageID = Int
////  typealias UnkeyedStorageID = Int
//
//  enum Storage {
//    case unset
//    case value(Enigma)
//    case dictId(Int)
//    case arrayId(Int)
//  }
//
//  struct Node {
//    var storage: Storage = .unset
//    let link: Link?
//  }
//
//  struct Fail {
//    let nodeId: Int
//    let link: Link?
//  }
//
//  struct Link {
//    let prev: Int
//    let codingKey: any CodingKey
//  }
//
//  struct Ref {
//    var id: Int
//    var failed: Bool
//  }
//
////
////    mutating func asKeyed<Key: CodingKey>(context: EncoderContext, nodeId: Int) -> KeyedEncoder<Key> {
////      switch storage {
////      case .fail, .keyed:
////        return KeyedEncoder<Key>(context: context, nodeId: nodeId)
////      case .unset:
////        defer { context.keyedStorages.append([:]) }
////        storage = .keyed(context.keyedStorages.count)
////        return KeyedEncoder<Key>(context: context, nodeId: nodeId)
////      case .unkeyed:
////        defer { context.nodes.append(Node(storage: .fail(.unkeyed, nodeId), link: link)) }
////        return KeyedEncoder<Key>(context: context, nodeId: context.nodes.count)
////      case .value:
////        defer { context.nodes.append(Node(storage: .fail(.value, nodeId), link: link)) }
////        return KeyedEncoder<Key>(context: context, nodeId: context.nodes.count)
////      }
////    }
////
////    mutating func store(
////      value: Enigma,
////      context: EncoderContext,
////      nodeId: Int,
////      key: (any CodingKey)? = nil
////    ) throws {
////      switch storage {
////      case .fail(let fail, let failId):
////        throw context.deferredError(value: value, nodeId: nodeId, fail: fail, failId: failId)
////      case .unset:
////        storage = .value(value)
////      case .keyed:
////        throw context.error(
////          value: value.rawAny,
////          text: "attempt to override keyed container",
////          path: codingPath(nodeId: nodeId, current: key)
////        )
////      }
////    }
////  }
//}
