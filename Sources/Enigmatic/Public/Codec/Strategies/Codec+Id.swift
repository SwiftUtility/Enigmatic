extension Codec {
  /// Delegates to the wrapped value's own Codable implementation.
  ///
  /// Use `Id` as the strategy when no representation transform is needed.
  public enum Id<BoxedValue>: Hashable, Strategy {}
}

extension Codec.Id: Codec.DecodeStrategy where BoxedValue: Decodable {
  /// Delegates decoding to the boxed type's `Decodable` initializer.
  @inlinable
  public static func decode(decoder: some Decoder) throws -> BoxedValue {
    try BoxedValue(from: decoder)
  }
}

extension Codec.Id: Codec.EncodeStrategy where BoxedValue: Encodable {
  /// Delegates encoding to the boxed type's `Encodable` implementation.
  @inlinable
  public static func encode(value: BoxedValue, encoder: some Encoder) throws {
    try value.encode(to: encoder)
  }
}
