import Foundation

struct ValueEncoder: Encoder, SingleValueEncodingContainer {
  let context: EncoderContext
  let codingPath: [CodingKey]

  var userInfo: [CodingUserInfoKey: Any] { [:] }

  func singleValueContainer() -> SingleValueEncodingContainer { self }

  func container<Key>(keyedBy _: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
    try? context.store(value: .dictionary([:]), path: codingPath)
    return context.makeKeyed(path: codingPath)
  }

  func unkeyedContainer() -> UnkeyedEncodingContainer {
    try? context.store(value: .array([]), path: codingPath)
    return context.makeUnkeyed(path: codingPath)
  }

  mutating func encodeNil() throws {
    try context.store(value: .null, path: codingPath)
  }

  mutating func encode(_ value: String) throws {
    try context.store(value: .string(value), path: codingPath)
  }

  mutating func encode(_ value: Bool) throws {
    try context.store(value: .bool(value), path: codingPath)
  }

  mutating func encode(_ value: Double) throws {
    try context.store(value: .double(value), path: codingPath)
  }

  mutating func encode(_ value: Float) throws {
    try context.store(value: .float(value), path: codingPath)
  }

  mutating func encode(_ value: Int) throws {
    try context.store(value: .int(value), path: codingPath)
  }

  mutating func encode(_ value: Int8) throws {
    try context.store(value: .int8(value), path: codingPath)
  }

  mutating func encode(_ value: Int16) throws {
    try context.store(value: .int16(value), path: codingPath)
  }

  mutating func encode(_ value: Int32) throws {
    try context.store(value: .int32(value), path: codingPath)
  }

  mutating func encode(_ value: Int64) throws {
    try context.store(value: .int64(value), path: codingPath)
  }

  mutating func encode(_ value: UInt) throws {
    try context.store(value: .uint(value), path: codingPath)
  }

  mutating func encode(_ value: UInt8) throws {
    try context.store(value: .uint8(value), path: codingPath)
  }

  mutating func encode(_ value: UInt16) throws {
    try context.store(value: .uint16(value), path: codingPath)
  }

  mutating func encode(_ value: UInt32) throws {
    try context.store(value: .uint32(value), path: codingPath)
  }

  mutating func encode(_ value: UInt64) throws {
    try context.store(value: .uint64(value), path: codingPath)
  }

  mutating func encode<T: Encodable>(_ value: T) throws {
    if let value = value as? Data { try context.store(value: .data(value), path: codingPath) }
    else if let value = value as? Date { try context.store(value: .date(value), path: codingPath) }
    else if let value = value as? Enigma { try context.store(value: value, path: codingPath) }
    else { try value.encode(to: self) }
  }
}
