extension Dictionary: Codec.Strategy where Value: Codec.Strategy {
  public typealias BoxedValue = [Key: Value.BoxedValue]
}

extension Dictionary: Codec.DecodeStrategy where Key: Decodable, Value: Codec.DecodeStrategy {
  @inlinable
  public static func decode(decoder: some Decoder) throws -> BoxedValue {
    try [Key: Codec.Box<Value>](from: decoder).mapValues(\.wrappedValue)
  }
}

extension Dictionary: Codec.EncodeStrategy where Key: Encodable, Value: Codec.EncodeStrategy {
  @inlinable
  public static func encode(value: BoxedValue, encoder: some Encoder) throws {
    try value.mapValues { Codec.Box<Value>(wrappedValue: $0) }.encode(to: encoder)
  }
}
