import Foundation

extension Codec {
  /// Encodes seconds since 1970 multiplied by 10 to the given scale as Int, truncating toward zero.
  ///
  /// Rejects non-finite values, invalid scale factors and unrepresentable results.
  @available(anyAppleOS 26, *)
  public enum UnixIntDate<let scale: Int>: Hashable, DecodeStrategy, EncodeStrategy, Error {
    /// Decodes an integer scaled timestamp into a date.
    /// - Throws: `DecodingError.dataCorrupted` when the scale is invalid or the result is non-finite.
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

    /// Encodes scaled seconds, truncating toward zero.
    /// - Throws: `EncodingError.invalidValue` for invalid scales or integer overflow.
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

    /// The value produced by decoding and consumed by encoding.
    public typealias BoxedValue = Date
  }

  /// Encodes seconds since 1970 as a truncated integer.
  /// Prefer `UnixIntDate<0>` when the deployment target supports it.
  @available(anyAppleOS, deprecated: 26.0)
  public enum UnixIntSecondsDate: Hashable, DecodeStrategy, EncodeStrategy, Error {
    /// Decodes integer seconds since 1970 into a date.
    @inlinable
    public static func decode(decoder: some Decoder) throws -> BoxedValue {
      try Date(timeIntervalSince1970: Double(Int(from: decoder)))
    }

    /// Encodes finite seconds since 1970 as an integer truncated toward zero.
    /// - Throws: `EncodingError.invalidValue` for non-finite values or integer overflow.
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

  /// Encodes milliseconds since 1970 as a truncated integer.
  /// Prefer `UnixIntDate<3>` when the deployment target supports it.
  @available(anyAppleOS, deprecated: 26.0)
  public enum UnixIntMillisecondsDate: Hashable, DecodeStrategy, EncodeStrategy {
    /// Decodes integer milliseconds since 1970 into a date.
    @inlinable
    public static func decode(decoder: some Decoder) throws -> BoxedValue {
      try Date(timeIntervalSince1970: Double(Int(from: decoder)) / 1000)
    }

    /// Encodes finite milliseconds since 1970 as an integer truncated toward zero.
    /// - Throws: `EncodingError.invalidValue` for non-finite values or integer overflow.
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
