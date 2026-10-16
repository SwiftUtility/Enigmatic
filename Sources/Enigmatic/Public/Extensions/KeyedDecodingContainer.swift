extension KeyedDecodingContainer {
  /// Decodes a present optional payload, or initializes the wrapper with nil
  /// when the key is missing or null.
  /// - Complexity: Delegated to the container and the optional strategy.
  public func decode<T: Codec.OptionalDecoder>(_ type: T.Type, forKey key: Key) throws -> T {
    guard contains(key) else { return T(wrappedValue: nil) }
    return try T(wrappedValue: decodeIfPresent(Codec.OptionalBox<T.Strategy>.self, forKey: key)?.wrappedValue)
  }
}
