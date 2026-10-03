extension Codec {
  /// Applies a strategy to a property while exposing its unwrapped value.
  ///
  /// For optional strategies, a nil value is omitted from keyed containers. During
  /// synthesized decoding, a missing or null key initializes the wrapped value to nil.
  @propertyWrapper
  public struct Box<Strategy: Codec.Strategy> {
    /// The value exposed to code using the property wrapper.
    public var wrappedValue: Strategy.BoxedValue

    /// Creates a box around an already-decoded strategy value.
    @inlinable
    public init(wrappedValue: Strategy.BoxedValue) {
      self.wrappedValue = wrappedValue
    }
  }
}

extension Codec.Box: Decodable where Strategy: Codec.DecodeStrategy {
  /// Decodes the wrapped value with `Strategy.decode`.
  @inlinable
  public init(from decoder: any Decoder) throws {
    self.wrappedValue = try Strategy.decode(decoder: decoder)
  }
}

extension Codec.Box: Encodable where Strategy: Codec.EncodeStrategy {
  /// Encodes the wrapped value with `Strategy.encode`.
  @inlinable
  public func encode(to encoder: any Encoder) throws {
    try Strategy.encode(value: wrappedValue, encoder: encoder)
  }
}

extension Codec.Box: Sendable where Strategy.BoxedValue: Sendable {}

extension Codec.Box: Equatable where Strategy.BoxedValue: Equatable {
  /// Compares the values stored in the two boxes.
  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension Codec.Box: Hashable where Strategy.BoxedValue: Hashable {
  /// Adds the wrapped value to `hasher`.
  @inlinable
  public func hash(into hasher: inout Hasher) {
    wrappedValue.hash(into: &hasher)
  }
}

extension Codec.Box: CustomStringConvertible {
  /// A textual representation of the wrapped value.
  @inlinable
  public var description: String {
    String(describing: wrappedValue)
  }
}

extension Codec.Box: CustomDebugStringConvertible {
  /// A debug representation of the wrapped value.
  @inlinable
  public var debugDescription: String {
    String(reflecting: wrappedValue)
  }
}
