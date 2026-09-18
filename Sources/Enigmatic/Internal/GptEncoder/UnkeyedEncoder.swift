import Foundation

struct UnkeyedEncoder: UnkeyedEncodingContainer {
  let context: EncoderContext
  let entry: EncoderContext.EntryID

  var codingPath: [CodingKey] {
    context.codingPath(for: entry)
  }

  var count: Int {
    context.unkeyedCount(at: entry)
  }

  mutating func encodeNil() throws {
    try append(.null)
  }

  mutating func encode(_ value: Bool) throws {
    try append(.bool(value))
  }

  mutating func encode(_ value: String) throws {
    try append(.string(value))
  }

  mutating func encode(_ value: Double) throws {
    try append(.double(value))
  }

  mutating func encode(_ value: Float) throws {
    try append(.float(value))
  }

  mutating func encode(_ value: Int) throws {
    try append(.int(value))
  }

  mutating func encode(_ value: Int8) throws {
    try append(.int8(value))
  }

  mutating func encode(_ value: Int16) throws {
    try append(.int16(value))
  }

  mutating func encode(_ value: Int32) throws {
    try append(.int32(value))
  }

  mutating func encode(_ value: Int64) throws {
    try append(.int64(value))
  }

  mutating func encode(_ value: UInt) throws {
    try append(.uint(value))
  }

  mutating func encode(_ value: UInt8) throws {
    try append(.uint8(value))
  }

  mutating func encode(_ value: UInt16) throws {
    try append(.uint16(value))
  }

  mutating func encode(_ value: UInt32) throws {
    try append(.uint32(value))
  }

  mutating func encode(_ value: UInt64) throws {
    try append(.uint64(value))
  }

  mutating func encode<T: Encodable>(_ value: T) throws {
    let child = try context.appendUnkeyedChild(at: entry)
    if try !context.encodeSpecial(value, at: child) {
      try value.encode(to: context.makeValue(at: child))
    }
  }

  mutating func nestedContainer<Key: CodingKey>(
    keyedBy _: Key.Type
  ) -> KeyedEncodingContainer<Key> {
    let child = context.appendKeyedChildForEncoder(at: entry)
    return context.makeKeyed(at: child)
  }

  mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
    let child = context.appendUnkeyedChildForEncoder(at: entry)
    return context.makeUnkeyed(at: child)
  }

  mutating func superEncoder() -> Encoder {
    let child = context.appendChildForEncoder(at: entry)
    return context.makeValue(at: child)
  }

  private mutating func append(_ value: Enigma) throws {
    let child = try context.appendUnkeyedChild(at: entry)
    try context.store(value, at: child)
  }
}
