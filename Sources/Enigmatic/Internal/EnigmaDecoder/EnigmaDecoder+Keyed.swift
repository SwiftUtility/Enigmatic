import Foundation

extension EnigmaDecoder {
  struct Keyed<Key: CodingKey>: KeyedDecodingContainerProtocol {
    let state: State
    let values: [String: Enigma]
    let pathId: Int

    var codingPath: [CodingKey] {
      state.path(pathId: pathId)
    }

    var allKeys: [Key] {
      var result: [Key] = []
      result.reserveCapacity(values.count)
      for key in values.keys {
        guard let key = Key(stringValue: key) else { continue }
        result.append(key)
      }
      return result
    }

    func contains(_ key: Key) -> Bool {
      values[key.stringValue] != nil
    }

    func decodeNil(forKey key: Key) throws -> Bool {
      guard let value = values[key.stringValue] else { return false }
      return value.isNull
    }

    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
      guard let value = values[key.stringValue] else { throw keyNotFound(key) }
      guard let value = value.asBool else { throw typeMismatch(key, type: type) }
      return value
    }

    func decode(_ type: String.Type, forKey key: Key) throws -> String {
      guard let value = values[key.stringValue] else { throw keyNotFound(key) }
      guard let value = value.asString else { throw typeMismatch(key, type: type) }
      return value
    }

    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
      guard let value = values[key.stringValue] else { throw keyNotFound(key) }
      guard let value = value.asDouble else { throw typeMismatch(key, type: type) }
      return value
    }

    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
      guard let value = values[key.stringValue] else { throw keyNotFound(key) }
      guard let value = value.asFloat else { throw typeMismatch(key, type: type) }
      return value
    }

    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
      guard let value = values[key.stringValue] else { throw keyNotFound(key) }
      guard let value = value.asInt else { throw typeMismatch(key, type: type) }
      return value
    }

    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
      guard let value = values[key.stringValue] else { throw keyNotFound(key) }
      guard let value = value.asInt8 else { throw typeMismatch(key, type: type) }
      return value
    }

    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
      guard let value = values[key.stringValue] else { throw keyNotFound(key) }
      guard let value = value.asInt16 else { throw typeMismatch(key, type: type) }
      return value
    }

    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
      guard let value = values[key.stringValue] else { throw keyNotFound(key) }
      guard let value = value.asInt32 else { throw typeMismatch(key, type: type) }
      return value
    }

    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
      guard let value = values[key.stringValue] else { throw keyNotFound(key) }
      guard let value = value.asInt64 else { throw typeMismatch(key, type: type) }
      return value
    }

    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
      guard let value = values[key.stringValue] else { throw keyNotFound(key) }
      guard let value = value.asUInt else { throw typeMismatch(key, type: type) }
      return value
    }

    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
      guard let value = values[key.stringValue] else { throw keyNotFound(key) }
      guard let value = value.asUInt8 else { throw typeMismatch(key, type: type) }
      return value
    }

    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
      guard let value = values[key.stringValue] else { throw keyNotFound(key) }
      guard let value = value.asUInt16 else { throw typeMismatch(key, type: type) }
      return value
    }

    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
      guard let value = values[key.stringValue] else { throw keyNotFound(key) }
      guard let value = value.asUInt32 else { throw typeMismatch(key, type: type) }
      return value
    }

    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
      guard let value = values[key.stringValue] else { throw keyNotFound(key) }
      guard let value = value.asUInt64 else { throw typeMismatch(key, type: type) }
      return value
    }

    func decode<T: Decodable>(
      _ type: T.Type,
      forKey key: Key
    ) throws -> T {
      guard let value = values[key.stringValue] else { throw keyNotFound(key) }
      return if type == Data.self, let result = value.asData as? T {
        result
      } else if type == Date.self, let result = value.asDate as? T {
        result
      } else {
        try T(from: Single(state: state, value: value, pathId: state.nested(pathId: pathId, key: key)))
      }
    }

    func nestedContainer<NestedKey: CodingKey>(
      keyedBy _: NestedKey.Type,
      forKey key: Key
    ) throws -> KeyedDecodingContainer<NestedKey> {
      guard let value = values[key.stringValue] else { throw keyNotFound(key) }
      guard let value = value.asDictionary else { throw typeMismatch(key, type: [String: Enigma].self) }
      return KeyedDecodingContainer(Keyed<NestedKey>(
        state: state, values: value, pathId: state.nested(pathId: pathId, key: key)
      ))
    }

    func nestedUnkeyedContainer(
      forKey key: Key
    ) throws -> UnkeyedDecodingContainer {
      guard let value = values[key.stringValue] else { throw keyNotFound(key) }
      guard let value = value.asArray else { throw typeMismatch(key, type: [Enigma].self) }
      return Unkeyed(state: state, values: value, pathId: state.nested(pathId: pathId, key: key))
    }

    func superDecoder() throws -> Decoder {
      let key = Enigma.Pin.super
      guard let value = values[key.stringValue] else { throw keyNotFound(key) }
      return Single(state: state, value: value, pathId: state.nested(pathId: pathId, key: key))
    }

    func superDecoder(
      forKey key: Key
    ) throws -> Decoder {
      guard let value = values[key.stringValue] else { throw keyNotFound(key) }
      return Single(state: state, value: value, pathId: state.nested(pathId: pathId, key: key))
    }

    private func keyNotFound(_ key: some CodingKey) -> DecodingError {
      DecodingError.keyNotFound(key, DecodingError.Context(
        codingPath: codingPath,
        debugDescription: "Key not found"
      ))
    }

    private func typeMismatch(_ key: Key, type: Any.Type) -> DecodingError {
      DecodingError.typeMismatch(type, .init(
        codingPath: state.path(pathId: pathId, key: key),
        debugDescription: "Expected \(type)"
      ))
    }
  }
}
