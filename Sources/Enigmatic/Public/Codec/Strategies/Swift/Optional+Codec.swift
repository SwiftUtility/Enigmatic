extension Optional: Codec.Strategy, Codec.OptionalStrategy where Wrapped: Codec.Strategy {
  /// The optional form of the wrapped strategy's boxed value.
  public typealias BoxedValue = Wrapped.BoxedValue?
  /// The wrapped strategy's boxed value when this optional is present.
  public typealias WrappedBoxedValue = Wrapped.BoxedValue
}

extension Optional: Codec.DecodeStrategy, Codec.DecodeOptionalStrategy
where Wrapped: Codec.DecodeStrategy {
  /// Decodes an optional value, accepting a null representation.
  @inlinable
  public static func decode(decoder: some Decoder) throws -> BoxedValue {
    try Codec.Box<Wrapped>?(from: decoder)?.wrappedValue
  }

  /// Decodes the present payload by delegating to the wrapped strategy.
  @inlinable
  public static func decodePresent(decoder: some Decoder) throws -> WrappedBoxedValue {
    try Wrapped.decode(decoder: decoder)
  }
}

extension Optional: Codec.EncodeStrategy, Codec.EncodeOptionalStrategy
where Wrapped: Codec.EncodeStrategy {
  /// Encodes the optional value, writing null when it is nil.
  @inlinable
  public static func encode(value: BoxedValue, encoder: some Encoder) throws {
    let mask: Codec.Box<Wrapped>? = if let value {
      Codec.Box<Wrapped>(wrappedValue: value)
    } else {
      nil
    }
    try mask.encode(to: encoder)
  }

  /// Encodes a present payload by delegating to the wrapped strategy.
  @inlinable
  public static func encodePresent(value: WrappedBoxedValue, encoder: some Encoder) throws {
    try Wrapped.encode(value: value, encoder: encoder)
  }
}
