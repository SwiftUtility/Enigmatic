@available(macOS, deprecated: 14.0, message: "Use Codec.Each instead")
@available(iOS, deprecated: 17.0, message: "Use Codec.Each instead")
@available(tvOS, deprecated: 17.0, message: "Use Codec.Each instead")
@available(watchOS, deprecated: 10.0, message: "Use Codec.Each instead")
@available(visionOS, deprecated, message: "Use Codec.Each instead")
extension Codec {
  /// Deprecated fixed-arity product that encodes four components into one container.
  /// Use `Codec.Each` when the deployment target supports it.
  public struct Each4<Value0, Value1, Value2, Value3> {
    /// The four component values.
    public var values: (Value0, Value1, Value2, Value3)

    /// Creates a product from four component values.
    @inlinable
    public init(values: (Value0, Value1, Value2, Value3)) {
      self.values = values
    }
  }
}

extension Codec.Each4: Sendable
where Value0: Sendable, Value1: Sendable, Value2: Sendable, Value3: Sendable {}

extension Codec.Each4: Decodable
where Value0: Decodable, Value1: Decodable, Value2: Decodable, Value3: Decodable {
  /// Decodes all component values from the same decoder.
  @inlinable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.values = try (
      container.decode(Value0.self),
      container.decode(Value1.self),
      container.decode(Value2.self),
      container.decode(Value3.self)
    )
  }
}

extension Codec.Each4: Encodable
where Value0: Encodable, Value1: Encodable, Value2: Encodable, Value3: Encodable {
  /// Encodes all component values into the same encoder.
  @inlinable
  public func encode(to encoder: Encoder) throws {
    try values.0.encode(to: encoder)
    try values.1.encode(to: encoder)
    try values.2.encode(to: encoder)
    try values.3.encode(to: encoder)
  }
}

extension Codec.Each4: Equatable
where Value0: Equatable, Value1: Equatable, Value2: Equatable, Value3: Equatable {
  /// Compares the corresponding component values.
  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.values.0 == rhs.values.0
    && lhs.values.1 == rhs.values.1
    && lhs.values.2 == rhs.values.2
    && lhs.values.3 == rhs.values.3
  }
}

extension Codec.Each4: Hashable
where Value0: Hashable, Value1: Hashable, Value2: Hashable, Value3: Hashable {
  /// Combines all component values into the hasher.
  @inlinable
  public func hash(into hasher: inout Hasher) {
    values.0.hash(into: &hasher)
    values.1.hash(into: &hasher)
    values.2.hash(into: &hasher)
    values.3.hash(into: &hasher)
  }
}

extension Codec.Each4: Codec.Strategy
where Value0: Codec.Strategy, Value1: Codec.Strategy, Value2: Codec.Strategy, Value3: Codec.Strategy {
  /// A tuple of each component strategy's boxed value.
  public typealias BoxedValue = (
    Value0.BoxedValue,
    Value1.BoxedValue,
    Value2.BoxedValue,
    Value3.BoxedValue
  )
}

extension Codec.Each4: Codec.DecodeStrategy
where Value0: Codec.DecodeStrategy, Value1: Codec.DecodeStrategy, Value2: Codec.DecodeStrategy, Value3: Codec.DecodeStrategy {
  /// Decodes all values with their corresponding strategies.
  @inlinable
  public static func decode(decoder: some Decoder) throws -> BoxedValue {
    try (
      Value0.decode(decoder: decoder),
      Value1.decode(decoder: decoder),
      Value2.decode(decoder: decoder),
      Value3.decode(decoder: decoder)
    )
  }
}

extension Codec.Each4: Codec.EncodeStrategy
where Value0: Codec.EncodeStrategy, Value1: Codec.EncodeStrategy, Value2: Codec.EncodeStrategy, Value3: Codec.EncodeStrategy {
  /// Encodes all values with their corresponding strategies.
  @inlinable
  public static func encode(value: BoxedValue, encoder: some Encoder) throws {
    try Value0.encode(value: value.0, encoder: encoder)
    try Value1.encode(value: value.1, encoder: encoder)
    try Value2.encode(value: value.2, encoder: encoder)
    try Value3.encode(value: value.3, encoder: encoder)
  }
}
