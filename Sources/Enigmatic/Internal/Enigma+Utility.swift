import Foundation

extension Enigma {
  init(any: Any?, pins: borrowing [Pin]) throws {
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

  var isFloat: Bool {
    if case .float = self { true } else { false }
  }

  var isArray: Bool {
    switch self {
    case .array, .dictionary([:]), .data: true
    default: false
    }
  }

  var isDictionart: Bool {
    if case .dictionary = self { true } else { false }
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

  func extract<T: Decodable>(path: borrowing [CodingKey], make: (borrowing Self) -> T?) throws -> T {
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

  func merge(_ other: Self, pins: borrowing [Pin], overwrite: Bool) throws -> Self {
    guard case (.dictionary(var this), .dictionary(let other)) = (self, other) else {
      return if overwrite {
        other
      } else if self == other {
        self
      } else {
        throw EncodingError.invalidValue(other, EncodingError.Context(
          codingPath: pins,
          debugDescription: "attempt to change \(debugDescription)"
        ))
      }
    }
    for (key, value) in other {
      if let result = this[key] {
        this[key] = try result.merge(value, pins: pins + [.str(key)], overwrite: overwrite)
      } else {
        this[key] = value
      }
    }
    return .dictionary(this)
  }

  mutating func access(pins: borrowing [Pin], depth: Int, block: (inout Self) throws -> Void) throws {
    guard depth < pins.count else { return try block(&self) }
    switch pins[depth] {
    case .int(let index):
      guard var array = asArray else {
        throw DecodingError.dataCorrupted(DecodingError.Context(
          codingPath: Array(pins[0...depth]),
          debugDescription: "Not an array"
        ))
      }
      guard array.indices.contains(index) else {
        throw DecodingError.dataCorrupted(DecodingError.Context(
          codingPath: Array(pins[0...depth]),
          debugDescription: "Not in bounds \(index)"
        ))
      }
      try array[index].access(pins: pins, depth: depth + 1, block: block)
      self = .array(array)
    case .str(let str):
      guard var dictionary = asDictionary else {
        throw DecodingError.dataCorrupted(DecodingError.Context(
          codingPath: Array(pins[0...depth]),
          debugDescription: "Not a dictionary"
        ))
      }
      guard var value = dictionary[str] else {
        throw DecodingError.dataCorrupted(DecodingError.Context(
          codingPath: Array(pins[0...depth]),
          debugDescription: "No key \(str)"
        ))
      }
      try value.access(pins: pins, depth: depth + 1, block: block)
      dictionary[str] = value
      self = .dictionary(dictionary)
    }
  }

  mutating func update<T>(pins: borrowing [Pin], depth: Int, block: (inout Self) throws -> T) rethrows -> T {
    guard depth < pins.count else { return try block(&self) }
    switch pins[depth] {
    case .int(let int):
      var array = asArray ?? []
      defer { self = .array(array) }
      if int < 0 {
        if int < -array.count {
          var value = Self.null
          defer { array = [value] + array }
          return try value.update(pins: pins, depth: depth + 1, block: block)
        } else {
          return try array[array.count - int].update(pins: pins, depth: depth + 1, block: block)
        }
      } else {
        if int < array.count {
          return try array[int].update(pins: pins, depth: depth + 1, block: block)
        } else {
          var value = Self.null
          defer { array.append(value) }
          return try value.update(pins: pins, depth: depth + 1, block: block)
        }
      }
    case .str(let str):
      var dictionary = asDictionary ?? [:]
      defer { self = .dictionary(dictionary) }
      var value = dictionary[str] ?? Self.null
      defer { dictionary[str] = value }
      return try value.update(pins: pins, depth: depth + 1, block: block)
    }
  }

  mutating func filter(
    pins: inout [Pin],
    isIncluded: (borrowing Self, borrowing [Pin]) -> Bool
  ) {
    let pin = pins.count
    pins.append(.super)
    defer { _ = pins.popLast() }
    if var dict = asDictionary {
      defer { self = .dictionary(dict) }
      for (key, var value) in dict {
        pins[pin] = .str(key)
        value.filter(pins: &pins, isIncluded: isIncluded)
        dict[key] = if isIncluded(value, pins) { value } else { nil }
      }
    } else if var array = asArray {
      defer { self = .array(array) }
      for index in array.indices.reversed() {
        pins[pin] = .int(index)
        array[index].filter(pins: &pins, isIncluded: isIncluded)
        if !isIncluded(array[index], pins) {
          array.remove(at: index)
        }
      }
    }
  }
}
