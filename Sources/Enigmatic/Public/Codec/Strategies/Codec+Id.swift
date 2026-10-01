extension Codec {
  public enum Id<BoxedValue>: Strategy {}
}

extension Codec.Id: Codec.DecodeStrategy where BoxedValue: Decodable {
  @inlinable
  public static func decode(decoder: some Decoder) throws -> BoxedValue {
    try BoxedValue(from: decoder)
  }
}

extension Codec.Id: Codec.EncodeStrategy where BoxedValue: Encodable {
  @inlinable
  public static func encode(value: BoxedValue, encoder: some Encoder) throws {
    try value.encode(to: encoder)
  }
}
