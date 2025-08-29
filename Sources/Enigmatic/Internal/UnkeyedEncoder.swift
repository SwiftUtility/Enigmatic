import Foundation

struct UnkeyedEncoder: UnkeyedEncodingContainer {
  let context: EncoderContext
  let codingPath: [CodingKey]
  var count: Int = 0

  var key: Enigma.Pin {
    .int(count)
  }

  mutating func encodeNil() throws {
    try context.store(value: .null, path: codingPath + [key])
    count += 1
  }

  mutating func encode(_ value: Bool) throws {
    try context.store(value: .bool(value), path: codingPath + [key])
    count += 1
  }

  mutating func encode(_ value: String) throws {
    try context.store(value: .string(value), path: codingPath + [key])
    count += 1
  }

  mutating func encode(_ value: Double) throws {
    try context.store(value: .double(value), path: codingPath + [key])
    count += 1
  }

  mutating func encode(_ value: Float) throws {
    try context.store(value: .float(value), path: codingPath + [key])
    count += 1
  }

  mutating func encode(_ value: Int) throws {
    try context.store(value: .int(value), path: codingPath + [key])
    count += 1
  }

  mutating func encode(_ value: Int8) throws {
    try context.store(value: .int8(value), path: codingPath + [key])
    count += 1
  }

  mutating func encode(_ value: Int16) throws {
    try context.store(value: .int16(value), path: codingPath + [key])
    count += 1
  }

  mutating func encode(_ value: Int32) throws {
    try context.store(value: .int32(value), path: codingPath + [key])
    count += 1
  }

  mutating func encode(_ value: Int64) throws {
    try context.store(value: .int64(value), path: codingPath + [key])
    count += 1
  }

  mutating func encode(_ value: UInt) throws {
    try context.store(value: .uint(value), path: codingPath + [key])
    count += 1
  }

  mutating func encode(_ value: UInt8) throws {
    try context.store(value: .uint8(value), path: codingPath + [key])
    count += 1
  }

  mutating func encode(_ value: UInt16) throws {
    try context.store(value: .uint16(value), path: codingPath + [key])
    count += 1
  }

  mutating func encode(_ value: UInt32) throws {
    try context.store(value: .uint32(value), path: codingPath + [key])
    count += 1
  }

  mutating func encode(_ value: UInt64) throws {
    try context.store(value: .uint64(value), path: codingPath + [key])
    count += 1
  }

  mutating func encode<T: Encodable>(_ value: T) throws {
    if let value = value as? Data {
      try context.store(value: .data(value), path: codingPath + [key])
    } else if let value = value as? Date {
      try context.store(value: .date(value), path: codingPath + [key])
    } else {
      try value.encode(to: context.makeValue(path: codingPath + [key]))
    }
    count += 1
  }

  mutating func nestedContainer<Key: CodingKey>(
    keyedBy _: Key.Type
  ) -> KeyedEncodingContainer<Key> {
    let path = codingPath + [key]
    try? context.store(value: .dictionary([:]), path: path)
    defer { count += 1 }
    return context.makeKeyed(path: path)
  }

  mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
    let path = codingPath + [key]
    try? context.store(value: .array([]), path: path)
    defer { count += 1 }
    return context.makeUnkeyed(path: path)
  }

  mutating func superEncoder() -> Encoder {
    let path = codingPath + [key]
    try? context.store(value: .dictionary([:]), path: path)
    defer { count += 1 }
    return context.makeValue(path: path)
  }
}
