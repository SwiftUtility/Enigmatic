import Foundation

extension Codec {
  /// Encodes milliseconds since 1970 as a truncated integer.
  /// Prefer `UnixIntDate<3>` when both the compiler (Swift 6.2.3 or newer) and
  /// deployment target support it.
#if compiler(>=6.3)
  @available(anyAppleOS, deprecated: 26.0)
#elseif compiler(>=6.2.3)
  @available(macOS, deprecated: 26.0)
  @available(iOS, deprecated: 26.0)
  @available(tvOS, deprecated: 26.0)
  @available(watchOS, deprecated: 26.0)
  @available(visionOS, deprecated: 26.0)
#endif
  public enum UnixIntMillisecondsDate: Hashable, DecodeStrategy, EncodeStrategy {
    /// Decodes integer milliseconds since 1970 into a date.
    /// - Complexity: O(1); the operation performs a fixed number of numeric conversions and arithmetic operations.
    @inlinable
    public static func decode(decoder: some Decoder) throws -> BoxedValue {
      try Date(timeIntervalSince1970: Double(Int(from: decoder)) / 1000)
    }

    /// Encodes finite milliseconds since 1970 as an integer truncated toward zero.
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
      let scaled = value * 1000
      guard scaled < Double(Int.max), scaled >= Double(Int.min) else {
        throw EncodingError.invalidValue(value, EncodingError.Context(
          codingPath: encoder.codingPath,
          debugDescription: "timeIntervalSince1970 out of Int bounds"
        ))
      }
      try Int(scaled).encode(to: encoder)
    }

    /// The value produced by decoding and consumed by encoding.
    public typealias BoxedValue = Date
  }
}
