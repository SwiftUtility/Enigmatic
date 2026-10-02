import Foundation

extension Codec {
  /// Encodes seconds since 1970 multiplied by 10 to the given scale as Double.
  ///
  /// Rejects non-finite values, invalid scale factors and unrepresentable results.
  @available(anyAppleOS 26, *)
  public enum UnixDate<let scale: Int>: Hashable, DecodeStrategy, EncodeStrategy {
    @inlinable
    public static func decode(decoder: some Decoder) throws -> BoxedValue {
      let value = try Double(from: decoder)
      guard value.isFinite else {
        throw DecodingError.dataCorrupted(DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: "Not finite timeIntervalSince1970: \(value)"
        ))
      }
      let factor = pow(10.0, Double(Self.scale))
      guard factor.isFinite, factor > 0 else {
        throw DecodingError.dataCorrupted(DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: "Invalid decimal date scale: \(Self.scale)"
        ))
      }
      let scaled = value / factor
      guard scaled.isFinite else {
        throw DecodingError.dataCorrupted(DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: "Not finite timeIntervalSince1970: \(value)/10^\(Self.scale)"
        ))
      }
      return Date(timeIntervalSince1970: scaled)
    }

    @inlinable
    public static func encode(value: BoxedValue, encoder: some Encoder) throws {
      let value = value.timeIntervalSince1970
      guard value.isFinite else {
        throw EncodingError.invalidValue(value, EncodingError.Context(
          codingPath: encoder.codingPath,
          debugDescription: "Not finite timeIntervalSince1970"
        ))
      }
      let factor = pow(10.0, Double(Self.scale))
      guard factor.isFinite, factor > 0 else {
        throw EncodingError.invalidValue(value, EncodingError.Context(
          codingPath: encoder.codingPath,
          debugDescription: "Invalid decimal date scale: \(Self.scale)"
        ))
      }
      let scaled = value * factor
      guard scaled.isFinite else {
        throw EncodingError.invalidValue(value, EncodingError.Context(
          codingPath: encoder.codingPath,
          debugDescription: "Not finite timeIntervalSince1970 after scaling: \(Self.scale)"
        ))
      }
      try scaled.encode(to: encoder)
    }

    public typealias BoxedValue = Date
  }

  @available(anyAppleOS, deprecated: 26.0)
  public enum UnixSecondsDate: Hashable, DecodeStrategy, EncodeStrategy, Error {
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

    public typealias BoxedValue = Date
  }

  @available(anyAppleOS, deprecated: 26.0)
  public enum UnixMillisecondsDate: Hashable, DecodeStrategy, EncodeStrategy, Error {
    @inlinable
    public static func decode(decoder: some Decoder) throws -> BoxedValue {
      let value = try Double(from: decoder)
      guard value.isFinite else {
        throw DecodingError.dataCorrupted(DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: "Not finite timeIntervalSince1970: \(value)"
        ))
      }
      return Date(timeIntervalSince1970: value / 1000)
    }

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
      guard scaled.isFinite else {
        throw EncodingError.invalidValue(value, EncodingError.Context(
          codingPath: encoder.codingPath,
          debugDescription: "Not finite timeIntervalSince1970 after scaling: \(3)"
        ))
      }
      try scaled.encode(to: encoder)
    }

    public typealias BoxedValue = Date
  }
}
