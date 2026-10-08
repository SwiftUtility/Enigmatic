extension Codec {
  protocol OptionalEncoder: Encodable {
    var wrappedValue: Strategy.WrappedBoxedValue? { get }
    associatedtype Strategy: Codec.EncodeOptionalStrategy
  }
}

extension KeyedEncodingContainer {
  mutating func encode<T: Codec.OptionalEncoder>(_ value: T, forKey key: Key) throws {
    guard let value = value.wrappedValue else { return }
    try encode(Codec.OptionalBox<T.Strategy>(wrappedValue: value), forKey: key)
  }
}

extension Codec.Box: Codec.OptionalEncoder where Strategy: Codec.EncodeOptionalStrategy {}
