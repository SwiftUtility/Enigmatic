@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Codec {
  /// Encodes components into the same encoder and decodes each from the same input.
  ///
  /// Use disjoint keyed models; overlapping writes can fail depending on the encoder.
  public struct Each<each Value> {
    public var values: (repeat each Value)

    public init(values: (repeat each Value)) {
      self.values = values
    }
  }
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Codec.Each: Sendable where repeat each Value: Sendable {}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Codec.Each: Decodable where repeat each Value: Decodable {
  @inlinable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.values = (repeat try container.decode((each Value).self))
  }
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Codec.Each: Encodable where repeat each Value: Encodable {
  @inlinable
  public func encode(to encoder: Encoder) throws {
    for value in repeat each values {
      try value.encode(to: encoder)
    }
  }
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Codec.Each: Equatable where repeat each Value: Equatable {
  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    for (lhs, rhs) in repeat (each lhs.values, each rhs.values) {
      guard lhs == rhs else { return false }
    }
    return true
  }
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Codec.Each: Hashable where repeat each Value: Hashable {
  @inlinable
  public func hash(into hasher: inout Hasher) {
    for value in repeat each values {
      value.hash(into: &hasher)
    }
  }
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Codec.Each: Codec.Strategy where repeat each Value: Codec.Strategy {
  public typealias BoxedValue = (repeat (each Value).BoxedValue)
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Codec.Each: Codec.DecodeStrategy where repeat each Value: Codec.DecodeStrategy {
  @inlinable
  public static func decode(decoder: some Decoder) throws -> BoxedValue {
    try (repeat (each Value).decode(decoder: decoder))
  }
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Codec.Each: Codec.EncodeStrategy where repeat each Value: Codec.EncodeStrategy {
  @inlinable
  public static func encode(value: BoxedValue, encoder: some Encoder) throws {
    for (value, type) in repeat (each value, (each Value).self) {
      try type.encode(value: value, encoder: encoder)
    }
  }
}
