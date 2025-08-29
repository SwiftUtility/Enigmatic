import Foundation

struct UnkeyedDecoder: Sendable, UnkeyedDecodingContainer {
  let enigmas: [Enigma]
  let codingPath: [CodingKey]
  var currentIndex: Int = 0

  var count: Int? {
    enigmas.count
  }

  var isAtEnd: Bool {
    currentIndex >= enigmas.count
  }

  var key: Enigma.Pin {
    .int(currentIndex)
  }

  var value: Enigma {
    get throws {
      guard currentIndex < enigmas.count else {
        throw DecodingError.dataCorrupted(DecodingError.Context(
          codingPath: codingPath + [key],
          debugDescription: "index out of range"
        ))
      }
      return enigmas[currentIndex]
    }
  }

  mutating func decodeNil() throws -> Bool {
    guard try value.isNull else { return false }
    currentIndex += 1
    return true
  }

  mutating func decode(_: Bool.Type) throws -> Bool {
    try extract(make: value.makeBool(path:))
  }

  mutating func decode(_: Int.Type) throws -> Int {
    try extract(make: value.makeInt(path:))
  }

  mutating func decode(_: Int64.Type) throws -> Int64 {
    try extract(make: value.makeInt64(path:))
  }

  mutating func decode(_: Int32.Type) throws -> Int32 {
    try extract(make: value.makeInt32(path:))
  }

  mutating func decode(_: Int16.Type) throws -> Int16 {
    try extract(make: value.makeInt16(path:))
  }

  mutating func decode(_: Int8.Type) throws -> Int8 {
    try extract(make: value.makeInt8(path:))
  }

  mutating func decode(_: UInt.Type) throws -> UInt {
    try extract(make: value.makeUInt(path:))
  }

  mutating func decode(_: UInt64.Type) throws -> UInt64 {
    try extract(make: value.makeUInt64(path:))
  }

  mutating func decode(_: UInt32.Type) throws -> UInt32 {
    try extract(make: value.makeUInt32(path:))
  }

  mutating func decode(_: UInt16.Type) throws -> UInt16 {
    try extract(make: value.makeUInt16(path:))
  }

  mutating func decode(_: UInt8.Type) throws -> UInt8 {
    try extract(make: value.makeUInt8(path:))
  }

  mutating func decode(_: Double.Type) throws -> Double {
    try extract(make: value.makeDouble(path:))
  }

  mutating func decode(_: Float.Type) throws -> Float {
    try extract(make: value.makeFloat(path:))
  }

  mutating func decode(_: String.Type) throws -> String {
    try extract(make: value.makeString(path:))
  }

  mutating func decode<T: Decodable>(_: T.Type) throws -> T {
    let value = try value
    let result: T
    if T.self == Data.self, let value = value.asData as? T {
      result = value
    } else if T.self == Date.self, let value = value.asDate as? T {
      result = value
    } else if T.self == Enigma.self, let value = value as? T {
      result = value
    } else {
      result = try T(from: value.makeValue(path: codingPath + [key]))
    }
    currentIndex += 1
    return result
  }

  mutating func nestedContainer<NestedKey: CodingKey>(
    keyedBy _: NestedKey.Type
  ) throws -> KeyedDecodingContainer<NestedKey> {
    let result = try value.makeKeyed(path: codingPath + [key]) as KeyedDecodingContainer<NestedKey>
    currentIndex += 1
    return result
  }

  mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
    let result = try value.makeUnkeyed(path: codingPath + [key])
    currentIndex += 1
    return result
  }

  mutating func superDecoder() throws -> Decoder {
    let result = try value.makeValue(path: codingPath + [key])
    currentIndex += 1
    return result
  }

  mutating func extract<T: Decodable>(make: ([CodingKey]) throws -> T) throws -> T {
    let result = try make(codingPath + [key])
    currentIndex += 1
    return result
  }
}
