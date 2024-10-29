import Foundation

extension Enigma {
  init(any: Any?, path: [CommonKey]) throws {
    if any == nil || any is NSNull {
      self = .null
    } else if let value = any as? [AnyHashable: Any?] {
      var dictionary: [String: Enigma] = [:]
      for (key, value) in value {
        let key = key.description
        try dictionary[key] = Self(any: value, path: path + [CommonKey.key(key)])
      }
      self = .dictionary(dictionary)
    } else if let value = any as? [Any?] {
      var array: [Self] = []
      for (index, value) in value.enumerated() {
        try array.append(Self(any: value, path: path + [CommonKey.index(index)]))
      }
      self = .array(array)
    } else if let value = any as? Data {
      self = .data(value)
    } else if let value = any as? Date {
      self = .date(value)
    } else if let value = any as? String {
      self = .string(value)
    } else if let value = any as? Bool {
      self = .bool(value)
    } else if let value = any as? NSNumber {
      if let value = UInt8(exactly: value) {
        self = .uint8(value)
      } else if let value = Int8(exactly: value) {
        self = .int8(value)
      } else if let value = UInt16(exactly: value) {
        self = .uint16(value)
      } else if let value = Int16(exactly: value) {
        self = .int16(value)
      } else if let value = UInt32(exactly: value) {
        self = .uint32(value)
      } else if let value = Int32(exactly: value) {
        self = .int32(value)
      } else if let value = UInt64(exactly: value) {
        self = .uint64(value)
      } else if let value = Int64(exactly: value) {
        self = .int64(value)
      } else if let value = UInt(exactly: value) {
        self = .uint(value)
      } else if let value = Int(exactly: value) {
        self = .int(value)
      } else if let value = Float(exactly: value) {
        self = .float(value)
      } else if let value = Double(exactly: value) {
        self = .double(value)
      } else {
        throw DecodingError.dataCorrupted(DecodingError.Context(
          codingPath: path,
          debugDescription: "NSNumber not either Int nor UInt nor Float nor Double"
        ))
      }
    } else {
      throw DecodingError.dataCorrupted(DecodingError.Context(
        codingPath: path,
        debugDescription: "Neither value nor array nor dictionary"
      ))
    }
  }

  func makeKeyed<K: CodingKey>(path: [CodingKey]) throws -> KeyedDecodingContainer<K> {
    let enigmas = try extract(path: path, make: \.asDictionary)
    return KeyedDecodingContainer(KeyedDecoder<K>(enigmas: enigmas, codingPath: path))
  }

  func makeUnkeyed(path: [CodingKey]) throws -> UnkeyedDecoder {
    let enigmas = try extract(path: path, make: \.asArray)
    return UnkeyedDecoder(enigmas: enigmas, codingPath: path)
  }

  func makeValue(path: [CodingKey]) throws -> ValueDecoder {
    return ValueDecoder(enigma: self, codingPath: path)
  }

  func makeBool(path: [CodingKey]) throws -> Bool {
    return try extract(path: path, make: \.asBool)
  }

  func makeInt(path: [CodingKey]) throws -> Int {
    return try extract(path: path, make: \.asInt)
  }

  func makeInt8(path: [CodingKey]) throws -> Int8 {
    return try extract(path: path, make: \.asInt8)
  }

  func makeInt16(path: [CodingKey]) throws -> Int16 {
    return try extract(path: path, make: \.asInt16)
  }

  func makeInt32(path: [CodingKey]) throws -> Int32 {
    return try extract(path: path, make: \.asInt32)
  }

  func makeInt64(path: [CodingKey]) throws -> Int64 {
    return try extract(path: path, make: \.asInt64)
  }

  func makeUInt(path: [CodingKey]) throws -> UInt {
    return try extract(path: path, make: \.asUInt)
  }

  func makeUInt8(path: [CodingKey]) throws -> UInt8 {
    return try extract(path: path, make: \.asUInt8)
  }

  func makeUInt16(path: [CodingKey]) throws -> UInt16 {
    return try extract(path: path, make: \.asUInt16)
  }

  func makeUInt32(path: [CodingKey]) throws -> UInt32 {
    return try extract(path: path, make: \.asUInt32)
  }

  func makeUInt64(path: [CodingKey]) throws -> UInt64 {
    return try extract(path: path, make: \.asUInt64)
  }

  func makeFloat(path: [CodingKey]) throws -> Float {
    return try extract(path: path, make: \.asFloat)
  }

  func makeDouble(path: [CodingKey]) throws -> Double {
    return try extract(path: path, make: \.asDouble)
  }

  func makeString(path: [CodingKey]) throws -> String {
    return try extract(path: path, make: \.asString)
  }

  func extract<T: Decodable>(path: [CodingKey], make: (Enigma) -> T?) throws -> T {
    guard !isNull else {
      throw DecodingError.valueNotFound(T.self, DecodingError.Context(
        codingPath: path,
        debugDescription: "null insted of \(T.self)"
      ))
    }
    guard let result = make(self) else {
      throw DecodingError.typeMismatch(T.self, DecodingError.Context(
        codingPath: path,
        debugDescription: "Not \(T.self): \(debugDescription)"
      ))
    }
    return result
  }

  func merge(_ other: Self, path: [CommonKey], overwrite: Bool) throws -> Self {
    guard case (.dictionary(var this), .dictionary(let other)) = (self, other) else {
      if overwrite {
        return other
      } else if self == other {
        return self
      } else {
        throw EncodingError.invalidValue(other, EncodingError.Context(
          codingPath: path,
          debugDescription: "attempt to change \(debugDescription)"
        ))
      }
    }
    for (key, value) in other {
      if let result = this[key] {
        this[key] = try result.merge(value, path: path + [.key(key)], overwrite: overwrite)
      } else {
        this[key] = value
      }
    }
    return .dictionary(this)
  }
}
