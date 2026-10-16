@available(macOS 12.3, iOS 15.4, watchOS 8.5, tvOS 15.4, *)
@usableFromInline
protocol CodingKeyedDecoding<Key, Value> {
  associatedtype Key: Hashable & CodingKeyRepresentable
  associatedtype Value: Codec.DecodeStrategy

  static func decodeCodingKeyed(decoder: some Decoder) throws -> [Key: Value.BoxedValue]
}

@available(macOS 12.3, iOS 15.4, watchOS 8.5, tvOS 15.4, *)
extension Dictionary: CodingKeyedDecoding
where Key: CodingKeyRepresentable, Value: Codec.DecodeStrategy {
  @usableFromInline
  static func decodeCodingKeyed(decoder: some Decoder) throws -> [Key: Value.BoxedValue] {
    try Codec.CodingKeyedDictionary<Key, Value>.decode(decoder: decoder)
  }
}
