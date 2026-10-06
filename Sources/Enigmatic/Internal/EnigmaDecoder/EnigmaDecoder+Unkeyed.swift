import Foundation

extension EnigmaDecoder {
  struct Unkeyed: UnkeyedDecodingContainer {
    let state: EnigmaDecoder
    let values: [Enigma]
    let pathId: Int

    var currentIndex = 0

    var codingPath: [any CodingKey] {
      state.path(pathId: pathId)
    }

    var count: Int? {
      values.count
    }

    var isAtEnd: Bool {
      currentIndex >= values.count
    }

    private var path: [any CodingKey] {
      state.path(pathId: pathId, key: Enigma.Pin.int(currentIndex))
    }

    mutating func decodeNil() throws -> Bool {
      guard currentIndex < values.count else { throw valueNotFound(Any?.self) }
      guard values[currentIndex].isNull else { return false }
      currentIndex += 1
      return true
    }

    mutating func decode(_ type: Bool.Type) throws -> Bool {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asBool else {
        throw values[currentIndex].decodingError(path, type: type)
      }
      currentIndex += 1
      return value
    }

    mutating func decode(_ type: String.Type) throws -> String {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asString else {
        throw values[currentIndex].decodingError(path, type: type)
      }
      currentIndex += 1
      return value
    }

    mutating func decode(_ type: Double.Type) throws -> Double {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asDouble else {
        throw values[currentIndex].decodingError(path, type: type)
      }
      currentIndex += 1
      return value
    }

    mutating func decode(_ type: Float.Type) throws -> Float {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asFloat else {
        throw values[currentIndex].decodingError(path, type: type)
      }
      currentIndex += 1
      return value
    }

    mutating func decode(_ type: Int.Type) throws -> Int {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asInt else {
        throw values[currentIndex].decodingError(path, type: type)
      }
      currentIndex += 1
      return value
    }

    mutating func decode(_ type: Int8.Type) throws -> Int8 {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asInt8 else {
        throw values[currentIndex].decodingError(path, type: type)
      }
      currentIndex += 1
      return value
    }

    mutating func decode(_ type: Int16.Type) throws -> Int16 {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asInt16 else {
        throw values[currentIndex].decodingError(path, type: type)
      }
      currentIndex += 1
      return value
    }

    mutating func decode(_ type: Int32.Type) throws -> Int32 {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asInt32 else {
        throw values[currentIndex].decodingError(path, type: type)
      }
      currentIndex += 1
      return value
    }

    mutating func decode(_ type: Int64.Type) throws -> Int64 {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asInt64 else {
        throw values[currentIndex].decodingError(path, type: type)
      }
      currentIndex += 1
      return value
    }

    mutating func decode(_ type: UInt.Type) throws -> UInt {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asUInt else {
        throw values[currentIndex].decodingError(path, type: type)
      }
      currentIndex += 1
      return value
    }

    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asUInt8 else {
        throw values[currentIndex].decodingError(path, type: type)
      }
      currentIndex += 1
      return value
    }

    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asUInt16 else {
        throw values[currentIndex].decodingError(path, type: type)
      }
      currentIndex += 1
      return value
    }

    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asUInt32 else {
        throw values[currentIndex].decodingError(path, type: type)
      }
      currentIndex += 1
      return value
    }

    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asUInt64 else {
        throw values[currentIndex].decodingError(path, type: type)
      }
      currentIndex += 1
      return value
    }

    @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
    mutating func decode(_ type: Int128.Type) throws -> Int128 {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asInt128 else {
        throw values[currentIndex].decodingError(path, type: type)
      }
      currentIndex += 1
      return value
    }

    @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
    mutating func decode(_ type: UInt128.Type) throws -> UInt128 {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asUInt128 else {
        throw values[currentIndex].decodingError(path, type: type)
      }
      currentIndex += 1
      return value
    }

    mutating func decode<T: Decodable>(
      _ type: T.Type
    ) throws -> T {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      let value = if type == Data.self, let value = values[currentIndex].asData as? T {
        value
      } else if type == Date.self, let value = values[currentIndex].asDate as? T {
        value
      } else {
        try T(from: Single(
          state: state,
          value: values[currentIndex],
          pathId: state.nested(pathId: pathId, key: Enigma.Pin.int(currentIndex))
        ))
      }
      currentIndex += 1
      return value
    }

    mutating func nestedContainer<NestedKey: CodingKey>(
      keyedBy _: NestedKey.Type
    ) throws -> KeyedDecodingContainer<NestedKey> {
      guard currentIndex < values.count else { throw valueNotFound([String: Enigma].self) }
      guard let values = values[currentIndex].asDictionary else {
        throw values[currentIndex].decodingError(path, type: [String: Enigma].self)
      }
      defer { currentIndex += 1 }
      return KeyedDecodingContainer(Keyed<NestedKey>(
        state: state,
        values: values,
        pathId: state.nested(pathId: pathId, key: Enigma.Pin.int(currentIndex))
      ))
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
      guard currentIndex < values.count else { throw valueNotFound([Enigma].self) }
      guard let values = values[currentIndex].asArray else {
        throw values[currentIndex].decodingError(path, type: [Enigma].self)
      }
      defer { currentIndex += 1 }
      return Unkeyed(
        state: state,
        values: values,
        pathId: state.nested(pathId: pathId, key: Enigma.Pin.int(currentIndex))
      )
    }

    mutating func superDecoder() throws -> Decoder {
      guard currentIndex < values.count else { throw valueNotFound(Decoder.self) }
      defer { currentIndex += 1 }
      return Single(
        state: state,
        value: values[currentIndex],
        pathId: state.nested(pathId: pathId, key: Enigma.Pin.int(currentIndex))
      )
    }

    private func valueNotFound<T>(_ type: T.Type) -> DecodingError {
      DecodingError.valueNotFound(type, DecodingError.Context(
        codingPath: codingPath,
        debugDescription: "Unkeyed container is at end"
      ))
    }
  }
}
