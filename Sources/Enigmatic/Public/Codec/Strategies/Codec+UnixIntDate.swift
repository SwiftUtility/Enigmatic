import Foundation

extension Codec {
  /// Encodes seconds since 1970 multiplied by 10 to the given scale as Int, truncating toward zero.
  ///
  /// Rejects non-finite values, invalid scale factors and unrepresentable results.
  @available(anyAppleOS 26, *)
  public enum UnixIntDate<let scale: Int>: Hashable, DecodeStrategy, EncodeStrategy, Error {
    @inlinable
    public static func decode(decoder: some Decoder) throws -> BoxedValue {
      let value = try Double(Int(from: decoder))
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
      guard scaled < Double(Int.max), scaled >= Double(Int.min) else {
        throw EncodingError.invalidValue(value, EncodingError.Context(
          codingPath: encoder.codingPath,
          debugDescription: "timeIntervalSince1970 out of Int bounds"
        ))
      }
      try Int(scaled).encode(to: encoder)
    }

    public typealias BoxedValue = Date
  }

  @available(anyAppleOS, deprecated: 26.0)
  public enum UnixIntSecondsDate: Hashable, DecodeStrategy, EncodeStrategy, Error {
    @inlinable
    public static func decode(decoder: some Decoder) throws -> BoxedValue {
      try Date(timeIntervalSince1970: Double(Int(from: decoder)))
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
      guard value < Double(Int.max), value >= Double(Int.min) else {
        throw EncodingError.invalidValue(value, EncodingError.Context(
          codingPath: encoder.codingPath,
          debugDescription: "timeIntervalSince1970 out of Int bounds"
        ))
      }
      try Int(value).encode(to: encoder)
    }

    public typealias BoxedValue = Date
  }

  @available(anyAppleOS, deprecated: 26.0)
  public enum UnixIntMillisecondsDate: Hashable, DecodeStrategy, EncodeStrategy {
    @inlinable
    public static func decode(decoder: some Decoder) throws -> BoxedValue {
      try Date(timeIntervalSince1970: Double(Int(from: decoder)) / 1000)
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
      guard scaled < Double(Int.max), scaled >= Double(Int.min) else {
        throw EncodingError.invalidValue(value, EncodingError.Context(
          codingPath: encoder.codingPath,
          debugDescription: "timeIntervalSince1970 out of Int bounds"
        ))
      }
      try Int(scaled).encode(to: encoder)
    }

    public typealias BoxedValue = Date
  }
}
