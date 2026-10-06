import Foundation

extension Enigma {
  /// Creates a tree from Foundation-compatible objects or supported Swift values.
  ///
  /// Arrays and sets become arrays. Dictionaries support string, integer,
  /// `AnyHashable` bases that convert to string keys, and `CodingKeyRepresentable`
  /// keys where available. Keys normalize to strings; collisions and unsupported
  /// value or key types cause a decoding error. Use values from `JSONSerialization`,
  /// `PropertyListSerialization`, or a YAML parser.
  /// - Parameter value: The root object to convert.
  /// - Throws: `DecodingError.dataCorrupted` or `typeMismatch` when a value cannot
  ///   be represented by Enigma.
  /// - Complexity: O(n) time and O(d) stack space, where n is the number of converted values and d is nesting depth.
  public init(cast value: Any) throws(DecodingError) {
    var pins: [Pin] = []
    self = try Self.make(pins: &pins, value: value)
  }

  /// Encodes a model into a tree, preserving Date and Data at every position.
  /// - Parameters:
  ///   - value: The value to encode.
  ///   - userInfo: Context passed to the encoder and nested encoders.
  /// - Throws: An encoding error when the value cannot be represented.
  /// - Complexity: O(n) time and O(d) stack space, where n is the number of encoded values and d is nesting
  ///   depth; the Encodable implementation contributes its own cost.
  public init(encode value: some Encodable, userInfo: [CodingUserInfoKey: Any] = [:]) throws {
    self = try value as? Enigma ?? EnigmaEncoder.encode(value: value, userInfo: userInfo)
  }

