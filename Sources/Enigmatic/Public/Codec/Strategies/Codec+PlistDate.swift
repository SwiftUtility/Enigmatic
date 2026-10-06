import Foundation

extension Codec {
  /// Encodes seconds since Foundation's reference date (2001-01-01). Non-finite values throw.
  public enum PlistDate: Hashable, DecodeStrategy, EncodeStrategy {
    /// Decodes a finite number of seconds since Foundation's reference date.
    /// - Complexity: O(1); the operation performs a fixed number of numeric conversions and arithmetic operations.
    @inlinable
    public static func decode(decoder: some Decoder) throws -> BoxedValue {
      let timeInterval = try Double(from: decoder)
      guard timeInterval.isFinite else {
        throw DecodingError.dataCorrupted(DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: "Not finite timeIntervalSinceReferenceDate: \(timeInterval)"
        ))
      }
      return Date(timeIntervalSinceReferenceDate: timeInterval)
    }

    /// Encodes seconds since Foundation's reference date, rejecting non-finite values.
    /// - Complexity: O(1); the operation performs a fixed number of numeric conversions and arithmetic operations.
    @inlinable
    public static func encode(value: BoxedValue, encoder: some Encoder) throws {
      let timeInterval = value.timeIntervalSinceReferenceDate
      guard timeInterval.isFinite else {
        throw EncodingError.invalidValue(timeInterval, EncodingError.Context(
          codingPath: encoder.codingPath,
          debugDescription: "Not finite timeIntervalSinceReferenceDate: \(timeInterval)"
        ))
      }
      try timeInterval.encode(to: encoder)
    }

    /// The decoded and encoded value type.
    public typealias BoxedValue = Date
  }
}
