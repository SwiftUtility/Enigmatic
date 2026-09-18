import Foundation

final class EncoderContext {
  typealias EntryID = Int
  typealias KeyedStorageID = Int
  typealias UnkeyedStorageID = Int

  enum Storage {
    case unset
    case value(Enigma)
    case keyed(KeyedStorageID)
    case unkeyed(UnkeyedStorageID)
  }

  struct Entry {
    var result: Result<Storage, Error> = .success(.unset)
    let parent: EntryID?
    let codingKey: Enigma.Pin?
    let codingPathCount: Int
  }

  private var entries: [Entry] = [
    Entry(parent: nil, codingKey: nil, codingPathCount: 0)
  ]
  private var keyedStorages: [[String: EntryID]] = []
  private var unkeyedStorages: [[EntryID]] = []
  private var codingPathBuffer: [CodingKey] = []

  let userInfo: [CodingUserInfoKey: Any]

  init(userInfo: [CodingUserInfoKey: Any]) {
    self.userInfo = userInfo
  }

  static func encode(_ value: any Encodable, userInfo: [CodingUserInfoKey: Any] = [:]) throws-> Enigma {
    let context = EncoderContext(userInfo: userInfo)
    try value.encode(to: ValueEncoder(context: context, entry: 0))
    return try context.materialize(0)
  }

  var root: EntryID { 0 }

  func makeValue(at entry: EntryID) -> ValueEncoder {
    ValueEncoder(context: self, entry: entry)
  }

  func makeKeyed<Key: CodingKey>(at entry: EntryID) -> KeyedEncodingContainer<Key> {
    KeyedEncodingContainer(KeyedEncoder<Key>(context: self, entry: entry))
  }

  func makeUnkeyed(at entry: EntryID) -> UnkeyedEncoder {
    UnkeyedEncoder(context: self, entry: entry)
  }

  func codingPath(for entry: EntryID) -> [CodingKey] {
    codingPathBuffer.removeAll(keepingCapacity: true)
    codingPathBuffer.reserveCapacity(entries[entry].codingPathCount)

    var current: EntryID? = entry
    while let id = current {
      let item = entries[id]
      if let key = item.codingKey {
        codingPathBuffer.append(key)
      }
      current = item.parent
    }

    codingPathBuffer.reverse()
    return codingPathBuffer
  }

  // MARK: - Non-throwing container creation

  /// Keyed containers are reopenable. Calling this repeatedly for the same entry is valid.
  func ensureKeyed(at entry: EntryID) {
    switch entries[entry].result {
    case .failure:
      return
    case .success(.unset):
      let storage = keyedStorages.count
      keyedStorages.append([:])
      entries[entry].result = .success(.keyed(storage))
    case .success(.keyed):
      return
    case .success(let storage):
      poison(
        entry,
        value: (),
        description: "cannot create a keyed container because this path already contains \(description(of: storage))"
      )
    }
  }

  /// Unkeyed containers are single-create. A second creation poisons the entry.
  func createUnkeyed(at entry: EntryID) {
    switch entries[entry].result {
    case .failure:
      return
    case .success(.unset):
      let storage = unkeyedStorages.count
      unkeyedStorages.append([])
      entries[entry].result = .success(.unkeyed(storage))
    case .success(.unkeyed):
      poison(
        entry,
        value: (),
        description: "an unkeyed container has already been created at this coding path"
      )
    case .success(let storage):
      poison(
        entry,
        value: (),
        description: "cannot create an unkeyed container because this path already contains \(description(of: storage))"
      )
    }
  }

  // MARK: - Throwing storage operations

  func store(_ value: Enigma, at entry: EntryID) throws {
    switch entries[entry].result {
    case .failure(let error):
      throw error
    case .success(.unset):
      entries[entry].result = .success(.value(value))
    case .success(let storage):
      throw poison(
        entry,
        value: value,
        description: "cannot encode a value because this path already contains \(description(of: storage))"
      )
    }
  }

  func keyedChild<Key: CodingKey>(at parent: EntryID, for key: Key) throws -> EntryID {
    let storage = try existingKeyedStorage(at: parent)
    let stringKey = key.stringValue

    if let child = keyedStorages[storage][stringKey] {
      return child
    }

    let child = makeEntry(parent: parent, codingKey: Enigma.Pin(key))
    keyedStorages[storage][stringKey] = child
    return child
  }

  func appendUnkeyedChild(at parent: EntryID) throws -> EntryID {
    let storage = try existingUnkeyedStorage(at: parent)
    let index = unkeyedStorages[storage].count
    let child = makeEntry(parent: parent, codingKey: .int(index))
    unkeyedStorages[storage].append(child)
    return child
  }

  func unkeyedCount(at entry: EntryID) -> Int {
    guard case .success(.unkeyed(let storage)) = entries[entry].result else {
      return 0
    }
    return unkeyedStorages[storage].count
  }

  // MARK: - Non-throwing nested-container helpers

