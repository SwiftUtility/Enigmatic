extension Codec {
  /// Applies a strategy to a property while exposing its unwrapped value.
  ///
  /// For optional strategies, a nil value is omitted from keyed containers. During
  /// synthesized decoding, a missing or null key initializes the wrapped value to nil.
  @propertyWrapper
  public struct Box<Strategy: Codec.Strategy> {
    /// The value exposed to code using the property wrapper.
    /// - Complexity: O(1) to store or access the wrapped value (copy-on-write values retain their normal value
    ///   semantics).
    public var wrappedValue: Strategy.BoxedValue

    /// Creates a box around an already-decoded strategy value.
    /// - Complexity: O(1) to store or access the wrapped value (copy-on-write values retain their normal value
    ///   semantics).
    @inlinable
    public init(wrappedValue: Strategy.BoxedValue) {
      self.wrappedValue = wrappedValue
    }
  }
}

extension Codec.Box: Decodable where Strategy: Codec.DecodeStrategy {
  /// Decodes the wrapped value with `Strategy.decode`.
  /// - Complexity: Delegated to the selected strategy.
  @inlinable
  public init(from decoder: any Decoder) throws {
    self.wrappedValue = try Strategy.decode(decoder: decoder)
  }
}

extension Codec.Box: Encodable where Strategy: Codec.EncodeStrategy {
  /// Encodes the wrapped value with `Strategy.encode`.
  /// - Complexity: Delegated to the selected strategy.
  @inlinable
  public func encode(to encoder: any Encoder) throws {
    try Strategy.encode(value: wrappedValue, encoder: encoder)
  }
}

extension Codec.Box: Sendable where Strategy.BoxedValue: Sendable {}

extension Codec.Box: Equatable where Strategy.BoxedValue: Equatable {
  /// Compares the values stored in the two boxes.
  /// - Complexity: The complexity of comparing the wrapped values.
  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension Codec.Box: Hashable where Strategy.BoxedValue: Hashable {
  /// Adds the wrapped value to `hasher`.
  /// - Complexity: The complexity of hashing the wrapped value.
  @inlinable
  public func hash(into hasher: inout Hasher) {
    wrappedValue.hash(into: &hasher)
  }
}

extension Codec.Box: CustomStringConvertible {
  /// A textual representation of the wrapped value.
  /// - Complexity: The complexity of formatting the wrapped value.
  @inlinable
  public var description: String {
    String(describing: wrappedValue)
  }
}

extension Codec.Box: CustomDebugStringConvertible {
  /// A debug representation of the wrapped value.
  /// - Complexity: The complexity of formatting the wrapped value.
  @inlinable
  public var debugDescription: String {
    String(reflecting: wrappedValue)
  }
}
