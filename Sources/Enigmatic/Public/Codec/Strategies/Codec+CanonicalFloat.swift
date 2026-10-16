extension Codec {
  /// Represents a Float as a Double using its shortest decimal spelling.
  /// Preserves signed zero and non-finite values; decoding rejects finite overflow
  /// and nonzero underflow to zero.
  public enum CanonicalFloat: Hashable, DecodeStrategy, EncodeStrategy {
    /// Parses the decoded Double's decimal spelling as Float.
    @inlinable
    public static func decode(decoder: some Decoder) throws -> BoxedValue {
      let value = try Double(from: decoder)
      guard value.isFinite, !value.isZero else { return Float(value) }
      let description = value.description
      guard let result = Float(description) else {
        throw DecodingError.dataCorrupted(DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: "failed to create Float from \(description)"
        ))
      }
      guard result.isFinite else {
        throw DecodingError.dataCorrupted(DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: "Float overflow from \(description)"
        ))
      }
      guard !result.isZero else {
        throw DecodingError.dataCorrupted(DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: "Float underflow from \(description)"
        ))
      }
      return result
    }

    /// Encodes the Float's decimal spelling as Double.
    @inlinable
    public static func encode(value: BoxedValue, encoder: some Encoder) throws {
      guard value.isFinite, !value.isZero else { return try Double(value).encode(to: encoder) }
      let description = value.description
      guard let value = Double(description) else {
        throw EncodingError.invalidValue(description, EncodingError.Context(
          codingPath: encoder.codingPath,
          debugDescription: "failed to create double"
        ))
      }
      try value.encode(to: encoder)
    }

    /// The decoded and encoded value type.
    public typealias BoxedValue = Float
  }
}