  func ensureKeyedChild<Key: CodingKey>(at parent: EntryID, for key: Key) -> EntryID {
    let child = keyedChildForEncoder(at: parent, for: key)
    guard child != parent || !isFailed(parent) else { return child }
    ensureKeyed(at: child)
    return child
  }

  func createUnkeyedChild<Key: CodingKey>(at parent: EntryID, for key: Key) -> EntryID {
    let child = keyedChildForEncoder(at: parent, for: key)
    guard child != parent || !isFailed(parent) else { return child }
    createUnkeyed(at: child)
    return child
  }

  func keyedChildForEncoder<Key: CodingKey>(at parent: EntryID, for key: Key) -> EntryID {
    switch entries[parent].result {
    case .failure:
      return parent
    case .success(.keyed(let storage)):
      let stringKey = key.stringValue
      if let child = keyedStorages[storage][stringKey] {
        return child
      }
      let child = makeEntry(parent: parent, codingKey: Enigma.Pin(key))
      keyedStorages[storage][stringKey] = child
      return child
    case .success(let storage):
      poison(
        parent,
        value: (),
        description: "expected a keyed container, found \(description(of: storage))"
      )
      return parent
    }
  }

  func appendChildForEncoder(at parent: EntryID) -> EntryID {
    switch entries[parent].result {
    case .failure:
      return parent
    case .success(.unkeyed(let storage)):
      let index = unkeyedStorages[storage].count
      let child = makeEntry(parent: parent, codingKey: .int(index))
      unkeyedStorages[storage].append(child)
      return child
    case .success(let storage):
      poison(
        parent,
        value: (),
        description: "expected an unkeyed container, found \(description(of: storage))"
      )
      return parent
    }
  }

  func appendKeyedChildForEncoder(at parent: EntryID) -> EntryID {
    let child = appendChildForEncoder(at: parent)
    guard child != parent || !isFailed(parent) else { return child }
    ensureKeyed(at: child)
    return child
  }

  func appendUnkeyedChildForEncoder(at parent: EntryID) -> EntryID {
    let child = appendChildForEncoder(at: parent)
    guard child != parent || !isFailed(parent) else { return child }
    createUnkeyed(at: child)
    return child
  }

  // MARK: - Special values

  func encodeSpecial<T: Encodable>(_ value: T, at entry: EntryID) throws -> Bool {
    if let value = value as? Enigma {
      try store(value, at: entry)
      return true
    }
    if let value = value as? Data {
      try store(.data(value), at: entry)
      return true
    }
    if let value = value as? Date {
      try store(.date(value), at: entry)
      return true
    }
    return false
  }

  // MARK: - Materialization

  func materialize(_ entry: EntryID) throws -> Enigma {
    switch entries[entry].result {
    case .failure(let error):
      throw error
    case .success(.unset):
      throw poison(entry, value: (), description: "nothing was encoded at this coding path")
    case .success(.value(let value)):
      return value
    case .success(.keyed(let storage)):
      let source = keyedStorages[storage]
      var result: [String: Enigma] = [:]
      result.reserveCapacity(source.count)
      for (key, child) in source {
        result[key] = try materialize(child)
      }
      return .dictionary(result)
    case .success(.unkeyed(let storage)):
      let source = unkeyedStorages[storage]
      var result: [Enigma] = []
      result.reserveCapacity(source.count)
      for child in source {
        result.append(try materialize(child))
      }
      return .array(result)
    }
  }

  // MARK: - Private

  private func makeEntry(parent: EntryID, codingKey: Enigma.Pin) -> EntryID {
    let id = entries.count
    entries.append(Entry(
      parent: parent,
      codingKey: codingKey,
      codingPathCount: entries[parent].codingPathCount + 1
    ))
    return id
  }

  private func existingKeyedStorage(at entry: EntryID) throws -> KeyedStorageID {
    switch entries[entry].result {
    case .failure(let error):
      throw error
    case .success(.keyed(let storage)):
      return storage
    case .success(let storage):
      throw poison(
        entry,
        value: (),
        description: "expected a keyed container, found \(description(of: storage))"
      )
    }
  }

  private func existingUnkeyedStorage(at entry: EntryID) throws -> UnkeyedStorageID {
    switch entries[entry].result {
    case .failure(let error):
      throw error
    case .success(.unkeyed(let storage)):
      return storage
    case .success(let storage):
      throw poison(
        entry,
        value: (),
        description: "expected an unkeyed container, found \(description(of: storage))"
      )
    }
  }

  private func isFailed(_ entry: EntryID) -> Bool {
    if case .failure = entries[entry].result { true } else { false }
  }

  @discardableResult
  private func poison(_ entry: EntryID, value: Any, description: String) -> Error {
    if case .failure(let error) = entries[entry].result {
      return error
    }

    let error = EncodingError.invalidValue(
      value,
      .init(codingPath: codingPath(for: entry), debugDescription: description)
    )
    entries[entry].result = .failure(error)
    return error
  }

  private func description(of storage: Storage) -> String {
    switch storage {
    case .unset: "unset storage"
    case .value: "an encoded value"
    case .keyed: "a keyed container"
    case .unkeyed: "an unkeyed container"
    }
  }
}
