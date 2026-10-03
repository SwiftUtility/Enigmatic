extension Codec {
  /// Encodes or decodes the present payload of an optional strategy.
  ///
  /// Unlike `Codec.Box`, this type represents a value known to be present. Use it
  /// when optional semantics are handled by an enclosing keyed or unkeyed container.
  public struct OptionalBox<Strategy: Codec.OptionalStrategy> {
    /// The non-optional payload represented by this box.
    public var wrappedValue: Strategy.WrappedBoxedValue

    /// Creates a box around a present optional payload.
    @inlinable
    public init(wrappedValue: Strategy.WrappedBoxedValue) {
      self.wrappedValue = wrappedValue
    }
  }
}

extension Codec.OptionalBox: Decodable where Strategy: Codec.DecodeOptionalStrategy {
  /// Decodes one present payload using the strategy's optional decoding operation.
  @inlinable
  public init(from decoder: any Decoder) throws {
    self.wrappedValue = try Strategy.decodePresent(decoder: decoder)
  }
}

extension Codec.OptionalBox: Encodable where Strategy: Codec.EncodeOptionalStrategy {
  /// Encodes one present payload using the strategy's optional encoding operation.
  @inlinable
  public func encode(to encoder: any Encoder) throws {
    try Strategy.encodePresent(value: wrappedValue, encoder: encoder)
  }
}

extension Codec.OptionalBox: Sendable where Strategy.BoxedValue: Sendable {}

extension Codec.OptionalBox: Equatable where Strategy.BoxedValue: Equatable {
  /// Compares the wrapped payloads.
  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension Codec.OptionalBox: Hashable where Strategy.BoxedValue: Hashable {
  /// Adds the wrapped payload to `hasher`.
  @inlinable
  public func hash(into hasher: inout Hasher) {
    wrappedValue.hash(into: &hasher)
  }
}

extension Codec.OptionalBox: CustomStringConvertible {
  /// A textual representation of the wrapped payload.
  @inlinable
  public var description: String {
    String(describing: wrappedValue)
  }
}

extension Codec.OptionalBox: CustomDebugStringConvertible {
  /// A debug representation of the wrapped payload.
  @inlinable
  public var debugDescription: String {
    String(reflecting: wrappedValue)
  }
}
