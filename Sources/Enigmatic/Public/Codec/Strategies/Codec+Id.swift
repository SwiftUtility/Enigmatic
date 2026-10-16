extension Codec {
  /// Delegates to the wrapped value's own Codable implementation.
  ///
  /// Calls the value's Codable methods directly, bypassing encoder/decoder
  /// handling specific to Date and Data. Those types use Foundation's own
  /// representation; their native Enigma cases cannot be decoded through Id.
  public enum Id<BoxedValue>: Hashable, Strategy {}
}

extension Codec.Id: Codec.DecodeStrategy where BoxedValue: Decodable {
  /// Delegates decoding to the boxed type's `Decodable` initializer.
  /// - Complexity: Delegated to the wrapped value’s Codable implementation.
  @inlinable
  public static func decode(decoder: some Decoder) throws -> BoxedValue {
    try BoxedValue(from: decoder)
  }
}

extension Codec.Id: Codec.EncodeStrategy where BoxedValue: Encodable {
  /// Delegates encoding to the boxed type's `Encodable` implementation.
  /// - Complexity: Delegated to the wrapped value’s Codable implementation.
  @inlinable
  public static func encode(value: BoxedValue, encoder: some Encoder) throws {
    try value.encode(to: encoder)
  }
}
