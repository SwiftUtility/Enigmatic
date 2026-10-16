import Foundation

extension Codec {
  /// Encodes seconds since 1970 as a floating-point value.
  /// Prefer `UnixDate<0>` when the deployment target supports it.
  @available(anyAppleOS, deprecated: 26.0)
  public enum UnixSecondsDate: Hashable, DecodeStrategy, EncodeStrategy, Error {
    /// Decodes finite seconds since 1970 into a date.
    /// - Throws: `DecodingError.dataCorrupted` for non-finite input.
    /// - Complexity: O(1); the operation performs a fixed number of numeric conversions and arithmetic operations.
    @inlinable
    public static func decode(decoder: some Decoder) throws -> BoxedValue {
      let value = try Double(from: decoder)
      guard value.isFinite else {
        throw DecodingError.dataCorrupted(DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: "Not finite timeIntervalSince1970: \(value)"
        ))
      }
      return Date(timeIntervalSince1970: value)
    }

    /// Encodes a date as finite seconds since 1970.
    /// - Throws: `EncodingError.invalidValue` for a non-finite date.
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
      try value.encode(to: encoder)
    }

    /// The value produced by decoding and consumed by encoding.
    public typealias BoxedValue = Date
  }
}
