extension KeyedEncodingContainer {
  public mutating func encode<T: Codec.OptionalEncoder>(_ value: T, forKey key: Key) throws {
    guard let value = value.wrappedValue else { return }
    try encode(Codec.OptionalBox<T.Strategy>(wrappedValue: value), forKey: key)
  }
}
