import Foundation

public extension Enigma {
  /// Convert Enigma to AnyObject
  ///
  /// - Note: It is usable with JSONSerialization
  ///   and [Stencil](https://github.com/stencilproject/Stencil) render
  var anyObject: NSObject {
    switch self {
    case .null: NSNull()
    case .bool(let value): value as NSNumber
    case .int(let value): value as NSNumber
    case .int64(let value): value as NSNumber
    case .int32(let value): value as NSNumber
    case .int16(let value): value as NSNumber
    case .int8(let value): value as NSNumber
    case .uint(let value): value as NSNumber
    case .uint64(let value): value as NSNumber
    case .uint32(let value): value as NSNumber
    case .uint16(let value): value as NSNumber
    case .uint8(let value): value as NSNumber
    case .double(let value): value as NSNumber
    case .float(let value): value as NSNumber
    case .string(let value): value as NSString
    case .array(let array): array.map(\.anyObject) as NSArray
    case .dictionary(let dictionary): dictionary.mapValues(\.anyObject) as NSDictionary
    case .data(let data): Array(data) as NSArray
    case .date(let date): date.timeIntervalSinceReferenceDate as NSNumber
    }
  }

  /// Get value if it is Array, emply Dictionary or Data, empty array otherwise
  var array: [Self] {
    get { asArray ?? [] }
    set { self = .array(newValue) }
  }

  /// Get value if it is Dictionary, empty dictionary otherwise
  var dictionary: [String: Self] {
    get { asDictionary ?? [:] }
    set { self = .dictionary(newValue) }
  }

  var pathes: [[Pin]] {
    var result: [[Pin]] = []
    var current: [Pin] = []
    collectPins(into: &result, current: &current)
    result.removeLast()
    return result
  }

  /// Test if root value is null
  var isNull: Bool {
    if case .null = self { true } else { false }
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
    case .date(let value): Int(exactly: value.timeIntervalSinceReferenceDate)
    default: nil
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
    case .date(let value): Int64(exactly: value.timeIntervalSinceReferenceDate)
    default: nil
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
    case .date(let value): Int32(exactly: value.timeIntervalSinceReferenceDate)
    default: nil
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
    case .date(let value): Int16(exactly: value.timeIntervalSinceReferenceDate)
    default: nil
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
    case .date(let value): Int8(exactly: value.timeIntervalSinceReferenceDate)
    default: nil
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
    case .date(let value): UInt(exactly: value.timeIntervalSinceReferenceDate)
    default: nil
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
    case .date(let value): UInt64(exactly: value.timeIntervalSinceReferenceDate)
    default: nil
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
    case .date(let value): UInt32(exactly: value.timeIntervalSinceReferenceDate)
    default: nil
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
    case .date(let value): UInt16(exactly: value.timeIntervalSinceReferenceDate)
    default: nil
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
    case .date(let value): UInt8(exactly: value.timeIntervalSinceReferenceDate)
    default: nil
    }
  }

  /// Get value if it is representable as Float
  var asFloat: Float? {
    switch self {
    case .int(let value): Float(value)
    case .int64(let value): Float(value)
    case .int32(let value): Float(value)
    case .int16(let value): Float(value)
    case .int8(let value): Float(value)
    case .uint(let value): Float(value)
    case .uint64(let value): Float(value)
    case .uint32(let value): Float(value)
    case .uint16(let value): Float(value)
    case .uint8(let value): Float(value)
    case .double(let value): value.asFloat
    case .float(let value): value
    case .date(let value): value.timeIntervalSinceReferenceDate.asFloat
    default: nil
    }
  }

  /// Get value if it is representable as Double
  var asDouble: Double? {
    switch self {
    case .int(let value): Double(value)
    case .int64(let value): Double(value)
    case .int32(let value): Double(value)
    case .int16(let value): Double(value)
    case .int8(let value): Double(value)
    case .uint(let value): Double(value)
    case .uint64(let value): Double(value)
    case .uint32(let value): Double(value)
    case .uint16(let value): Double(value)
    case .uint8(let value): Double(value)
    case .double(let value): value
    case .float(let value): Double(value)
    case .date(let value): value.timeIntervalSinceReferenceDate
    default: nil
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

  /// Get value if it is Array, emply Dictionary or Data
  var asArray: [Self]? {
    switch self {
    case .array(let value): value
    case .dictionary([:]): []
    case .data(let data): data.map(Enigma.uint8(_:))
    default: nil
    }
  }

  /// Get value if it is Dictionary
  var asDictionary: [String: Self]? {
    if case .dictionary(let value) = self { value } else { nil }
  }
}
