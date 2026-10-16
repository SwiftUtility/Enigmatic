extension Dictionary: Codec.Strategy where Value: Codec.Strategy {
  /// A dictionary whose values use the boxed representation of `Value`.
  public typealias BoxedValue = [Key: Value.BoxedValue]
}

@available(macOS 12.3, iOS 15.4, watchOS 8.5, tvOS 15.4, *)
extension Dictionary where Key: Hashable & CodingKeyRepresentable, Value: Codec.Strategy {
  /// An explicitly keyed strategy that does not require Codable keys.
  public typealias CodingKeyed = Codec.CodingKeyedDictionary<Key, Value>
}

extension Dictionary: Codec.DecodeStrategy where Key: Decodable, Value: Codec.DecodeStrategy {
  /// Decodes keyed values using `Value`'s strategy.
  /// - Complexity: O(n) expected dictionary visits and strategy calls, plus the sum of value strategy costs,
  ///   where n is the entry count.
  @inlinable
  public static func decode(decoder: some Decoder) throws -> BoxedValue {
    if
      #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *),
      let type = [Key: Value].self as? any CodingKeyedDecoding<Key, Value>.Type
    {
      try type.decodeCodingKeyed(decoder: decoder)
    } else {
      try [Key: Codec.Box<Value>](from: decoder).mapValues(\.wrappedValue)
    }
  }
}

extension Dictionary: Codec.EncodeStrategy where Key: Encodable, Value: Codec.EncodeStrategy {
  /// Encodes keyed values using `Value`'s strategy.
  /// - Complexity: O(n) expected dictionary visits and strategy calls, plus the sum of value strategy costs,
  ///   where n is the entry count.
  @inlinable
  public static func encode(value: BoxedValue, encoder: some Encoder) throws {
    if
      #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *),
      let type = [Key: Value].self as? any CodingKeyedEncoding<Key, Value>.Type
    {
      try type.encodeCodingKeyed(value: value, encoder: encoder)
    } else {
      try value.mapValues { Codec.Box<Value>(wrappedValue: $0) }.encode(to: encoder)
    }
  }
}
