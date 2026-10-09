extension KeyedDecodingContainer {
  public func decode<T: Codec.OptionalDecoder>(_ type: T.Type, forKey key: Key) throws -> T {
    guard contains(key) else { return T(wrappedValue: nil) }
    return try T(wrappedValue: decodeIfPresent(Codec.OptionalBox<T.Strategy>.self, forKey: key)?.wrappedValue)
  }
}
