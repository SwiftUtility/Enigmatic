@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Codec {
  /// Encodes components into the same encoder and decodes each from the same input.
  ///
  /// Use disjoint keyed models; overlapping writes can fail depending on the encoder.
  @dynamicMemberLookup
  public struct Each<each Value> {
    /// The values encoded or decoded against the same input and output container.
    var values: (repeat each Value)

    /// Creates a product from its component values.
    public init(_ value: repeat each Value) {
      self.values = (repeat each value)
    }

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
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.values = (repeat try container.decode((each Value).self))
  }
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Codec.Each: Encodable where repeat each Value: Encodable {
  /// Encodes each component into the same encoder.
  public func encode(to encoder: Encoder) throws {
    for value in repeat each values {
      try value.encode(to: encoder)
    }
  }
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Codec.Each: Equatable where repeat each Value: Equatable {
  /// Returns whether corresponding component values are equal.
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
  public func hash(into hasher: inout Hasher) {
    for value in repeat each values {
      value.hash(into: &hasher)
    }
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
  @inlinable
  public static func decode(decoder: some Decoder) throws -> BoxedValue {
    try (repeat (each Value).decode(decoder: decoder))
  }
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Codec.Each: Codec.EncodeStrategy where repeat each Value: Codec.EncodeStrategy {
  /// Encodes each component with its corresponding strategy into one encoder.
  @inlinable
  public static func encode(value: BoxedValue, encoder: some Encoder) throws {
    for (value, type) in repeat (each value, (each Value).self) {
      try type.encode(value: value, encoder: encoder)
    }
  }
}
