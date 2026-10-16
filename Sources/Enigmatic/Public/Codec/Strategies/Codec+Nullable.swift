extension Codec {
  /// Applies a strategy to an optional value while retaining explicit null keys.
  ///
  /// A boxed property requires its key during decoding, accepts null as nil,
  /// and encodes nil as null. Use an optional strategy instead to accept missing
  /// keys and omit nil properties from keyed output.
  public enum Nullable<Wrapped: Strategy>: Hashable, Strategy {
    /// The optional form of the wrapped strategy's boxed value.
    public typealias BoxedValue = Wrapped.BoxedValue?
  }
}

extension Codec.Nullable: Codec.DecodeStrategy where Wrapped: Codec.DecodeStrategy {
  /// Decodes null as nil, otherwise delegates to the wrapped strategy.
  /// - Complexity: O(1) for nil; otherwise the cost of the wrapped strategy.
  @inlinable
  public static func decode(decoder: some Decoder) throws -> BoxedValue {
    try Wrapped?.decode(decoder: decoder)
  }
}

extension Codec.Nullable: Codec.EncodeStrategy where Wrapped: Codec.EncodeStrategy {
  /// Writes null for nil, otherwise delegates to the wrapped strategy.
  /// - Complexity: O(1) for nil; otherwise the cost of the wrapped strategy.
  @inlinable
  public static func encode(value: BoxedValue, encoder: some Encoder) throws {
    try Wrapped?.encode(value: value, encoder: encoder)
  }
}
