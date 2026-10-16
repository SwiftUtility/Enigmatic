@available(macOS 12.3, iOS 15.4, watchOS 8.5, tvOS 15.4, *)
@usableFromInline
protocol CodingKeyedEncoding<Key, Value> {
  associatedtype Key: Hashable & CodingKeyRepresentable
  associatedtype Value: Codec.EncodeStrategy

  static func encodeCodingKeyed(value: [Key: Value.BoxedValue], encoder: some Encoder) throws
}

@available(macOS 12.3, iOS 15.4, watchOS 8.5, tvOS 15.4, *)
extension Dictionary: CodingKeyedEncoding
where Key: CodingKeyRepresentable, Value: Codec.EncodeStrategy {
  @usableFromInline
  static func encodeCodingKeyed(value: [Key: Value.BoxedValue], encoder: some Encoder) throws {
    try Codec.CodingKeyedDictionary<Key, Value>.encode(value: value, encoder: encoder)
  }
}
