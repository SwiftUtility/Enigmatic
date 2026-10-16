import Foundation

extension Codec {
  /// Encodes seconds since 1970 as a truncated integer.
  /// Prefer `UnixIntDate<0>` when the deployment target supports it.
  @available(anyAppleOS, deprecated: 26.0)
  public enum UnixIntSecondsDate: Hashable, DecodeStrategy, EncodeStrategy, Error {
    /// Decodes integer seconds since 1970 into a date.
    /// - Complexity: O(1); the operation performs a fixed number of numeric conversions and arithmetic operations.
    @inlinable
    public static func decode(decoder: some Decoder) throws -> BoxedValue {
      try Date(timeIntervalSince1970: Double(Int(from: decoder)))
    }

    /// Encodes finite seconds since 1970 as an integer truncated toward zero.
    /// - Throws: `EncodingError.invalidValue` for non-finite values or integer overflow.
    /// - Complexity: O(1); the operation performs a fixed number of numeric conversions and arithmetic operations.
    @inlinable
    public static func encode(value: BoxedValue, encoder: some Encoder) throws {
      let value = value.timeIntervalSince1970
      guard value.isFinite else {
        throw EncodingError.invalidValue(value, EncodingError.Context(
          codingPath: encoder.codingPath,
          debugDescription: "Not finite timeIntervalSince1970"
        ))
      }
      guard value < Double(Int.max), value >= Double(Int.min) else {
        throw EncodingError.invalidValue(value, EncodingError.Context(
          codingPath: encoder.codingPath,
          debugDescription: "timeIntervalSince1970 out of Int bounds"
        ))
      }
      try Int(value).encode(to: encoder)
    }

    /// The value produced by decoding and consumed by encoding.
    public typealias BoxedValue = Date
  }
}
