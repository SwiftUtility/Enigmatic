import Foundation

/// Container type to allow partial or multi step encoding and decoding operations
public enum Enigma: Sendable {
  case null
  case bool(Bool)
  case int(Int)
  case int64(Int64)
  case int32(Int32)
  case int16(Int16)
  case int8(Int8)
  case uint(UInt)
  case uint64(UInt64)
  case uint32(UInt32)
  case uint16(UInt16)
  case uint8(UInt8)
  case double(Double)
  case float(Float)
  case string(String)
  case array([Self])
  case dictionary([String: Self])
  case data(Data)
  case date(Date)

  /// Create Enigma tree from AnyObject
  ///
  /// - Note: It is usable with JSONSerialization and [Yams](https://github.com/jpsim/Yams) parser load function output
  public init(cast any: Any?) throws {
    try self.init(any: any, pins: [])
  }

  /// Create Enigma tree by encoding Encodable instance
  public init<T: Encodable>(encode value: T) throws {
    let context = EncoderContext()
    try value.encode(to: context.makeValue(path: []))
    guard let enigma = context.enigma else {
      throw EncodingError.invalidValue(value, EncodingError.Context(
        codingPath: [],
        debugDescription: "encoded to nothing"
      ))
    }
    self = enigma
  }

  /// Get value if it is Array, emply Dictionary or Data, empty array otherwise
  public var array: [Self] {
    get { asArray ?? [] }
    set { self = .array(newValue) }
  }

  /// Get value if it is Dictionary, empty dictionary otherwise
  public var dictionary: [String: Self] {
    get { asDictionary ?? [:] }
    set { self = .dictionary(newValue) }
  }

  /// Get or set value if it is present, index is correct and root element is Array
  public subscript(_ index: Int) -> Self? {
    get {
      if let array = asArray, array.indices.contains(index) { array[index] } else { nil }
    }
    set {
      guard let newValue, var array = asArray, array.indices.contains(index) else { return }
      array[index] = newValue
      self = .array(array)
    }
  }

  /// Get, add, overwrite or delete value
  public subscript(_ key: String) -> Self? {
    get {
      if case .dictionary(let value) = self { value[key] } else { nil }
    }
    set {
      guard let newValue, case .dictionary(var value) = self else { return }
      value[key] = newValue
      self = .dictionary(value)
    }
  }

  /// Get or set value if it is encoded/decoded successfully
  public subscript<T: Codable>(_ _: T.Type) -> T? {
    get { try? makeValue(path: []).decode(T.self) }
    set {
      guard let newValue else { return }
      guard let value = try? merge(Self(encode: newValue), pins: [], overwrite: true) else { return }
      self = value
    }
  }

  /// Get or set value unconditionally
  public subscript(_ pins: [Pin]) -> Self {
    get {
      var result = self
      for pin in pins {
        switch pin {
        case .int(let int):
          if let array = result.asArray {
            if int < 0 {
              if int < -array.count {
                return .null
              } else {
                result = array[array.count - int]
              }
            } else {
              if int < array.count {
                result = array[int]
              } else {
                return .null
              }
            }
          }
        case .str(let str):
          guard let dictionary = result.asDictionary, let value = dictionary[str] else { return .null }
          result = value
        }
      }
      return result
    }
    set {
      update(pins: pins, depth: 0) { $0 = newValue }
    }
  }

