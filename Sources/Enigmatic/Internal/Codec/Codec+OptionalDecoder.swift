extension Codec {
  protocol OptionalDecoder: Decodable {
    init(wrappedValue: Strategy.WrappedBoxedValue?)
    associatedtype Strategy: Codec.DecodeOptionalStrategy
  }
}

extension KeyedDecodingContainer {
  func decode<T: Codec.OptionalDecoder>(_ type: T.Type, forKey key: Key) throws -> T {
    guard contains(key) else { return T(wrappedValue: nil) }
    return try T(wrappedValue: decodeIfPresent(Codec.OptionalBox<T.Strategy>.self, forKey: key)?.wrappedValue)
  }
}

extension Codec.Box: Codec.OptionalDecoder where Strategy: Codec.DecodeOptionalStrategy {}
