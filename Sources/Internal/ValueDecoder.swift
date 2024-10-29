import Foundation

struct ValueDecoder: Sendable, Decoder, SingleValueDecodingContainer {
  let enigma: Enigma
  let codingPath: [CodingKey]

  var userInfo: [CodingUserInfoKey: Any] { [:] }

  func singleValueContainer() throws -> SingleValueDecodingContainer { self }

  func unkeyedContainer() throws -> UnkeyedDecodingContainer {
    try enigma.makeUnkeyed(path: codingPath)
  }

  func container<Key: CodingKey>(keyedBy _: Key.Type) throws -> KeyedDecodingContainer<Key> {
    try enigma.makeKeyed(path: codingPath)
  }

  func decodeNil() -> Bool { enigma.isNull }

  func decode(_: Bool.Type) throws -> Bool {
    try enigma.makeBool(path: codingPath)
  }

  func decode(_: Int.Type) throws -> Int {
    try enigma.makeInt(path: codingPath)
  }

  func decode(_: Int64.Type) throws -> Int64 {
    try enigma.makeInt64(path: codingPath)
  }

  func decode(_: Int32.Type) throws -> Int32 {
    try enigma.makeInt32(path: codingPath)
  }

  func decode(_: Int16.Type) throws -> Int16 {
    try enigma.makeInt16(path: codingPath)
  }

  func decode(_: Int8.Type) throws -> Int8 {
    try enigma.makeInt8(path: codingPath)
  }

  func decode(_: UInt.Type) throws -> UInt {
    try enigma.makeUInt(path: codingPath)
  }

  func decode(_: UInt64.Type) throws -> UInt64 {
    try enigma.makeUInt64(path: codingPath)
  }

  func decode(_: UInt32.Type) throws -> UInt32 {
    try enigma.makeUInt32(path: codingPath)
  }

  func decode(_: UInt16.Type) throws -> UInt16 {
    try enigma.makeUInt16(path: codingPath)
  }

  func decode(_: UInt8.Type) throws -> UInt8 {
    try enigma.makeUInt8(path: codingPath)
  }

  func decode(_: Double.Type) throws -> Double {
    try enigma.makeDouble(path: codingPath)
  }

  func decode(_: Float.Type) throws -> Float {
    try enigma.makeFloat(path: codingPath)
  }

  func decode(_: String.Type) throws -> String {
    try enigma.makeString(path: codingPath)
  }

  func decode<T: Decodable>(_: T.Type) throws -> T {
    if T.self == Data.self, let value = enigma.asData as? T { return value }
    else if T.self == Date.self, let value = enigma.asDate as? T { return value }
    else if T.self == Enigma.self, let value = enigma as? T { return value }
    else { return try T(from: self) }
  }
}
