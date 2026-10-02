extension Codec {
  /// Applies a strategy to a property while exposing its unwrapped value.
  ///
  /// An optional strategy accepts null; synthesized decoding still requires the key.
  @propertyWrapper
  public struct Box<Strategy: Codec.Strategy> {
    public var wrappedValue: Strategy.BoxedValue

    @inlinable
    public init(wrappedValue: Strategy.BoxedValue) {
      self.wrappedValue = wrappedValue
    }
  }
}

extension Codec.Box: Decodable where Strategy: Codec.DecodeStrategy {
  @inlinable
  public init(from decoder: any Decoder) throws {
    self.wrappedValue = try Strategy.decode(decoder: decoder)
  }
}

extension Codec.Box: Encodable where Strategy: Codec.EncodeStrategy {
  @inlinable
  public func encode(to encoder: any Encoder) throws {
    try Strategy.encode(value: wrappedValue, encoder: encoder)
  }
}

extension Codec.Box: Sendable where Strategy.BoxedValue: Sendable {}

extension Codec.Box: Equatable where Strategy.BoxedValue: Equatable {
  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension Codec.Box: Hashable where Strategy.BoxedValue: Hashable {
  @inlinable
  public func hash(into hasher: inout Hasher) {
    wrappedValue.hash(into: &hasher)
  }
}

extension Codec.Box: CustomStringConvertible {
  @inlinable
  public var description: String {
    String(describing: wrappedValue)
  }
}

extension Codec.Box: CustomDebugStringConvertible {
  @inlinable
  public var debugDescription: String {
    String(reflecting: wrappedValue)
  }
}

protocol DecodeOptionalCodecBox: Decodable {
  init(wrappedValue: Strategy.WrappedBoxedValue?)
  associatedtype Strategy: Codec.DecodeOptionalStrategy
}

extension Codec.Box: DecodeOptionalCodecBox where Strategy: Codec.DecodeOptionalStrategy {}

protocol EncodeOptionalCodecBox: Encodable {
  var wrappedValue: Strategy.WrappedBoxedValue? { get }
  associatedtype Strategy: Codec.EncodeOptionalStrategy
}

extension Codec.Box: EncodeOptionalCodecBox where Strategy: Codec.EncodeOptionalStrategy {}

extension KeyedDecodingContainer {
  func decode<T: DecodeOptionalCodecBox>(_ type: T.Type, forKey key: Key) throws -> T {
    guard contains(key) else { return T(wrappedValue: nil) }
    return try T(wrappedValue: decodeIfPresent(Codec.OptionalBox<T.Strategy>.self, forKey: key)?.wrappedValue)
  }
}

extension KeyedEncodingContainer {
  mutating func encode<T: EncodeOptionalCodecBox>(_ value: T, forKey key: Key) throws {
    guard let value = value.wrappedValue else { return }
    try encode(Codec.OptionalBox<T.Strategy>(wrappedValue: value), forKey: key)
  }
}
