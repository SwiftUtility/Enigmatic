import Foundation

/// A typed value tree for partial encoding, editing, merging, and decoding.
public enum Enigma: Sendable {
  /// An explicit null value.
  case null
  /// A Boolean value.
  case bool(Bool)
  /// A platform-sized signed integer.
  case int(Int)
  /// A signed 64-bit integer.
  case int64(Int64)
  /// A signed 32-bit integer.
  case int32(Int32)
  /// A signed 16-bit integer.
  case int16(Int16)
  /// A signed 8-bit integer.
  case int8(Int8)
  /// A platform-sized unsigned integer.
  case uint(UInt)
  /// An unsigned 64-bit integer.
  case uint64(UInt64)
  /// An unsigned 32-bit integer.
  case uint32(UInt32)
  /// An unsigned 16-bit integer.
  case uint16(UInt16)
  /// An unsigned 8-bit integer.
  case uint8(UInt8)
  /// A 64-bit floating-point value.
  case double(Double)
  /// A 32-bit floating-point value.
  case float(Float)
  /// A string value.
  case string(String)
  /// An ordered sequence of values.
  case array([Self])
  /// A string-keyed collection of values.
  case dictionary([String: Self])
  /// Binary data retained in its native form.
  case data(Data)
  /// A date retained in its native form.
  case date(Date)
  /// A signed 128-bit integer on supported operating systems.
  case int128(Int128Value)
  /// An unsigned 128-bit integer on supported operating systems.
  case uint128(UInt128Value)
}

extension Enigma: Equatable {
  /// Compares two trees by value, allowing exactly representable numeric cases to compare equal.
  /// NaN compares equal to NaN; this comparison does not guarantee identical numeric storage.
  /// - Complexity: O(n) in the number of visited values or output characters; recursive values use O(d) stack
  ///   space, where d is nesting depth.
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch lhs {
    case .null: rhs.isNull
    case .bool(let lhs): lhs == rhs.asBool
    case .int(let lhs): lhs == rhs.asInt
    case .int64(let lhs): lhs == rhs.asInt64
    case .int32(let lhs): lhs == rhs.asInt32
    case .int16(let lhs): lhs == rhs.asInt16
    case .int8(let lhs): lhs == rhs.asInt8
    case .uint(let lhs): lhs == rhs.asUInt
    case .uint64(let lhs): lhs == rhs.asUInt64
    case .uint32(let lhs): lhs == rhs.asUInt32
    case .uint16(let lhs): lhs == rhs.asUInt16
    case .uint8(let lhs): lhs == rhs.asUInt8
    case .double(let lhs):
      if case .float(let rhs) = rhs { rhs.isSame(double: lhs) } else { lhs.isSame(double: rhs.asDouble) }
    case .float(let lhs):
        if case .double(let rhs) = rhs { lhs.isSame(double: rhs) } else { lhs.isSame(float: rhs.asFloat) }
    case .string(let lhs): lhs == rhs.asString
    case .date(let lhs): lhs == rhs.asDate
    case .data(let lhs): lhs == rhs.asData
    case .array(let lhs): lhs == rhs.asArray
    case .dictionary(let lhs): lhs == rhs.asDictionary
    case .int128(let lhs): lhs.isSame(enigma: rhs)
    case .uint128(let lhs): lhs.isSame(enigma: rhs)
    }
  }
}

extension Enigma: Decodable {
  /// Creates a tree from the first keyed, unkeyed, or single-value container available.
  /// Dates and data are retained in their native cases when supported by the decoder.
  /// - Complexity: O(n) in the number of encoded or decoded values, plus the cost of nested Codable
  ///   implementations; recursive traversal uses O(d) stack space, where d is nesting depth.
  public init(from decoder: Decoder) throws {
    if var container = try? decoder.container(keyedBy: Pin.self) {
      self = try Self.decode(keyed: &container)
    } else if var container = try? decoder.unkeyedContainer() {
      self = try Self.decode(unkeyed: &container)
    } else if let container = try? decoder.singleValueContainer() {
      self = try Self.decode(single: container)
    } else {
      throw DecodingError.typeMismatch(Self.self, DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Neither value nor array nor dictionary"
      ))
    }
  }
}

