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
    case .double(let value): value.isSame(integer: integer)
    case .float(let value): value.isSame(integer: integer)
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
    case .int(let value): double.isSame(integer: value)
    case .int64(let value): double.isSame(integer: value)
    case .int32(let value): double.isSame(integer: value)
    case .int16(let value): double.isSame(integer: value)
    case .int8(let value): double.isSame(integer: value)
    case .uint(let value): double.isSame(integer: value)
    case .uint64(let value): double.isSame(integer: value)
    case .uint32(let value): double.isSame(integer: value)
    case .uint16(let value): double.isSame(integer: value)
    case .uint8(let value): double.isSame(integer: value)
    case .double(let value): double.isSame(double: value)
    case .float(let value): value.isSame(double: double)
    case .int128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        double.isSame(integer: value.value)
      } else {
        false
      }
    case .uint128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        double.isSame(integer: value.value)
      } else {
        false
      }
    case .array, .bool, .data, .date, .dictionary, .null, .string: false
    }
  }

  func isSame(float: Float) -> Bool {
    switch self {
    case .int(let value): float.isSame(integer: value)
    case .int64(let value): float.isSame(integer: value)
    case .int32(let value): float.isSame(integer: value)
    case .int16(let value): float.isSame(integer: value)
    case .int8(let value): float.isSame(integer: value)
    case .uint(let value): float.isSame(integer: value)
    case .uint64(let value): float.isSame(integer: value)
    case .uint32(let value): float.isSame(integer: value)
    case .uint16(let value): float.isSame(integer: value)
    case .uint8(let value): float.isSame(integer: value)
    case .double(let value): float.isSame(double: value)
    case .float(let value): float.isSame(float: value)
    case .int128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        float.isSame(integer: value.value)
      } else {
        false
      }
    case .uint128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        float.isSame(integer: value.value)
      } else {
        false
      }
    case .array, .bool, .data, .date, .dictionary, .null, .string: false
    }
  }
}
