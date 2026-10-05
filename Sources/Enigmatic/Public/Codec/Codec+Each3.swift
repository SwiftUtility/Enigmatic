@available(macOS, deprecated: 14.0, message: "Use Codec.Each instead")
@available(iOS, deprecated: 17.0, message: "Use Codec.Each instead")
@available(tvOS, deprecated: 17.0, message: "Use Codec.Each instead")
@available(watchOS, deprecated: 10.0, message: "Use Codec.Each instead")
@available(visionOS, deprecated, message: "Use Codec.Each instead")
extension Codec {
  /// Deprecated fixed-arity product that encodes three components into one container.
  /// Use `Codec.Each` when the deployment target supports it.
  public struct Each3<Value0, Value1, Value2> {
    /// The three component values.
    public var values: (Value0, Value1, Value2)

    /// Creates a product from three component values.
    @inlinable
    public init(_ value0: Value0, _ value1: Value1, _ value2: Value2) {
      self.values = (value0, value1, value2)
    }
  }
}

extension Codec.Each3: Sendable
where Value0: Sendable, Value1: Sendable, Value2: Sendable {}

extension Codec.Each3: Decodable
where Value0: Decodable, Value1: Decodable, Value2: Decodable {
  /// Decodes all component values from the same decoder.
  @inlinable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.values = try (
      container.decode(Value0.self),
      container.decode(Value1.self),
      container.decode(Value2.self)
    )
  }
}

extension Codec.Each3: Encodable
where Value0: Encodable, Value1: Encodable, Value2: Encodable {
  /// Encodes all component values into the same encoder.
  @inlinable
  public func encode(to encoder: Encoder) throws {
    try values.0.encode(to: encoder)
    try values.1.encode(to: encoder)
    try values.2.encode(to: encoder)
  }
}

extension Codec.Each3: Equatable
where Value0: Equatable, Value1: Equatable, Value2: Equatable {
  /// Compares the corresponding component values.
  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.values.0 == rhs.values.0
    && lhs.values.1 == rhs.values.1
    && lhs.values.2 == rhs.values.2
  }
}

extension Codec.Each3: Hashable
where Value0: Hashable, Value1: Hashable, Value2: Hashable {
  /// Combines all component values into the hasher.
  @inlinable
  public func hash(into hasher: inout Hasher) {
    values.0.hash(into: &hasher)
    values.1.hash(into: &hasher)
    values.2.hash(into: &hasher)
  }
}

extension Codec.Each3: Codec.Strategy
where Value0: Codec.Strategy, Value1: Codec.Strategy, Value2: Codec.Strategy {
  /// A tuple of each component strategy's boxed value.
  public typealias BoxedValue = (
    Value0.BoxedValue,
    Value1.BoxedValue,
    Value2.BoxedValue
  )
}

extension Codec.Each3: Codec.DecodeStrategy
where Value0: Codec.DecodeStrategy, Value1: Codec.DecodeStrategy, Value2: Codec.DecodeStrategy {
  /// Decodes all values with their corresponding strategies.
  @inlinable
  public static func decode(decoder: some Decoder) throws -> BoxedValue {
    try (
      Value0.decode(decoder: decoder),
      Value1.decode(decoder: decoder),
      Value2.decode(decoder: decoder)
    )
  }
}

extension Codec.Each3: Codec.EncodeStrategy
where Value0: Codec.EncodeStrategy, Value1: Codec.EncodeStrategy, Value2: Codec.EncodeStrategy {
  /// Encodes all values with their corresponding strategies.
  @inlinable
  public static func encode(value: BoxedValue, encoder: some Encoder) throws {
    try Value0.encode(value: value.0, encoder: encoder)
    try Value1.encode(value: value.1, encoder: encoder)
    try Value2.encode(value: value.2, encoder: encoder)
  }
}
