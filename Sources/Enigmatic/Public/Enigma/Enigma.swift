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