  /// Converts the tree to native Swift/Foundation values for templating and inspection.
  ///
  /// - Warning: It is not guaranteed to be compatible with JSONSerialization or PropertyListSerialization
  /// - Complexity: O(n) in the number of tree values; recursive conversion also uses O(d) stack space, where d
  ///   is nesting depth.
  public var asAny: Any {
    switch self {
    case .null: NSNull()
    case .bool(let value): value
    case .int(let value): value
    case .int64(let value): value
    case .int32(let value): value
    case .int16(let value): value
    case .int8(let value): value
    case .uint(let value): value
    case .uint64(let value): value
    case .uint32(let value): value
    case .uint16(let value): value
    case .uint8(let value): value
    case .double(let value): value
    case .float(let value): value
    case .string(let value): value
    case .array(let value): value.map(\.asAny)
    case .dictionary(let value): value.mapValues(\.asAny)
    case .data(let value): value
    case .date(let value): value
    case .int128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        value.value
      } else {
        value
      }
    case .uint128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        value.value
      } else {
        value
      }
    }
  }

  /// Converts the tree to a Foundation object accepted by `PropertyListSerialization`.
  ///
  /// - Throws: `EncodingError.invalidValue` when a value is unsupported by property lists.
  /// - Complexity: O(n) in the number of tree values; recursive conversion also uses O(d) stack space, where d
  ///   is nesting depth.
  public var asPlistObject: NSObject {
    get throws(EncodingError) {
      var pins = [] as [Pin]
      return try makePlistObject(pins: &pins)
    }
  }

  /// Converts the tree to a Foundation object accepted by `JSONSerialization`.
  ///
  /// - Throws: `EncodingError.invalidValue` for data, dates, non-finite numbers,
  ///   and 128-bit integers.
  /// - Complexity: O(n) in the number of tree values; recursive conversion also uses O(d) stack space, where d
  ///   is nesting depth.
  public var asJsonObject: NSObject {
    get throws(EncodingError) {
      var pins = [] as [Pin]
      return try makeJsonObject(pins: &pins)
    }
  }

  /// Returns the Boolean value, or nil for other cases.
  /// - Complexity: O(1); the accessor checks one enum case and returns the associated value.
  public var asBool: Bool? {
    if case .bool(let value) = self { value } else { nil }
  }

  /// Returns an exactly representable integer value, or nil for other values,
  /// fractions, and overflow.
  /// - Complexity: O(1); the accessor checks one enum case and performs a fixed number of exact numeric conversions.
  public var asInt: Int? {
    switch self {
    case .int(let value): value
    case .int64(let value): Int(exactly: value)
    case .int32(let value): Int(exactly: value)
    case .int16(let value): Int(exactly: value)
    case .int8(let value): Int(exactly: value)
    case .uint(let value): Int(exactly: value)
    case .uint64(let value): Int(exactly: value)
    case .uint32(let value): Int(exactly: value)
    case .uint16(let value): Int(exactly: value)
    case .uint8(let value): Int(exactly: value)
    case .double(let value): Int(exactly: value)
    case .float(let value): Int(exactly: value)
    case .int128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        Int(exactly: value.value)
      } else {
        nil
      }
    case .uint128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        Int(exactly: value.value)
      } else {
        nil
      }
    case .array, .bool, .data, .date, .dictionary, .null, .string: nil
    }
  }

  /// Returns an exactly representable 64-bit integer, or nil for other values,
  /// fractions, and overflow.
  /// - Complexity: O(1); the accessor checks one enum case and performs a fixed number of exact numeric conversions.
  public var asInt64: Int64? {
    switch self {
    case .int(let value): Int64(exactly: value)
    case .int64(let value): value
    case .int32(let value): Int64(exactly: value)
    case .int16(let value): Int64(exactly: value)
    case .int8(let value): Int64(exactly: value)
    case .uint(let value): Int64(exactly: value)
    case .uint64(let value): Int64(exactly: value)
    case .uint32(let value): Int64(exactly: value)
    case .uint16(let value): Int64(exactly: value)
    case .uint8(let value): Int64(exactly: value)
    case .double(let value): Int64(exactly: value)
    case .float(let value): Int64(exactly: value)
    case .int128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        Int64(exactly: value.value)
      } else {
        nil
      }
    case .uint128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        Int64(exactly: value.value)
      } else {
        nil
      }
    case .array, .bool, .data, .date, .dictionary, .null, .string: nil
    }
  }

  /// Returns an exactly representable 32-bit integer, or nil for other values,
  /// fractions, and overflow.
  /// - Complexity: O(1); the accessor checks one enum case and performs a fixed number of exact numeric conversions.
  public var asInt32: Int32? {
    switch self {
    case .int(let value): Int32(exactly: value)
    case .int64(let value): Int32(exactly: value)
    case .int32(let value): value
    case .int16(let value): Int32(exactly: value)
    case .int8(let value): Int32(exactly: value)
    case .uint(let value): Int32(exactly: value)
    case .uint64(let value): Int32(exactly: value)
    case .uint32(let value): Int32(exactly: value)
    case .uint16(let value): Int32(exactly: value)
    case .uint8(let value): Int32(exactly: value)
    case .double(let value): Int32(exactly: value)
    case .float(let value): Int32(exactly: value)
    case .int128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        Int32(exactly: value.value)
      } else {
        nil
      }
    case .uint128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        Int32(exactly: value.value)
      } else {
        nil
      }
    case .array, .bool, .data, .date, .dictionary, .null, .string: nil
    }
  }

  /// Returns an exactly representable 16-bit integer, or nil for other values,
  /// fractions, and overflow.
  /// - Complexity: O(1); the accessor checks one enum case and performs a fixed number of exact numeric conversions.
  public var asInt16: Int16? {
    switch self {
    case .int(let value): Int16(exactly: value)
    case .int64(let value): Int16(exactly: value)
    case .int32(let value): Int16(exactly: value)
    case .int16(let value): value
    case .int8(let value): Int16(exactly: value)
    case .uint(let value): Int16(exactly: value)
    case .uint64(let value): Int16(exactly: value)
    case .uint32(let value): Int16(exactly: value)
    case .uint16(let value): Int16(exactly: value)
    case .uint8(let value): Int16(exactly: value)
    case .double(let value): Int16(exactly: value)
    case .float(let value): Int16(exactly: value)
    case .int128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        Int16(exactly: value.value)
      } else {
        nil
      }
    case .uint128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        Int16(exactly: value.value)
      } else {
        nil
      }
    case .array, .bool, .data, .date, .dictionary, .null, .string: nil
    }
  }

  /// Returns an exactly representable 8-bit integer, or nil for other values,
  /// fractions, and overflow.
  /// - Complexity: O(1); the accessor checks one enum case and performs a fixed number of exact numeric conversions.
  public var asInt8: Int8? {
    switch self {
    case .int(let value): Int8(exactly: value)
    case .int64(let value): Int8(exactly: value)
    case .int32(let value): Int8(exactly: value)
    case .int16(let value): Int8(exactly: value)
    case .int8(let value): value
    case .uint(let value): Int8(exactly: value)
    case .uint64(let value): Int8(exactly: value)
    case .uint32(let value): Int8(exactly: value)
    case .uint16(let value): Int8(exactly: value)
    case .uint8(let value): Int8(exactly: value)
    case .double(let value): Int8(exactly: value)
    case .float(let value): Int8(exactly: value)
    case .int128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        Int8(exactly: value.value)
      } else {
        nil
      }
    case .uint128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        Int8(exactly: value.value)
      } else {
        nil
      }
    case .array, .bool, .data, .date, .dictionary, .null, .string: nil
    }
  }

  /// Returns an exactly representable unsigned integer, or nil for other values,
  /// negative values, fractions, and overflow.
  /// - Complexity: O(1); the accessor checks one enum case and performs a fixed number of exact numeric conversions.
  public var asUInt: UInt? {
    switch self {
    case .int(let value): UInt(exactly: value)
    case .int64(let value): UInt(exactly: value)
    case .int32(let value): UInt(exactly: value)
    case .int16(let value): UInt(exactly: value)
    case .int8(let value): UInt(exactly: value)
    case .uint(let value): value
    case .uint64(let value): UInt(exactly: value)
    case .uint32(let value): UInt(exactly: value)
    case .uint16(let value): UInt(exactly: value)
    case .uint8(let value): UInt(exactly: value)
    case .double(let value): UInt(exactly: value)
    case .float(let value): UInt(exactly: value)
    case .int128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        UInt(exactly: value.value)
      } else {
        nil
      }
    case .uint128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        UInt(exactly: value.value)
      } else {
        nil
      }
    case .array, .bool, .data, .date, .dictionary, .null, .string: nil
    }
  }

  /// Returns an exactly representable unsigned 64-bit integer, or nil for other
  /// values, negative values, fractions, and overflow.
  /// - Complexity: O(1); the accessor checks one enum case and performs a fixed number of exact numeric conversions.
  public var asUInt64: UInt64? {
    switch self {
    case .int(let value): UInt64(exactly: value)
    case .int64(let value): UInt64(exactly: value)
    case .int32(let value): UInt64(exactly: value)
    case .int16(let value): UInt64(exactly: value)
    case .int8(let value): UInt64(exactly: value)
    case .uint(let value): UInt64(exactly: value)
    case .uint64(let value): value
    case .uint32(let value): UInt64(exactly: value)
    case .uint16(let value): UInt64(exactly: value)
    case .uint8(let value): UInt64(exactly: value)
    case .double(let value): UInt64(exactly: value)
    case .float(let value): UInt64(exactly: value)
    case .int128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        UInt64(exactly: value.value)
      } else {
        nil
      }
    case .uint128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        UInt64(exactly: value.value)
      } else {
        nil
      }
    case .array, .bool, .data, .date, .dictionary, .null, .string: nil
    }
  }

  /// Returns an exactly representable unsigned 32-bit integer, or nil for other
  /// values, negative values, fractions, and overflow.
  /// - Complexity: O(1); the accessor checks one enum case and performs a fixed number of exact numeric conversions.
  public var asUInt32: UInt32? {
    switch self {
    case .int(let value): UInt32(exactly: value)
    case .int64(let value): UInt32(exactly: value)
    case .int32(let value): UInt32(exactly: value)
    case .int16(let value): UInt32(exactly: value)
    case .int8(let value): UInt32(exactly: value)
    case .uint(let value): UInt32(exactly: value)
    case .uint64(let value): UInt32(exactly: value)
    case .uint32(let value): value
    case .uint16(let value): UInt32(exactly: value)
    case .uint8(let value): UInt32(exactly: value)
    case .double(let value): UInt32(exactly: value)
    case .float(let value): UInt32(exactly: value)
    case .int128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        UInt32(exactly: value.value)
      } else {
        nil
      }
    case .uint128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        UInt32(exactly: value.value)
      } else {
        nil
      }
    case .array, .bool, .data, .date, .dictionary, .null, .string: nil
    }
  }

  /// Returns an exactly representable unsigned 16-bit integer, or nil for other
  /// values, negative values, fractions, and overflow.
  /// - Complexity: O(1); the accessor checks one enum case and performs a fixed number of exact numeric conversions.
  public var asUInt16: UInt16? {
    switch self {
    case .int(let value): UInt16(exactly: value)
    case .int64(let value): UInt16(exactly: value)
    case .int32(let value): UInt16(exactly: value)
    case .int16(let value): UInt16(exactly: value)
    case .int8(let value): UInt16(exactly: value)
    case .uint(let value): UInt16(exactly: value)
    case .uint64(let value): UInt16(exactly: value)
    case .uint32(let value): UInt16(exactly: value)
    case .uint16(let value): value
    case .uint8(let value): UInt16(exactly: value)
    case .double(let value): UInt16(exactly: value)
    case .float(let value): UInt16(exactly: value)
    case .int128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        UInt16(exactly: value.value)
      } else {
        nil
      }
    case .uint128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        UInt16(exactly: value.value)
      } else {
        nil
      }
    case .array, .bool, .data, .date, .dictionary, .null, .string: nil
    }
  }

  /// Returns an exactly representable unsigned 8-bit integer, or nil for other
  /// values, negative values, fractions, and overflow.
  /// - Complexity: O(1); the accessor checks one enum case and performs a fixed number of exact numeric conversions.
  public var asUInt8: UInt8? {
    switch self {
    case .int(let value): UInt8(exactly: value)
    case .int64(let value): UInt8(exactly: value)
    case .int32(let value): UInt8(exactly: value)
    case .int16(let value): UInt8(exactly: value)
    case .int8(let value): UInt8(exactly: value)
    case .uint(let value): UInt8(exactly: value)
    case .uint64(let value): UInt8(exactly: value)
    case .uint32(let value): UInt8(exactly: value)
    case .uint16(let value): UInt8(exactly: value)
    case .uint8(let value): value
    case .double(let value): UInt8(exactly: value)
    case .float(let value): UInt8(exactly: value)
    case .int128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        UInt8(exactly: value.value)
      } else {
        nil
      }
    case .uint128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        UInt8(exactly: value.value)
      } else {
        nil
      }
    case .array, .bool, .data, .date, .dictionary, .null, .string: nil
    }
  }

  /// Returns a floating-point value. Conversion from Double permits rounding
  /// and underflow but rejects finite overflow.
  /// - Complexity: O(1); the accessor checks one enum case and performs a fixed number of exact numeric conversions.
  public var asFloat: Float? {
    switch self {
    case .int(let value): Float(exactly: value)
    case .int64(let value): Float(exactly: value)
    case .int32(let value): Float(exactly: value)
    case .int16(let value): Float(exactly: value)
    case .int8(let value): Float(exactly: value)
    case .uint(let value): Float(exactly: value)
    case .uint64(let value): Float(exactly: value)
    case .uint32(let value): Float(exactly: value)
    case .uint16(let value): Float(exactly: value)
    case .uint8(let value): Float(exactly: value)
    case .double(let value): value.asFloat
    case .float(let value): value
    case .int128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        Float(exactly: value.value)
      } else {
        nil
      }
    case .uint128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        Float(exactly: value.value)
      } else {
        nil
      }
    case .array, .bool, .data, .date, .dictionary, .null, .string: nil
    }
  }

  /// Returns a Double when the numeric value is exactly representable; values
  /// already stored as Float convert without loss of their Float value.
  /// - Complexity: O(1); the accessor checks one enum case and performs a fixed number of exact numeric conversions.
  public var asDouble: Double? {
    switch self {
    case .int(let value): Double(exactly: value)
    case .int64(let value): Double(exactly: value)
    case .int32(let value): Double(exactly: value)
    case .int16(let value): Double(exactly: value)
    case .int8(let value): Double(exactly: value)
    case .uint(let value): Double(exactly: value)
    case .uint64(let value): Double(exactly: value)
    case .uint32(let value): Double(exactly: value)
    case .uint16(let value): Double(exactly: value)
    case .uint8(let value): Double(exactly: value)
    case .double(let value): value
    case .float(let value): Double(value)
    case .int128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        Double(exactly: value.value)
      } else {
        nil
      }
    case .uint128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        Double(exactly: value.value)
      } else {
        nil
      }
    case .array, .bool, .data, .date, .dictionary, .null, .string: nil
    }
  }

  /// Returns the string value, or nil for other cases.
  /// - Complexity: O(1); the accessor checks one enum case and returns the associated value.
  public var asString: String? {
    if case .string(let value) = self { value } else { nil }
  }

  /// Returns the data value, or nil for other cases.
  /// - Complexity: O(1); the accessor checks one enum case and returns the associated value.
  public var asData: Data? {
    if case .data(let value) = self { value } else { nil }
  }

  /// Returns the date value, or nil for other cases.
  /// - Complexity: O(1); the accessor checks one enum case and returns the associated value.
  public var asDate: Date? {
    if case .date(let value) = self { value } else { nil }
  }

  /// Get the array value, or nil for other cases.
  /// - Complexity: O(1); the accessor checks one enum case and returns the associated value.
  public var asArray: [Self]? {
    if case .array(let value) = self { value } else { nil }
  }

  /// Returns the string-keyed dictionary value, or nil for other cases.
  /// - Complexity: O(1); the accessor checks one enum case and returns the associated value.
  public var asDictionary: [String: Self]? {
    if case .dictionary(let value) = self { value } else { nil }
  }

  /// Returns an exactly representable signed 128-bit integer, or nil for other
  /// values, fractions, and overflow.
  /// - Complexity: O(1); the accessor checks one enum case and performs a fixed number of exact numeric conversions.
  @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
  public var asInt128: Int128? {
    switch self {
    case .int(let value): Int128(exactly: value)
    case .int64(let value): Int128(exactly: value)
    case .int32(let value): Int128(exactly: value)
    case .int16(let value): Int128(exactly: value)
    case .int8(let value): Int128(exactly: value)
    case .uint(let value): Int128(exactly: value)
    case .uint64(let value): Int128(exactly: value)
    case .uint32(let value): Int128(exactly: value)
    case .uint16(let value): Int128(exactly: value)
    case .uint8(let value): Int128(exactly: value)
    case .double(let value): Int128(exactly: value)
    case .float(let value): Int128(exactly: value)
    case .int128(let value): value.value
    case .uint128(let value): Int128(exactly: value.value)
    case .array, .bool, .data, .date, .dictionary, .null, .string: nil
    }
  }

  /// Returns an exactly representable unsigned 128-bit integer, or nil for other
  /// values, negative values, fractions, and overflow.
  /// - Complexity: O(1); the accessor checks one enum case and performs a fixed number of exact numeric conversions.
  @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
  public var asUInt128: UInt128? {
    switch self {
    case .int(let value): UInt128(exactly: value)
    case .int64(let value): UInt128(exactly: value)
    case .int32(let value): UInt128(exactly: value)
    case .int16(let value): UInt128(exactly: value)
    case .int8(let value): UInt128(exactly: value)
    case .uint(let value): UInt128(exactly: value)
    case .uint64(let value): UInt128(exactly: value)
    case .uint32(let value): UInt128(exactly: value)
    case .uint16(let value): UInt128(exactly: value)
    case .uint8(let value): UInt128(exactly: value)
    case .double(let value): UInt128(exactly: value)
    case .float(let value): UInt128(exactly: value)
    case .int128(let value): UInt128(exactly: value.value)
    case .uint128(let value): value.value
    case .array, .bool, .data, .date, .dictionary, .null, .string: nil
    }
  }

  /// Decodes a model from this tree, passing userInfo to nested decoders.
  /// - Parameters:
  ///   - type: The model type to decode; defaults to the inferred type.
  ///   - userInfo: Context passed to the decoder and nested decoders.
  /// - Returns: The decoded model.
  /// - Throws: A decoding error when the tree does not match the requested type.
  /// - Complexity: O(n) in the number of tree values; recursive conversion also uses O(d) stack space, where d
  ///   is nesting depth.
  public func decode<T: Decodable>(_: T.Type = T.self, userInfo: [CodingUserInfoKey: Any] = [:]) throws -> T {
    try EnigmaDecoder.decoder(enigma: self, userInfo: userInfo).decode(T.self)
  }
}
