import Foundation

struct KeyedEncoder<Key: CodingKey>: KeyedEncodingContainerProtocol {
  let context: EncoderContext
  let entry: EncoderContext.EntryID

  var codingPath: [CodingKey] {
    context.codingPath(for: entry)
  }

  mutating func encodeNil(forKey key: Key) throws {
    try store(.null, forKey: key)
  }

  mutating func encode(_ value: Bool, forKey key: Key) throws {
    try store(.bool(value), forKey: key)
  }

  mutating func encode(_ value: String, forKey key: Key) throws {
    try store(.string(value), forKey: key)
  }

  mutating func encode(_ value: Double, forKey key: Key) throws {
    try store(.double(value), forKey: key)
  }

  mutating func encode(_ value: Float, forKey key: Key) throws {
    try store(.float(value), forKey: key)
  }

  mutating func encode(_ value: Int, forKey key: Key) throws {
    try store(.int(value), forKey: key)
  }

  mutating func encode(_ value: Int8, forKey key: Key) throws {
    try store(.int8(value), forKey: key)
  }

  mutating func encode(_ value: Int16, forKey key: Key) throws {
    try store(.int16(value), forKey: key)
  }

  mutating func encode(_ value: Int32, forKey key: Key) throws {
    try store(.int32(value), forKey: key)
  }

  mutating func encode(_ value: Int64, forKey key: Key) throws {
    try store(.int64(value), forKey: key)
  }

  mutating func encode(_ value: UInt, forKey key: Key) throws {
    try store(.uint(value), forKey: key)
  }

  mutating func encode(_ value: UInt8, forKey key: Key) throws {
    try store(.uint8(value), forKey: key)
  }

  mutating func encode(_ value: UInt16, forKey key: Key) throws {
    try store(.uint16(value), forKey: key)
  }

  mutating func encode(_ value: UInt32, forKey key: Key) throws {
    try store(.uint32(value), forKey: key)
  }

  mutating func encode(_ value: UInt64, forKey key: Key) throws {
    try store(.uint64(value), forKey: key)
  }

  mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
    let child = try context.keyedChild(at: entry, for: key)
    if try !context.encodeSpecial(value, at: child) {
      try value.encode(to: context.makeValue(at: child))
    }
  }

  mutating func nestedContainer<NestedKey: CodingKey>(
    keyedBy _: NestedKey.Type,
    forKey key: Key
  ) -> KeyedEncodingContainer<NestedKey> {
    let child = context.ensureKeyedChild(at: entry, for: key)
    return context.makeKeyed(at: child)
  }

  mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
    let child = context.createUnkeyedChild(at: entry, for: key)
    return context.makeUnkeyed(at: child)
  }

  mutating func superEncoder() -> Encoder {
    let child = context.keyedChildForEncoder(at: entry, for: Enigma.Pin.super)
    return context.makeValue(at: child)
  }

  mutating func superEncoder(forKey key: Key) -> Encoder {
    let child = context.keyedChildForEncoder(at: entry, for: key)
    return context.makeValue(at: child)
  }

  private mutating func store(_ value: Enigma, forKey key: Key) throws {
    let child = try context.keyedChild(at: entry, for: key)
    try context.store(value, at: child)
  }
}
