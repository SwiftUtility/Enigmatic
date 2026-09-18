import Foundation

struct ValueEncoder: Encoder, SingleValueEncodingContainer {
  let context: EncoderContext
  let entry: EncoderContext.EntryID

  var codingPath: [CodingKey] {
    context.codingPath(for: entry)
  }

  var userInfo: [CodingUserInfoKey: Any] {
    context.userInfo
  }

  func singleValueContainer() -> SingleValueEncodingContainer {
    self
  }

  func container<Key: CodingKey>(keyedBy _: Key.Type) -> KeyedEncodingContainer<Key> {
    context.ensureKeyed(at: entry)
    return context.makeKeyed(at: entry)
  }

  func unkeyedContainer() -> UnkeyedEncodingContainer {
    context.createUnkeyed(at: entry)
    return context.makeUnkeyed(at: entry)
  }

  mutating func encodeNil() throws {
    try context.store(.null, at: entry)
  }

  mutating func encode(_ value: Bool) throws {
    try context.store(.bool(value), at: entry)
  }

  mutating func encode(_ value: String) throws {
    try context.store(.string(value), at: entry)
  }

  mutating func encode(_ value: Double) throws {
    try context.store(.double(value), at: entry)
  }

  mutating func encode(_ value: Float) throws {
    try context.store(.float(value), at: entry)
  }

  mutating func encode(_ value: Int) throws {
    try context.store(.int(value), at: entry)
  }

  mutating func encode(_ value: Int8) throws {
    try context.store(.int8(value), at: entry)
  }

  mutating func encode(_ value: Int16) throws {
    try context.store(.int16(value), at: entry)
  }

  mutating func encode(_ value: Int32) throws {
    try context.store(.int32(value), at: entry)
  }

  mutating func encode(_ value: Int64) throws {
    try context.store(.int64(value), at: entry)
  }

  mutating func encode(_ value: UInt) throws {
    try context.store(.uint(value), at: entry)
  }

  mutating func encode(_ value: UInt8) throws {
    try context.store(.uint8(value), at: entry)
  }

  mutating func encode(_ value: UInt16) throws {
    try context.store(.uint16(value), at: entry)
  }

  mutating func encode(_ value: UInt32) throws {
    try context.store(.uint32(value), at: entry)
  }

  mutating func encode(_ value: UInt64) throws {
    try context.store(.uint64(value), at: entry)
  }

  mutating func encode<T: Encodable>(_ value: T) throws {
    if try !context.encodeSpecial(value, at: entry) {
      try value.encode(to: self)
    }
  }
}