  /// Attempt to decode value
  public func decode<T: Decodable>(_: T.Type = T.self, at pins: borrowing [Pin] = []) throws -> T {
    var this = self
    for depth in pins.indices {
      switch pins[depth] {
      case .int(let index):
        guard let array = asArray else {
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
        this = array[index]
      case .str(let str):
        guard let dictionary = asDictionary else {
          throw DecodingError.dataCorrupted(DecodingError.Context(
            codingPath: Array(pins[0...depth]),
            debugDescription: "Not a dictionary"
          ))
        }
        guard let value = dictionary[str] else {
          throw DecodingError.dataCorrupted(DecodingError.Context(
            codingPath: Array(pins[0...depth]),
            debugDescription: "No key \(str)"
          ))
        }
        this = value
      }
    }
    return try this.makeValue(path: pins).decode(T.self)
  }

  /// Attempt to merge current and encoded ortagonal value
  public mutating func encode<T: Encodable>(_ value: T, at pins: borrowing [Pin] = []) throws {
    try self.access(pins: pins, depth: 0) { this in
      this = try this.merge(Self(encode: value), pins: [], overwrite: false)
    }
  }

  /// Attempt to write encoded value overwriting original
  public mutating func merge<T: Encodable>(_ value: T, at pins: borrowing [Pin] = []) throws {
    try self.access(pins: pins, depth: 0) { this in
      this = try this.merge(Self(encode: value), pins: [], overwrite: true)
    }
  }

  public mutating func update<T: Codable>(
    _: T.Type = T.self,
    at pins: borrowing [Pin] = [],
    block: (inout T) throws -> Void
  ) throws {
    try self.access(pins: pins, depth: 0) { this in
      var value = try this.decode() as T
      try block(&value)
      this = try this.merge(Self(encode: value), pins: [], overwrite: true)
    }
  }

  public mutating func filter(
    isIncluded: (borrowing Self, borrowing [Pin]) -> Bool
  ) {
    var pins: [Pin] = []
    filter(pins: &pins, isIncluded: isIncluded)
  }
}

extension Enigma: Decodable {
  /// In fact it never throws for json and plist coders
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if container.decodeNil() {
      self = .null
    } else if let value = try? container.decode([String: Self].self) {
      self = .dictionary(value)
    } else if let value = try? container.decode([Self].self) {
      self = .array(value)
    } else if let value = try? container.decode(Bool.self) {
      self = .bool(value)
    } else if let value = try? container.decode(UInt8.self) {
      self = .uint8(value)
    } else if let value = try? container.decode(Int8.self) {
      self = .int8(value)
    } else if let value = try? container.decode(UInt16.self) {
      self = .uint16(value)
    } else if let value = try? container.decode(Int16.self) {
      self = .int16(value)
    } else if let value = try? container.decode(UInt32.self) {
      self = .uint32(value)
    } else if let value = try? container.decode(Int32.self) {
      self = .int32(value)
    } else if let value = try? container.decode(UInt64.self) {
      self = .uint64(value)
    } else if let value = try? container.decode(Int64.self) {
      self = .int64(value)
    } else if let value = try? container.decode(UInt.self) {
      self = .uint(value)
    } else if let value = try? container.decode(Int.self) {
      self = .int(value)
    } else if let value = try? container.decode(Double.self) {
      self = Float(exactly: value).map(Enigma.float(_:)) ?? .double(value)
    } else if let value = try? container.decode(Float.self) {
      self = .float(value)
    } else if let value = try? container.decode(String.self) {
      self = .string(value)
    } else if let value = try? container.decode(Data.self) {
      self = .data(value)
    } else if let value = try? container.decode(Date.self) {
      self = .date(value)
    } else {
      throw DecodingError.typeMismatch(Self.self, DecodingError.Context(
        codingPath: container.codingPath,
        debugDescription: "Neither value nor array nor dictionary"
      ))
    }
  }
}

extension Enigma: Encodable {
  /// In fact it never throws for json coders, and for plist if root element is collection
  public func encode(to encoder: Encoder) throws {
    switch self {
    case .null:
      var container = encoder.singleValueContainer()
      try container.encodeNil()
    case .bool(let value): try value.encode(to: encoder)
    case .int(let value): try value.encode(to: encoder)
    case .int64(let value): try value.encode(to: encoder)
    case .int32(let value): try value.encode(to: encoder)
    case .int16(let value): try value.encode(to: encoder)
    case .int8(let value): try value.encode(to: encoder)
    case .uint(let value): try value.encode(to: encoder)
    case .uint64(let value): try value.encode(to: encoder)
    case .uint32(let value): try value.encode(to: encoder)
    case .uint16(let value): try value.encode(to: encoder)
    case .uint8(let value): try value.encode(to: encoder)
    case .double(let value): try value.encode(to: encoder)
    case .float(let value): try value.encode(to: encoder)
    case .string(let value): try value.encode(to: encoder)
    case .array(let value): try value.encode(to: encoder)
    case .dictionary(let value): try value.encode(to: encoder)
    case .data(let value): try value.encode(to: encoder)
    case .date(let value): try value.encode(to: encoder)
    }
  }
}

extension Enigma: Equatable {
  /// Equality check
  ///
  /// - Note: two values are considered equal if and only if:
  ///   * they are both null
  ///   * they are both empty Array or Dictionary
  ///   * they are both equal Arrays (Data threated as array of numerics)
  ///   * they are both equal Dictionaries
  ///   * they are both equal Strings
  ///   * they are both equal Bools (Bools do not implicitly convert to numerics)
  ///   * they are both convertible to the same integer type and values are equal
  ///   * they are both convertible to decimal type and values are almost equal
  public static func ==(lhs: Self, rhs: Self) -> Bool {
    return if lhs.isNull, rhs.isNull {
      true
    } else if let lhs = lhs.asArray, let rhs = rhs.asArray {
      lhs == rhs
    } else if let lhs = lhs.asDictionary, let rhs = rhs.asDictionary {
      lhs == rhs
    } else if let lhs = lhs.asString, let rhs = rhs.asString {
      lhs == rhs
    } else if let lhs = lhs.asBool, let rhs = rhs.asBool {
      lhs == rhs
    } else if let lhs = lhs.asInt, let rhs = rhs.asInt {
      lhs == rhs
    } else if let lhs = lhs.asUInt, let rhs = rhs.asUInt {
      lhs == rhs
    } else if lhs.isFloat || rhs.isFloat {
      Float.isNearlyEqual(lhs.asFloat, rhs.asFloat)
    } else {
      Double.isNearlyEqual(lhs.asDouble, rhs.asDouble)
    }
  }
}

