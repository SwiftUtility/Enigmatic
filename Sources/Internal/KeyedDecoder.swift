import Foundation

struct KeyedDecoder<Key: CodingKey>: Sendable, KeyedDecodingContainerProtocol {
  let enigmas: [String: Enigma]
  let codingPath: [CodingKey]

  var allKeys: [Key] { enigmas.keys.compactMap(Key.init(stringValue:)) }

  func contains(_ key: Key) -> Bool { enigmas[key.stringValue] != nil }

  func decodeNil(forKey key: Key) throws -> Bool {
    enigmas[key.stringValue]?.isNull ?? true
  }

  func decode(_: Bool.Type, forKey key: Key) throws -> Bool {
    try value(key).makeBool(path: codingPath + [key])
  }

  func decode(_: Int.Type, forKey key: Key) throws -> Int {
    try value(key).makeInt(path: codingPath + [key])
  }

  func decode(_: Int64.Type, forKey key: Key) throws -> Int64 {
    try value(key).makeInt64(path: codingPath + [key])
  }

  func decode(_: Int32.Type, forKey key: Key) throws -> Int32 {
    try value(key).makeInt32(path: codingPath + [key])
  }

  func decode(_: Int16.Type, forKey key: Key) throws -> Int16 {
    try value(key).makeInt16(path: codingPath + [key])
  }

  func decode(_: Int8.Type, forKey key: Key) throws -> Int8 {
    try value(key).makeInt8(path: codingPath + [key])
  }

  func decode(_: UInt.Type, forKey key: Key) throws -> UInt {
    try value(key).makeUInt(path: codingPath + [key])
  }

  func decode(_: UInt64.Type, forKey key: Key) throws -> UInt64 {
    try value(key).makeUInt64(path: codingPath + [key])
  }

  func decode(_: UInt32.Type, forKey key: Key) throws -> UInt32 {
    try value(key).makeUInt32(path: codingPath + [key])
  }

  func decode(_: UInt16.Type, forKey key: Key) throws -> UInt16 {
    try value(key).makeUInt16(path: codingPath + [key])
  }

  func decode(_: UInt8.Type, forKey key: Key) throws -> UInt8 {
    try value(key).makeUInt8(path: codingPath + [key])
  }

  func decode(_: Double.Type, forKey key: Key) throws -> Double {
    try value(key).makeDouble(path: codingPath + [key])
  }

  func decode(_: Float.Type, forKey key: Key) throws -> Float {
    try value(key).makeFloat(path: codingPath + [key])
  }

  func decode(_: String.Type, forKey key: Key) throws -> String {
    try value(key).makeString(path: codingPath + [key])
  }

  func decode<T: Decodable>(_: T.Type, forKey key: Key) throws -> T {
    let value = try value(key)
    return if T.self == Data.self, let value = value.asData as? T { value }
    else if T.self == Date.self, let value = value.asDate as? T { value }
    else if T.self == Enigma.self, let value = value as? T { value }
    else { try T(from: value.makeValue(path: codingPath + [key])) }
  }

  func nestedContainer<NestedKey: CodingKey>(
    keyedBy _: NestedKey.Type,
    forKey key: Key
  ) throws -> KeyedDecodingContainer<NestedKey> {
    try value(key).makeKeyed(path: codingPath + [key])
  }

  func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
    try value(key).makeUnkeyed(path: codingPath + [key])
  }

  func superDecoder() throws -> Decoder {
    if let key = Key(stringValue: "super") {
      try superDecoder(forKey: key)
    } else {
      try value(CommonKey.super).makeValue(path: codingPath + [CommonKey.super])
    }
  }

  func superDecoder(forKey key: Key) throws -> Decoder {
    try value(key).makeValue(path: codingPath + [key])
  }

  func value<K: CodingKey>(_ key: K) throws -> Enigma {
    guard let value = enigmas[key.stringValue] else {
      throw DecodingError.keyNotFound(key, DecodingError.Context(
        codingPath: codingPath + [key],
        debugDescription: "Key not found in: \(Enigma.dictionary(enigmas).debugDescription)"
      ))
    }
    return value
  }
}
