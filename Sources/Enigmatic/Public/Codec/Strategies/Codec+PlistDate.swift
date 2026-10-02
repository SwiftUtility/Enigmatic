import Foundation

extension Codec {
  /// Encodes seconds since Foundation's reference date (2001-01-01). Non-finite values throw.
  public enum PlistDate: Hashable, DecodeStrategy, EncodeStrategy {
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

    public typealias BoxedValue = Date
  }
}
