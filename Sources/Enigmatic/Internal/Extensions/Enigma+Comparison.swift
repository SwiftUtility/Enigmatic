import Foundation

extension Enigma {
  func isSame<T: FixedWidthInteger>(integer: T) -> Bool {
    switch self {
    case .int(let value): T(exactly: value) == integer
    case .int64(let value): T(exactly: value) == integer
    case .int32(let value): T(exactly: value) == integer
    case .int16(let value): T(exactly: value) == integer
    case .int8(let value): T(exactly: value) == integer
    case .uint(let value): T(exactly: value) == integer
    case .uint64(let value): T(exactly: value) == integer
    case .uint32(let value): T(exactly: value) == integer
    case .uint16(let value): T(exactly: value) == integer
    case .uint8(let value): T(exactly: value) == integer
    case .double(let value): T(exactly: value) == integer
    case .int128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        T(exactly: value.value) == integer
      } else {
        false
      }
    case .uint128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        T(exactly: value.value) == integer
      } else {
        false
      }
    case .array, .bool, .data, .date, .dictionary, .null, .string: false
    }
  }

  func isSame(double: Double) -> Bool {
    switch self {
    case .int(let value): Int(exactly: double) == value
    case .int64(let value): Int64(exactly: double) == value
    case .int32(let value): Int32(exactly: double) == value
    case .int16(let value): Int16(exactly: double) == value
    case .int8(let value): Int8(exactly: double) == value
    case .uint(let value): UInt(exactly: double) == value
    case .uint64(let value): UInt64(exactly: double) == value
    case .uint32(let value): UInt32(exactly: double) == value
    case .uint16(let value): UInt16(exactly: double) == value
    case .uint8(let value): UInt8(exactly: double) == value
    case .double(let value): double.isSame(double: value)
    case .int128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        Int128(exactly: double) == value.value
      } else {
        false
      }
    case .uint128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        UInt128(exactly: double) == value.value
      } else {
        false
      }
    case .array, .bool, .data, .date, .dictionary, .null, .string: false
    }
  }
}
