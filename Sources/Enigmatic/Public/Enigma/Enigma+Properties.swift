import Foundation

public extension Enigma {
  /// Convert Enigma to Any usable with [Stencil](https://github.com/stencilproject/Stencil) render
  ///
  /// - Warning: It is not guaranteed to be compatible with JSONSerialization or PropertyListSerialization
  var rawAny: Any {
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
    case .array(let value): value.map(\.rawAny)
    case .dictionary(let value): value.mapValues(\.rawAny)
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

  /// Convert Enigma to NSObject compatible with PropertyListSerialization
  var plistObject: NSObject {
    get throws(EncodingError) {
      try Reducer.reduce(seed: [], self, Self.makePlistObject(reducer:))
    }
  }

  /// Convert Enigma to NSObject compatible with JSONSerialization
  var jsonObject: NSObject {
    get throws(EncodingError) {
      try Reducer.reduce(seed: [], self, Self.makeJsonObject(reducer:))
    }
  }

  /// Get the array value, or an empty array for other cases.
  var array: [Self] {
    get { asArray ?? [] }
    set { self = .array(newValue) }
  }

  /// Get value if it is Dictionary, empty dictionary otherwise
  var dictionary: [String: Self] {
    get { asDictionary ?? [:] }
    set { self = .dictionary(newValue) }
  }

  /// Paths of all descendants, including containers, excluding the root.
  ///
  /// Traversal is depth first, with ascending array indices and sorted dictionary keys.
  var paths: [[Pin]] {
    var result: [[Pin]] = []
    var current: [Pin] = []
    collectPins(into: &result, current: &current)
    return result
  }

  /// Test if root value is null
  var isNull: Bool {
    if case .null = self { true } else { false }
  }

  var isArray: Bool {
    if case .array = self { true } else { false }
  }

  var isDictionary: Bool {
    if case .dictionary = self { true } else { false }
  }

  /// Get value if it is Bool
  var asBool: Bool? {
    if case .bool(let value) = self { value } else { nil }
  }

  /// Get value if it is representable as Int
  var asInt: Int? {
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
  var asInt64: Int64? {
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
  var asInt32: Int32? {
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
  var asInt16: Int16? {
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
  var asInt8: Int8? {
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
  var asUInt: UInt? {
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
  var asUInt64: UInt64? {
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
  var asUInt32: UInt32? {
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
  var asUInt16: UInt16? {
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
  var asUInt8: UInt8? {
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
  var asFloat: Float? {
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
  var asDouble: Double? {
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
  var asString: String? {
    if case .string(let value) = self { value } else { nil }
  }

  /// Get value if it is exactly Data
  var asData: Data? {
    if case .data(let value) = self { value } else { nil }
  }

  /// Get value if it is exactly Date
  var asDate: Date? {
    if case .date(let value) = self { value } else { nil }
  }

  /// Get the array value, or nil for other cases.
  var asArray: [Self]? {
    if case .array(let value) = self { value } else { nil }
  }

  /// Get value if it is Dictionary
  var asDictionary: [String: Self]? {
    if case .dictionary(let value) = self { value } else { nil }
  }

  @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
  var asInt128: Int128? {
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
  var asUInt128: UInt128? {
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
}
