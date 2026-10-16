extension KeyedEncodingContainer {
  /// Encodes a present optional payload and omits the key when its value is nil.
  /// - Complexity: O(1) for nil; otherwise delegated to the container and strategy.
  public mutating func encode<T: Codec.OptionalEncoder>(_ value: T, forKey key: Key) throws {
    guard let value = value.wrappedValue else { return }
    try encode(Codec.OptionalBox<T.Strategy>(wrappedValue: value), forKey: key)
  }
}
