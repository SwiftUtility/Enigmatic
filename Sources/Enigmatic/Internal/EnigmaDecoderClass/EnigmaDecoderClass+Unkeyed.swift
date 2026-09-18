import Foundation

extension EnigmaDecoderClass {
  final class Unkeyed: UnkeyedDecodingContainer, Container {
    let link: Link?
    let userInfo: [CodingUserInfoKey: Any]
    let values: [Enigma]
    var currentIndex = 0

    init(link: Link?, userInfo: [CodingUserInfoKey: Any], values: [Enigma]) {
      self.link = link
      self.userInfo = userInfo
      self.values = values
    }

    var codingPath: [any CodingKey] {
      path()
    }

    var count: Int? {
      values.count
    }

    var isAtEnd: Bool {
      currentIndex >= values.count
    }

    func decodeNil() throws -> Bool {
      guard currentIndex < values.count else { throw valueNotFound(Any?.self) }
      guard values[currentIndex].isNull else { return false }
      currentIndex += 1
      return true
    }

    func decode(_ type: Bool.Type) throws -> Bool {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asBool else { throw typeMismatch(type) }
      currentIndex += 1
      return value
    }

    func decode(_ type: String.Type) throws -> String {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asString else { throw typeMismatch(type) }
      currentIndex += 1
      return value
    }

    func decode(_ type: Double.Type) throws -> Double {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asDouble else { throw typeMismatch(type) }
      currentIndex += 1
      return value
    }

    func decode(_ type: Float.Type) throws -> Float {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asFloat else { throw typeMismatch(type) }
      currentIndex += 1
      return value
    }

    func decode(_ type: Int.Type) throws -> Int {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asInt else { throw typeMismatch(type) }
      currentIndex += 1
      return value
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asInt8 else { throw typeMismatch(type) }
      currentIndex += 1
      return value
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asInt16 else { throw typeMismatch(type) }
      currentIndex += 1
      return value
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asInt32 else { throw typeMismatch(type) }
      currentIndex += 1
      return value
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asInt64 else { throw typeMismatch(type) }
      currentIndex += 1
      return value
    }

    func decode(_ type: UInt.Type) throws -> UInt {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asUInt else { throw typeMismatch(type) }
      currentIndex += 1
      return value
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asUInt8 else { throw typeMismatch(type) }
      currentIndex += 1
      return value
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asUInt16 else { throw typeMismatch(type) }
      currentIndex += 1
      return value
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asUInt32 else { throw typeMismatch(type) }
      currentIndex += 1
      return value
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      guard let value = values[currentIndex].asUInt64 else { throw typeMismatch(type) }
      currentIndex += 1
      return value
    }

    func decode<T: Decodable>(
      _ type: T.Type
    ) throws -> T {
      guard currentIndex < values.count else { throw valueNotFound(type) }
      let value = if type == Data.self, let value = values[currentIndex].asData as? T {
        value
      } else if type == Date.self, let value = values[currentIndex].asDate as? T {
        value
      } else {
        try T(from: Single(
          link: Link(prev: self, key: Enigma.Pin.int(currentIndex)),
          userInfo: userInfo,
          value: values[currentIndex]
        ))
      }
      currentIndex += 1
      return value
    }

    func nestedContainer<NestedKey: CodingKey>(
      keyedBy _: NestedKey.Type
    ) throws -> KeyedDecodingContainer<NestedKey> {
      guard currentIndex < values.count else { throw valueNotFound([String: Enigma].self) }
      guard let values = values[currentIndex].asDictionary else { throw typeMismatch([String: Enigma].self) }
      defer { currentIndex += 1 }
      return KeyedDecodingContainer(Keyed<NestedKey>(
        link: Link(prev: self, key: Enigma.Pin.int(currentIndex)),
        userInfo: userInfo,
        values: values
      ))
    }

    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
      guard currentIndex < values.count else { throw valueNotFound([String: Enigma].self) }
      guard let values = values[currentIndex].asArray else { throw typeMismatch([Enigma].self) }
      defer { currentIndex += 1 }
      return Unkeyed(
        link: Link(prev: self, key: Enigma.Pin.int(currentIndex)),
        userInfo: userInfo,
        values: values
      )
    }

    func superDecoder() throws -> Decoder {
      guard currentIndex < values.count else { throw valueNotFound([String: Enigma].self) }
      defer { currentIndex += 1 }
      return Single(
        link: Link(prev: self, key: Enigma.Pin.int(currentIndex)),
        userInfo: userInfo,
        value: values[currentIndex]
      )
    }

    private func valueNotFound<T>(_ type: T.Type) -> DecodingError {
      DecodingError.valueNotFound(type, DecodingError.Context(
        codingPath: codingPath,
        debugDescription: "Unkeyed container is at end"
      ))
    }

    private func typeMismatch<T>(_ type: T.Type) -> DecodingError {
      DecodingError.typeMismatch(type, DecodingError.Context(
        codingPath: path(key: Enigma.Pin.int(currentIndex)),
        debugDescription: "Expected \(type)"
      ))
    }
  }
}
