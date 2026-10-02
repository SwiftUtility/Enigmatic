extension Codec {
  public struct OptionalBox<Strategy: Codec.OptionalStrategy> {
    public var wrappedValue: Strategy.WrappedBoxedValue

    @inlinable
    public init(wrappedValue: Strategy.WrappedBoxedValue) {
      self.wrappedValue = wrappedValue
    }
  }
}

extension Codec.OptionalBox: Decodable where Strategy: Codec.DecodeOptionalStrategy {
  @inlinable
  public init(from decoder: any Decoder) throws {
    self.wrappedValue = try Strategy.decodePresent(decoder: decoder)
  }
}

extension Codec.OptionalBox: Encodable where Strategy: Codec.EncodeOptionalStrategy {
  @inlinable
  public func encode(to encoder: any Encoder) throws {
    try Strategy.encodePresent(value: wrappedValue, encoder: encoder)
  }
}

extension Codec.OptionalBox: Sendable where Strategy.BoxedValue: Sendable {}

extension Codec.OptionalBox: Equatable where Strategy.BoxedValue: Equatable {
  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension Codec.OptionalBox: Hashable where Strategy.BoxedValue: Hashable {
  @inlinable
  public func hash(into hasher: inout Hasher) {
    wrappedValue.hash(into: &hasher)
  }
}

extension Codec.OptionalBox: CustomStringConvertible {
  @inlinable
  public var description: String {
    String(describing: wrappedValue)
  }
}

extension Codec.OptionalBox: CustomDebugStringConvertible {
  @inlinable
  public var debugDescription: String {
    String(reflecting: wrappedValue)
  }
}
