extension Optional: Codec.Strategy where Wrapped: Codec.Strategy {
  public typealias BoxedValue = Wrapped.BoxedValue?
}

extension Optional: Codec.DecodeStrategy where Wrapped: Codec.DecodeStrategy {
  @inlinable
  public static func decode(decoder: some Decoder) throws -> BoxedValue {
    try Codec.Box<Wrapped>?(from: decoder)?.wrappedValue
  }
}

extension Optional: Codec.EncodeStrategy where Wrapped: Codec.EncodeStrategy {
  @inlinable
  public static func encode(value: BoxedValue, encoder: some Encoder) throws {
    let mask: Codec.Box<Wrapped>? = if let value {
      Codec.Box<Wrapped>(wrappedValue: value)
    } else {
      nil
    }
    try mask.encode(to: encoder)
  }
}
