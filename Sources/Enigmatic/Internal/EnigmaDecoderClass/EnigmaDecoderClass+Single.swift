import Foundation

extension EnigmaDecoderClass {
  final class Single: Decoder, SingleValueDecodingContainer, Container {
    let link: Link?
    let userInfo: [CodingUserInfoKey: Any]
    let value: Enigma

    init(link: Link?, userInfo: [CodingUserInfoKey: Any], value: Enigma) {
      self.link = link
      self.userInfo = userInfo
      self.value = value
    }

    var codingPath: [any CodingKey] {
      path()
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
      self
    }

    func container<Key: CodingKey>(
      keyedBy _: Key.Type
    ) throws -> KeyedDecodingContainer<Key> {
      guard let values = value.asDictionary else {
        throw DecodingError.typeMismatch([String: Enigma].self, DecodingError.Context(
          codingPath: codingPath,
          debugDescription: "Not dictionary"
        ))
      }
      return KeyedDecodingContainer(Keyed<Key>(link: link, userInfo: userInfo, values: values))
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
      guard let values = value.asArray else {
        throw DecodingError.typeMismatch([Enigma].self, .init(
          codingPath: codingPath,
          debugDescription: "Expected array"
        ))
      }
      return Unkeyed(link: link, userInfo: userInfo, values: values)
    }

    func decodeNil() -> Bool {
      value.isNull
    }

    func decode(_ type: Bool.Type) throws -> Bool {
      guard let result = value.asBool else { throw typeMismatch(type) }
      return result
    }

    func decode(_ type: String.Type) throws -> String {
      guard let result = value.asString else { throw typeMismatch(type) }
      return result
    }

    func decode(_ type: Double.Type) throws -> Double {
      guard let result = value.asDouble else { throw typeMismatch(type) }
      return result
    }

    func decode(_ type: Float.Type) throws -> Float {
      guard let result = value.asFloat else { throw typeMismatch(type) }
      return result
    }

    func decode(_ type: Int.Type) throws -> Int {
      guard let result = value.asInt else { throw typeMismatch(type) }
      return result
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
      guard let result = value.asInt8 else { throw typeMismatch(type) }
      return result
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
      guard let result = value.asInt16 else { throw typeMismatch(type) }
      return result
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
      guard let result = value.asInt32 else { throw typeMismatch(type) }
      return result
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
      guard let result = value.asInt64 else { throw typeMismatch(type) }
      return result
    }

    func decode(_ type: UInt.Type) throws -> UInt {
      guard let result = value.asUInt else { throw typeMismatch(type) }
      return result
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
      guard let result = value.asUInt8 else { throw typeMismatch(type) }
      return result
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
      guard let result = value.asUInt16 else { throw typeMismatch(type) }
      return result
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
      guard let result = value.asUInt32 else { throw typeMismatch(type) }
      return result
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
      guard let result = value.asUInt64 else { throw typeMismatch(type) }
      return result
    }

    func decode<T: Decodable>(_ type: T.Type) throws -> T {
      if type == Data.self, let result = value.asData as? T {
        result
      } else if type == Date.self, let result = value.asDate as? T {
        result
      } else {
        try T(from: self)
      }
    }

    private func typeMismatch<T>(_ type: T.Type) -> DecodingError {
      .typeMismatch(type, DecodingError.Context(
        codingPath: codingPath,
        debugDescription: "Expected \(type)"
      ))
    }

    static func decoder(enigma: Enigma, userInfo: [CodingUserInfoKey : Any]) -> Single {
      Single(link: nil, userInfo: userInfo, value: enigma)
    }
  }
}
