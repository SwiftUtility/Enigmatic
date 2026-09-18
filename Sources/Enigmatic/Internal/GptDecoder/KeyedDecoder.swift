import Foundation

struct KeyedDecoder<Key: CodingKey>: KeyedDecodingContainerProtocol {
  let values: [String: Enigma]
  let path: CodingPathNode?

  var codingPath: [CodingKey] {
    makeCodingPath(path)
  }

  var allKeys: [Key] {
    var result: [Key] = []
    result.reserveCapacity(values.count)

    for key in values.keys {
      if let key = Key(stringValue: key) {
        result.append(key)
      }
    }

    return result
  }

  func contains(_ key: Key) -> Bool {
    values[key.stringValue] != nil
  }

  func decodeNil(forKey key: Key) throws -> Bool {
    guard let value = values[key.stringValue] else {
      return false
    }
    return value.isNull
  }

  func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
    try scalar(type, forKey: key, extract: \.asBool)
  }

  func decode(_ type: String.Type, forKey key: Key) throws -> String {
    try scalar(type, forKey: key, extract: \.asString)
  }

  func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
    try scalar(type, forKey: key, extract: \.asDouble)
  }

  func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
    try scalar(type, forKey: key, extract: \.asFloat)
  }

  func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
    try scalar(type, forKey: key, extract: \.asInt)
  }

  func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
    try scalar(type, forKey: key, extract: \.asInt8)
  }

  func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
    try scalar(type, forKey: key, extract: \.asInt16)
  }

  func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
    try scalar(type, forKey: key, extract: \.asInt32)
  }

  func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
    try scalar(type, forKey: key, extract: \.asInt64)
  }

  func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
    try scalar(type, forKey: key, extract: \.asUInt)
  }

  func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
    try scalar(type, forKey: key, extract: \.asUInt8)
  }

  func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
    try scalar(type, forKey: key, extract: \.asUInt16)
  }

  func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
    try scalar(type, forKey: key, extract: \.asUInt32)
  }

  func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
    try scalar(type, forKey: key, extract: \.asUInt64)
  }

  func decode<T: Decodable>(
    _ type: T.Type,
    forKey key: Key
  ) throws -> T {
    let value = try value(forKey: key)

    if type == Data.self, let result = value.asData as? T {
      return result
    } else if type == Date.self, let result = value.asDate as? T {
      return result
    } else {
      return try T(from: ValueDecoder(value: value, path: CodingPathNode(parent: path, key: key)))
    }
  }

  func nestedContainer<NestedKey: CodingKey>(
    keyedBy _: NestedKey.Type,
    forKey key: Key
  ) throws -> KeyedDecodingContainer<NestedKey> {
    let value = try value(forKey: key)

    guard let values = value.asDictionary else {
      throw DecodingError.typeMismatch(
        [String: Enigma].self,
        .init(
          codingPath: makeCodingPath(path, appending: key),
          debugDescription: "Expected dictionary"
        )
      )
    }

    return KeyedDecodingContainer(
      KeyedDecoder<NestedKey>(
        values: values,
        path: CodingPathNode(parent: path, key: key)
      )
    )
  }

  func nestedUnkeyedContainer(
    forKey key: Key
  ) throws -> UnkeyedDecodingContainer {
    let value = try value(forKey: key)

    guard let values = value.asArray else {
      throw DecodingError.typeMismatch(
        [Enigma].self,
        .init(
          codingPath: makeCodingPath(path, appending: key),
          debugDescription: "Expected array"
        )
      )
    }

    return UnkeyedDecoder(
      values: values,
      path: CodingPathNode(parent: path, key: key)
    )
  }

  func superDecoder() throws -> Decoder {
    let key = Enigma.Pin.super
    let value = try value(forKey: key)

    return ValueDecoder(
      value: value,
      path: CodingPathNode(parent: path, key: key)
    )
  }

  func superDecoder(
    forKey key: Key
  ) throws -> Decoder {
    let value = try value(forKey: key)

    return ValueDecoder(
      value: value,
      path: CodingPathNode(parent: path, key: key)
    )
  }

  @inline(__always)
  private func scalar<T>(
    _ type: T.Type,
    forKey key: Key,
    extract: KeyPath<Enigma, T?>
  ) throws -> T {
    guard let value = values[key.stringValue] else {
      throw keyNotFound(key)
    }

    if let result = value[keyPath: extract] {
      return result
    }

    throw DecodingError.typeMismatch(
      type,
      .init(
        codingPath: makeCodingPath(path, appending: key),
        debugDescription: "Expected \(type)"
      )
    )
  }

  @inline(__always)
  private func value(
    forKey key: Key
  ) throws -> Enigma {
    guard let value = values[key.stringValue] else {
      throw keyNotFound(key)
    }

    return value
  }

  @inline(__always)
  private func value<K: CodingKey>(
    forKey key: K
  ) throws -> Enigma {
    guard let value = values[key.stringValue] else {
      throw DecodingError.keyNotFound(
        key,
        .init(
          codingPath: codingPath,
          debugDescription: "Key not found"
        )
      )
    }

    return value
  }

  private func keyNotFound(_ key: Key) -> DecodingError {
    .keyNotFound(
      key,
      .init(
        codingPath: codingPath,
        debugDescription: "Key not found"
      )
    )
  }
}
