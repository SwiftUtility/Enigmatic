@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Codec {
  /// Encodes components into the same encoder and decodes each from the same input.
  ///
  /// Use disjoint keyed models. Enigma's encoder rejects overlapping keys,
  /// repeated scalar writes and separately requested unkeyed containers, even
  /// when the values are equal or the containers are empty. Shared keys are not
  /// merged recursively. Other encoders define their own conflict handling.
  @dynamicMemberLookup
  public struct Each<each Value> {
    /// The values encoded or decoded against the same input and output container.
    @usableFromInline
    var values: (repeat each Value)

    /// Creates a product from its component values.
    /// - Complexity: O(k) in the number k of components to form the tuple.
    public init(_ value: repeat each Value) {
      self.values = (repeat each value)
    }

    /// Reads or updates a component through a key path into the values tuple.
    /// - Complexity: O(1) key-path access, excluding copy-on-write work of the selected component.
    @inlinable
    public subscript<T>(dynamicMember keyPath: WritableKeyPath<(repeat each Value), T>) -> T {
      get { values[keyPath: keyPath] }
      set { values[keyPath: keyPath] = newValue }
    }
  }
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Codec.Each: Sendable where repeat each Value: Sendable {}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Codec.Each: Decodable where repeat each Value: Decodable {
  /// Decodes every component from the same decoder.
  /// - Complexity: O(k) decode calls for k components, plus their decoding costs.
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.values = (repeat try container.decode((each Value).self))
  }
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Codec.Each: Encodable where repeat each Value: Encodable {
  /// Encodes each component into the same encoder.
  /// - Complexity: O(k) strategy calls for k components, plus the sum of each component's encoding cost.
  public func encode(to encoder: Encoder) throws {
    for value in repeat each values {
      try value.encode(to: encoder)
    }
  }
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Codec.Each: Equatable where repeat each Value: Equatable {
  /// Returns whether corresponding component values are equal.
  /// - Complexity: O(k) component comparisons, plus the cost of comparing each component.
  public static func == (lhs: Self, rhs: Self) -> Bool {
    for (lhs, rhs) in repeat (each lhs.values, each rhs.values) {
      guard lhs == rhs else { return false }
    }
    return true
  }
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Codec.Each: Hashable where repeat each Value: Hashable {
  /// Combines every component value into the hasher.
  /// - Complexity: O(k) component hash operations, plus the cost of hashing each component.
  public func hash(into hasher: inout Hasher) {
    repeat (each values).hash(into: &hasher)
  }
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Codec.Each: Codec.Strategy where repeat each Value: Codec.Strategy {
  /// A tuple of each component strategy's boxed value.
  public typealias BoxedValue = (repeat (each Value).BoxedValue)
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Codec.Each: Codec.DecodeStrategy where repeat each Value: Codec.DecodeStrategy {
  /// Decodes each component with its corresponding strategy from one decoder.
  /// - Complexity: O(k) strategy calls for k components, plus the sum of each component's decoding cost.
  @inlinable
  public static func decode(decoder: some Decoder) throws -> BoxedValue {
    try (repeat (each Value).decode(decoder: decoder))
  }
}

#if os(Windows) && compiler(<6.2)
// Swift 6.1's asserting compiler crashes when a witness unpacks a tuple pack.
// Keep the tuple inside Box across the witness boundary instead.
@usableFromInline
protocol EachEncodeStrategy: Codec.EncodeStrategy {
  static func encodeBox(_ box: Codec.Box<Self>, encoder: some Encoder) throws
}

extension EachEncodeStrategy {
  @inlinable
  public static func encode(value: BoxedValue, encoder: some Encoder) throws {
    try encodeBox(Codec.Box(wrappedValue: value), encoder: encoder)
  }
}

extension Codec.Each: Codec.EncodeStrategy, EachEncodeStrategy where repeat each Value: Codec.EncodeStrategy {
  @usableFromInline
  static func encodeBox(_ box: Codec.Box<Self>, encoder: some Encoder) throws {
    for (value, type) in repeat (each box.wrappedValue, (each Value).self) {
      try type.encode(value: value, encoder: encoder)
    }
  }
}
#else
@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Codec.Each: Codec.EncodeStrategy where repeat each Value: Codec.EncodeStrategy {
  /// Encodes each component with its corresponding strategy into one encoder.
  /// - Complexity: O(k) strategy calls for k components, plus the sum of each component's encoding cost.
  @inlinable
  public static func encode(value: BoxedValue, encoder: some Encoder) throws {
    for (value, type) in repeat (each value, (each Value).self) {
      try type.encode(value: value, encoder: encoder)
    }
  }
}
#endif
