extension Optional: Codec.Strategy, Codec.OptionalStrategy where Wrapped: Codec.Strategy {
  public typealias BoxedValue = Wrapped.BoxedValue?
  public typealias WrappedBoxedValue = Wrapped.BoxedValue
}

extension Optional: Codec.DecodeStrategy, Codec.DecodeOptionalStrategy
where Wrapped: Codec.DecodeStrategy {
  @inlinable
  public static func decode(decoder: some Decoder) throws -> BoxedValue {
    try Codec.Box<Wrapped>?(from: decoder)?.wrappedValue
  }

  @inlinable
  public static func decodePresent(decoder: some Decoder) throws -> WrappedBoxedValue {
    try Wrapped.decode(decoder: decoder)
  }
}

extension Optional: Codec.EncodeStrategy, Codec.EncodeOptionalStrategy
where Wrapped: Codec.EncodeStrategy {
  @inlinable
  public static func encode(value: BoxedValue, encoder: some Encoder) throws {
    let mask: Codec.Box<Wrapped>? = if let value {
      Codec.Box<Wrapped>(wrappedValue: value)
    } else {
      nil
    }
    try mask.encode(to: encoder)
  }

  @inlinable
  public static func encodePresent(value: WrappedBoxedValue, encoder: some Encoder) throws {
    try Wrapped.encode(value: value, encoder: encoder)
  }
}
