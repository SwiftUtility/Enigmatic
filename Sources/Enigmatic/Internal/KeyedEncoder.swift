import Foundation

struct KeyedEncoder<Key: CodingKey>: KeyedEncodingContainerProtocol {
  let context: EncoderContext
  let codingPath: [CodingKey]

  mutating func encodeNil(forKey key: Key) throws {
    try context.store(value: .null, path: codingPath + [key])
  }

  mutating func encode(_ value: Bool, forKey key: Key) throws {
    try context.store(value: .bool(value), path: codingPath + [key])
  }

  mutating func encode(_ value: String, forKey key: Key) throws {
    try context.store(value: .string(value), path: codingPath + [key])
  }

  mutating func encode(_ value: Double, forKey key: Key) throws {
    try context.store(value: .double(value), path: codingPath + [key])
  }

  mutating func encode(_ value: Float, forKey key: Key) throws {
    try context.store(value: .float(value), path: codingPath + [key])
  }

  mutating func encode(_ value: Int, forKey key: Key) throws {
    try context.store(value: .int(value), path: codingPath + [key])
  }

  mutating func encode(_ value: Int8, forKey key: Key) throws {
    try context.store(value: .int8(value), path: codingPath + [key])
  }

  mutating func encode(_ value: Int16, forKey key: Key) throws {
    try context.store(value: .int16(value), path: codingPath + [key])
  }

  mutating func encode(_ value: Int32, forKey key: Key) throws {
    try context.store(value: .int32(value), path: codingPath + [key])
  }

  mutating func encode(_ value: Int64, forKey key: Key) throws {
    try context.store(value: .int64(value), path: codingPath + [key])
  }

  mutating func encode(_ value: UInt, forKey key: Key) throws {
    try context.store(value: .uint(value), path: codingPath + [key])
  }

  mutating func encode(_ value: UInt8, forKey key: Key) throws {
    try context.store(value: .uint8(value), path: codingPath + [key])
  }

  mutating func encode(_ value: UInt16, forKey key: Key) throws {
    try context.store(value: .uint16(value), path: codingPath + [key])
  }

  mutating func encode(_ value: UInt32, forKey key: Key) throws {
    try context.store(value: .uint32(value), path: codingPath + [key])
  }

  mutating func encode(_ value: UInt64, forKey key: Key) throws {
    try context.store(value: .uint64(value), path: codingPath + [key])
  }

  mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
    let path = codingPath + [key]
    if let value = value as? Data {
      try context.store(value: .data(value), path: path)
    } else if let value = value as? Date {
      try context.store(value: .date(value), path: path)
    } else {
      try value.encode(to: context.makeValue(path: path))
    }
  }

  mutating func nestedContainer<NestedKey: CodingKey>(
    keyedBy keyType: NestedKey.Type,
    forKey key: Key
  ) -> KeyedEncodingContainer<NestedKey> {
    let path = codingPath + [key]
    try? context.store(value: .dictionary([:]), path: path)
    return context.makeKeyed(path: path)
  }

  mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
    let path = codingPath + [key]
    try? context.store(value: .array([]), path: path)
    return context.makeUnkeyed(path: path)
  }

  mutating func superEncoder() -> Encoder {
    let path = codingPath + [Enigma.Pin.super]
    try? context.store(value: .dictionary([:]), path: path)
    return context.makeValue(path: path)
  }

  mutating func superEncoder(forKey key: Key) -> Encoder {
    let path = codingPath + [key]
    try? context.store(value: .dictionary([:]), path: path)
    return context.makeValue(path: path)
  }
}
