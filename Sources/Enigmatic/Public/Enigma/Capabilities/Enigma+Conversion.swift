import Foundation

extension Enigma {
  /// Creates a tree from Foundation-compatible objects or supported Swift values.
  ///
  /// Use values from `JSONSerialization`, `PropertyListSerialization`, or a YAML parser.
  /// - Parameter cast: The optional root value to convert.
  /// - Throws: An encoding error when a value cannot be represented by Enigma.
  public init(cast value: Any) throws(DecodingError) {
    var pins: [Pin] = []
    self = try Self.make(pins: &pins, value: value)
  }

  /// Encodes a model into a tree, preserving Date and Data at every position.
  /// - Parameters:
  ///   - value: The value to encode.
  ///   - userInfo: Context passed to the encoder and nested encoders.
  /// - Throws: An encoding error when the value cannot be represented.
  public init(encode value: some Encodable, userInfo: [CodingUserInfoKey: Any] = [:]) throws {
    self = try value as? Enigma ?? EnigmaEncoder.encode(value: value, userInfo: userInfo)
  }

  /// Converts the tree to native Swift/Foundation values for templating and inspection.
  ///
  /// - Warning: It is not guaranteed to be compatible with JSONSerialization or PropertyListSerialization
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
  public var asPlistObject: NSObject {
    get throws(EncodingError) {
      var pins = [] as [Pin]
      return try makePlistObject(pins: &pins)
    }
  }

  /// Converts the tree to a Foundation object accepted by `JSONSerialization`.
  ///
  /// - Throws: `EncodingError.invalidValue` for null-incompatible values, data, dates,
  ///   non-finite numbers, and 128-bit integers.
  public var asJsonObject: NSObject {
    get throws(EncodingError) {
      var pins = [] as [Pin]
      return try makeJsonObject(pins: &pins)
    }
  }

  /// Get value if it is Bool
  public var asBool: Bool? {
    if case .bool(let value) = self { value } else { nil }
  }

  /// Get value if it is representable as Int
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

  /// Get value if it is representable as Int64
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

  /// Get value if it is representable as Int32
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

  /// Get value if it is representable as Int16
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

  /// Get value if it is representable as Int8
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

  /// Get value if it is representable as UInt
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

  /// Get value if it is representable as UInt64
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

  /// Get value if it is representable as UInt32
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

  /// Get value if it is representable as UInt16
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

  /// Get value if it is representable as UInt8
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

  /// Get value if it is representable as Float
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

  /// Get value if it is representable as Double
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

  /// Get value if it is representable as String
  public var asString: String? {
    if case .string(let value) = self { value } else { nil }
  }

  /// Get value if it is exactly Data
  public var asData: Data? {
    if case .data(let value) = self { value } else { nil }
  }

  /// Get value if it is exactly Date
  public var asDate: Date? {
    if case .date(let value) = self { value } else { nil }
  }

  /// Get the array value, or nil for other cases.
  public var asArray: [Self]? {
    if case .array(let value) = self { value } else { nil }
  }

  /// Get value if it is Dictionary
  public var asDictionary: [String: Self]? {
    if case .dictionary(let value) = self { value } else { nil }
  }

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
  public func decode<T: Decodable>(_: T.Type = T.self, userInfo: [CodingUserInfoKey: Any] = [:]) throws -> T {
    try EnigmaDecoder.decoder(enigma: self, userInfo: userInfo).decode(T.self)
  }
}