extension Enigma: Encodable {
  /// Writes this tree using the supplied encoder. Format and value restrictions may throw.
  /// - Complexity: O(n) in the number of encoded or decoded values, plus the cost of nested Codable
  ///   implementations; recursive traversal uses O(d) stack space, where d is nesting depth.
  public func encode(to encoder: Encoder) throws {
    switch self {
    case .null:
      var container = encoder.singleValueContainer()
      try container.encodeNil()
    case .bool(let value):
      var container = encoder.singleValueContainer()
      try container.encode(value)
    case .int(let value):
      var container = encoder.singleValueContainer()
      try container.encode(value)
    case .int64(let value):
      var container = encoder.singleValueContainer()
      try container.encode(value)
    case .int32(let value):
      var container = encoder.singleValueContainer()
      try container.encode(value)
    case .int16(let value):
      var container = encoder.singleValueContainer()
      try container.encode(value)
    case .int8(let value):
      var container = encoder.singleValueContainer()
      try container.encode(value)
    case .uint(let value):
      var container = encoder.singleValueContainer()
      try container.encode(value)
    case .uint64(let value):
      var container = encoder.singleValueContainer()
      try container.encode(value)
    case .uint32(let value):
      var container = encoder.singleValueContainer()
      try container.encode(value)
    case .uint16(let value):
      var container = encoder.singleValueContainer()
      try container.encode(value)
    case .uint8(let value):
      var container = encoder.singleValueContainer()
      try container.encode(value)
    case .double(let value):
      var container = encoder.singleValueContainer()
      try container.encode(value)
    case .float(let value):
      var container = encoder.singleValueContainer()
      try container.encode(value)
    case .string(let value):
      var container = encoder.singleValueContainer()
      try container.encode(value)
    case .array(let value):
      var container = encoder.unkeyedContainer()
      for item in value {
        try container.encode(item)
      }
    case .dictionary(let value):
      var container = encoder.container(keyedBy: Pin.self)
      for (key, item) in value {
        try item.encode(pin: Pin.str(key), keyed: &container)
      }
    case .data(let value):
      try value.encode(to: encoder)
    case .date(let value):
      try value.encode(to: encoder)
    case .int128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        var container = encoder.singleValueContainer()
        try container.encode(value.value)
      } else {
        throw EncodingError.invalidValue(value, EncodingError.Context(
          codingPath: encoder.codingPath,
          debugDescription: "Int128 not available"
        ))
      }
    case .uint128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        var container = encoder.singleValueContainer()
        try container.encode(value.value)
      } else {
        throw EncodingError.invalidValue(value, EncodingError.Context(
          codingPath: encoder.codingPath,
          debugDescription: "UInt128 not available"
        ))
      }
    }
  }
}

extension Enigma: CustomStringConvertible {
  /// A human-readable description. This is not a JSON serialization.
  /// - Complexity: O(n) in the number of visited values or output characters; recursive values use O(d) stack
  ///   space, where d is nesting depth.
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
    case .int128(let value): String(describing: value)
    case .uint128(let value): String(describing: value)
    }
  }
}

extension Enigma: CustomDebugStringConvertible {
  /// A diagnostic representation of the tree; it is not a serialization format.
  /// - Complexity: O(n) in the number of visited values or output characters; recursive values use O(d) stack
  ///   space, where d is nesting depth.
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
    case .int128(let value): String(reflecting: value)
    case .uint128(let value): String(reflecting: value)
    }
  }
}

extension Enigma: ExpressibleByNilLiteral {
  /// Creates an explicit null tree value from `nil`.
  /// - Complexity: O(1) for the literal value.
  public init(nilLiteral: ()) {
    self = .null
  }
}

extension Enigma: ExpressibleByBooleanLiteral {
  /// Creates a Boolean tree value from a Boolean literal.
  /// - Complexity: O(1) for the literal value.
  public init(booleanLiteral value: BooleanLiteralType) {
    self = .bool(value)
  }
}

extension Enigma: ExpressibleByIntegerLiteral {
  /// Creates an integer tree value from an integer literal.
  /// - Complexity: O(1) for the literal value.
  public init(integerLiteral value: IntegerLiteralType) {
    self = if let value = UInt8(exactly: value) {
      .uint8(value)
    } else if let value = Int8(exactly: value) {
      .int8(value)
    } else if let value = UInt16(exactly: value) {
      .uint16(value)
    } else if let value = Int16(exactly: value) {
      .int16(value)
    } else if let value = UInt32(exactly: value) {
      .uint32(value)
    } else if let value = Int32(exactly: value) {
      .int32(value)
    } else if let value = UInt64(exactly: value) {
      .uint64(value)
    } else if let value = Int64(exactly: value) {
      .int64(value)
    } else if let value = UInt(exactly: value) {
      .uint(value)
    } else {
      .int(value)
    }
  }
}

extension Enigma: ExpressibleByFloatLiteral {
  /// Creates a floating-point tree value from a floating-point literal.
  /// - Complexity: O(1) for the literal value.
  public init(floatLiteral value: FloatLiteralType) {
    self = if let value = UInt8(exactly: value) {
      .uint8(value)
    } else if let value = Int8(exactly: value) {
      .int8(value)
    } else if let value = UInt16(exactly: value) {
      .uint16(value)
    } else if let value = Int16(exactly: value) {
      .int16(value)
    } else if let value = UInt32(exactly: value) {
      .uint32(value)
    } else if let value = Int32(exactly: value) {
      .int32(value)
    } else if let value = UInt64(exactly: value) {
      .uint64(value)
    } else if let value = Int64(exactly: value) {
      .int64(value)
    } else if let value = UInt(exactly: value) {
      .uint(value)
    } else if let value = Int(exactly: value) {
      .int(value)
    } else if let value = Float(exactly: value) {
      .float(value)
    } else {
      .double(value)
    }
  }
}

extension Enigma: ExpressibleByStringLiteral {
  /// Creates a string tree value from a string literal.
  /// - Complexity: O(1) for the literal value.
  public init(stringLiteral value: StringLiteralType) {
    self = .string(value)
  }
}

extension Enigma: ExpressibleByArrayLiteral {
  /// Creates an array tree from its elements.
  /// - Complexity: O(n) in the number of elements; elements are stored in order.
  public init(arrayLiteral elements: Enigma...) {
    self = .array(elements)
  }
}

extension Enigma: ExpressibleByDictionaryLiteral {
  /// Creates a dictionary tree from string-keyed entries.
  /// - Complexity: O(n) expected in the number of entries, assuming expected
  ///   constant-time string hashing and dictionary insertion.
  public init(dictionaryLiteral elements: (String, Enigma)...) {
    self = .dictionary([String: Enigma](uniqueKeysWithValues: elements))
  }
}
