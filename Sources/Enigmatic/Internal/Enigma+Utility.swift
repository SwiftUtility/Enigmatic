import Foundation

extension Enigma {
  init(
    any: Any?,
    pins: borrowing [Pin]
  ) throws {
    if any == nil || any is NSNull {
      self = .null
    } else if let value = any as? Data {
      self = .data(value)
    } else if let value = any as? Date {
      self = .date(value)
    } else if let value = any as? String {
      self = .string(value)
    } else if let value = any as? NSNumber {
      if CFGetTypeID(value) == CFBooleanGetTypeID() {
        self = .bool(value.boolValue)
      } else if let value = UInt8(exactly: value) {
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
          codingPath: pins,
          debugDescription: "NSNumber type not determined: \(value.stringValue)"
        ))
      }
    } else if let value = any as? [AnyHashable: Any?] {
      var dictionary: [String: Enigma] = [:]
      for (key, value) in value {
        let key = key.description
        try dictionary[key] = Self(any: value, pins: pins + [Pin.str(key)])
      }
      self = .dictionary(dictionary)
    } else if let value = any as? [Any?] {
      var array: [Self] = []
      for (index, value) in value.enumerated() {
        try array.append(Self(any: value, pins: pins + [Pin.int(index)]))
      }
      self = .array(array)
    } else {
      throw DecodingError.dataCorrupted(DecodingError.Context(
        codingPath: pins,
        debugDescription: "Neither value nor array nor dictionary"
      ))
    }
  }

  func makeKeyed<K: CodingKey>(path: borrowing [CodingKey]) throws -> KeyedDecodingContainer<K> {
    let enigmas = try extract(path: path, make: \.asDictionary)
    return KeyedDecodingContainer(KeyedDecoder<K>(enigmas: enigmas, codingPath: copy path))
  }

  func makeUnkeyed(path: borrowing [CodingKey]) throws -> UnkeyedDecoder {
    let enigmas = try extract(path: path, make: \.asArray)
    return UnkeyedDecoder(enigmas: enigmas, codingPath: copy path)
  }

  func makeValue(path: borrowing [CodingKey]) throws -> ValueDecoder {
    ValueDecoder(enigma: self, codingPath: copy path)
  }

  func makeBool(path: borrowing [CodingKey]) throws -> Bool {
    try extract(path: path, make: \.asBool)
  }

  func makeInt(path: borrowing [CodingKey]) throws -> Int {
    try extract(path: path, make: \.asInt)
  }

  func makeInt8(path: borrowing [CodingKey]) throws -> Int8 {
    try extract(path: path, make: \.asInt8)
  }

  func makeInt16(path: borrowing [CodingKey]) throws -> Int16 {
    try extract(path: path, make: \.asInt16)
  }

  func makeInt32(path: borrowing [CodingKey]) throws -> Int32 {
    try extract(path: path, make: \.asInt32)
  }

  func makeInt64(path: borrowing [CodingKey]) throws -> Int64 {
    try extract(path: path, make: \.asInt64)
  }

  func makeUInt(path: borrowing [CodingKey]) throws -> UInt {
    try extract(path: path, make: \.asUInt)
  }

  func makeUInt8(path: borrowing [CodingKey]) throws -> UInt8 {
    try extract(path: path, make: \.asUInt8)
  }

  func makeUInt16(path: borrowing [CodingKey]) throws -> UInt16 {
    try extract(path: path, make: \.asUInt16)
  }

  func makeUInt32(path: borrowing [CodingKey]) throws -> UInt32 {
    try extract(path: path, make: \.asUInt32)
  }

  func makeUInt64(path: borrowing [CodingKey]) throws -> UInt64 {
    try extract(path: path, make: \.asUInt64)
  }

  func makeFloat(path: borrowing [CodingKey]) throws -> Float {
    try extract(path: path, make: \.asFloat)
  }

  func makeDouble(path: borrowing [CodingKey]) throws -> Double {
    try extract(path: path, make: \.asDouble)
  }

  func makeString(path: borrowing [CodingKey]) throws -> String {
    try extract(path: path, make: \.asString)
  }

  func extract<T: Decodable>(
    path: borrowing [CodingKey],
    make: (borrowing Self) -> T?
  ) throws -> T {
    guard !isNull else {
      throw DecodingError.valueNotFound(T.self, DecodingError.Context(
        codingPath: copy path,
        debugDescription: "null insted of \(T.self)"
      ))
    }
    guard let result = make(self) else {
      throw DecodingError.typeMismatch(T.self, DecodingError.Context(
        codingPath: copy path,
        debugDescription: "Not \(T.self): \(debugDescription)"
      ))
    }
    return result
  }

  func collectPins(
    into pins: inout [[Pin]],
    current: inout [Pin]
  ) {
    switch self {
    case .array(let value):
      for (index, element) in value.enumerated() {
        current.append(.int(index))
        defer { current.removeLast() }
        element.collectPins(into: &pins, current: &current)
      }
    case .dictionary(let value):
      for (key, element) in value {
        current.append(.str(key))
        defer { current.removeLast() }
        element.collectPins(into: &pins, current: &current)
      }
    default: break
    }
    pins.append(current)
  }

  func getValue(
    pins: [Pin]
  ) -> Self? {
    var result = self
    for pin in pins {
      switch pin {
      case .int(let int):
        guard let array = result.asArray, array.indices.contains(int) else { return nil }
        result = array[int]
      case .str(let str):
        guard let dictionary = result.asDictionary, let value = dictionary[str] else { return nil }
        result = value
      }
    }
    return result
  }

  func setValue(
    _ value: Self?,
    pins: borrowing [Pin],
    depth: Int = 0
  ) -> Self? {
    guard depth < pins.count else { return value }
    switch pins[depth] {
    case .int(let index):
      guard var array = asArray else {
        guard let value = Self.null.setValue(value, pins: pins, depth: depth + 1) else { return self }
        return .array([value])
      }
      guard array.indices.contains(index) else {
        guard let value = Self.null.setValue(value, pins: pins, depth: depth + 1) else { return self }
        return if index < array.count { .array([value] + array) } else { .array(array + [value]) }
      }
      guard let value = array[index].setValue(value, pins: pins, depth: depth + 1) else {
        array.remove(at: index)
        return .array(array)
      }
      array[index] = value
      return .array(array)
    case .str(let key):
      guard var dictionary = asDictionary else {
        guard let value = Self.null.setValue(value, pins: pins, depth: depth + 1) else { return self }
        return .dictionary([key: value])
      }
      guard let element = dictionary[key] else {
        guard let value = Self.null.setValue(value, pins: pins, depth: depth + 1) else { return self }
        dictionary[key] = value
        return .dictionary(dictionary)
      }
      dictionary[key] = element.setValue(value, pins: pins, depth: depth + 1)
      return .dictionary(dictionary)
    }
  }

  func merge<E: Error>(
    _ other: Self,
    pins: inout [Pin],
    resolve: ([Pin], Self, Self) throws(E) -> Self
  ) throws(E) -> Self {
    guard case (.dictionary(var this), .dictionary(let other)) = (self, other) else {
      return try resolve(pins, self, other)
    }
    for (key, value) in other {
      pins.append(.str(key))
      defer { pins.removeLast() }
      this[key] = try this[key]?.merge(value, pins: &pins, resolve: resolve) ?? value
    }
    return .dictionary(this)
  }
}