extension Enigma: CustomStringConvertible {
  /// CustomStringConvertible implementation converts to json string
  public var description: String {
    switch self {
    case .null: "null"
    case .bool(let value): String(describing: value)
    case .int(let value): String(describing: value)
    case .int64(let value): String(describing: value)
    case .int32(let value): String(describing: value)
    case .int16(let value): String(describing: value)
    case .int8(let value): String(describing: value)
    case .uint(let value): String(describing: value)
    case .uint64(let value): String(describing: value)
    case .uint32(let value): String(describing: value)
    case .uint16(let value): String(describing: value)
    case .uint8(let value): String(describing: value)
    case .double(let value): String(describing: value)
    case .float(let value): String(describing: value)
    case .string(let value): String(describing: value)
    case .date(let value): String(describing: value)
    case .data(let value): String(describing: value)
    case .array(let value): String(describing: value)
    case .dictionary(let value): String(describing: value)
    }
  }
}

extension Enigma: CustomDebugStringConvertible {
  /// CustomDebugStringConvertible implementation
  public var debugDescription: String {
    switch self {
    case .null: "null"
    case .bool(let value): String(reflecting: value)
    case .int(let value): String(reflecting: value)
    case .int64(let value): String(reflecting: value)
    case .int32(let value): String(reflecting: value)
    case .int16(let value): String(reflecting: value)
    case .int8(let value): String(reflecting: value)
    case .uint(let value): String(reflecting: value)
    case .uint64(let value): String(reflecting: value)
    case .uint32(let value): String(reflecting: value)
    case .uint16(let value): String(reflecting: value)
    case .uint8(let value): String(reflecting: value)
    case .double(let value): String(reflecting: value)
    case .float(let value): String(reflecting: value)
    case .string(let value): String(reflecting: value)
    case .date(let value): String(reflecting: value)
    case .data(let value): String(reflecting: value)
    case .array(let value): String(reflecting: value)
    case .dictionary(let value): String(reflecting: value)
    }
  }
}

extension Enigma: ExpressibleByNilLiteral {
  public init(nilLiteral: ()) { self = .null }
}

extension Enigma: ExpressibleByBooleanLiteral {
  public init(booleanLiteral value: BooleanLiteralType) { self = .bool(value) }
}

extension Enigma: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: IntegerLiteralType) {
    if let value = UInt8(exactly: value) { self = .uint8(value) }
    else if let value = Int8(exactly: value) { self = .int8(value) }
    else if let value = UInt16(exactly: value) { self = .uint16(value) }
    else if let value = Int16(exactly: value) { self = .int16(value) }
    else if let value = UInt32(exactly: value) { self = .uint32(value) }
    else if let value = Int32(exactly: value) { self = .int32(value) }
    else if let value = UInt64(exactly: value) { self = .uint64(value) }
    else if let value = Int64(exactly: value) { self = .int64(value) }
    else if let value = UInt(exactly: value) { self = .uint(value) }
    else { self = .int(value) }
  }
}

extension Enigma: ExpressibleByFloatLiteral {
  public init(floatLiteral value: FloatLiteralType) {
    if let value = UInt8(exactly: value) { self = .uint8(value) }
    else if let value = Int8(exactly: value) { self = .int8(value) }
    else if let value = UInt16(exactly: value) { self = .uint16(value) }
    else if let value = Int16(exactly: value) { self = .int16(value) }
    else if let value = UInt32(exactly: value) { self = .uint32(value) }
    else if let value = Int32(exactly: value) { self = .int32(value) }
    else if let value = UInt64(exactly: value) { self = .uint64(value) }
    else if let value = Int64(exactly: value) { self = .int64(value) }
    else if let value = UInt(exactly: value) { self = .uint(value) }
    else if let value = Int(exactly: value) { self = .int(value) }
    else if let value = Float(exactly: value) { self = .float(value) }
    else { self = .double(value) }
  }
}

extension Enigma: ExpressibleByStringLiteral {
  public init(stringLiteral value: StringLiteralType) { self = .string(value) }
}

extension Enigma: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: Enigma...) { self = .array(elements) }
}

extension Enigma: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (String, Enigma)...) {
    self = .dictionary([String: Enigma](uniqueKeysWithValues: elements))
  }
}
