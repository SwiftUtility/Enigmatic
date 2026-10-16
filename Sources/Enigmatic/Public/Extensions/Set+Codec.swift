extension Set: Codec.Strategy where Element: Codec.Strategy, Element.BoxedValue: Hashable {
  /// A set containing the boxed value of each element.
  public typealias BoxedValue = Set<Element.BoxedValue>
}

extension Set: Codec.DecodeStrategy where Element: Codec.DecodeStrategy, Element.BoxedValue: Hashable {
  /// Decodes an unkeyed sequence and removes duplicate elements.
  /// - Complexity: O(n) expected set insertions/visits, plus element strategy costs; hashing and equality costs
  ///   depend on the boxed element type.
  @inlinable
  public static func decode(decoder: some Decoder) throws -> BoxedValue {
    var container = try decoder.unkeyedContainer()
    var result: BoxedValue = []
    if let count = container.count {
      result.reserveCapacity(count)
    }
    while !container.isAtEnd {
      try result.insert(container.decode(Codec.Box<Element>.self).wrappedValue)
    }
    return result
  }
}

extension Set: Codec.EncodeStrategy where Element: Codec.EncodeStrategy, Element.BoxedValue: Hashable {
  /// Encodes the set as an unkeyed sequence; element order is unspecified.
  /// - Complexity: O(n) expected set insertions/visits, plus element strategy costs; hashing and equality costs
  ///   depend on the boxed element type.
  @inlinable
  public static func encode(value: BoxedValue, encoder: some Encoder) throws {
    var container = encoder.unkeyedContainer()
    for element in value {
      try container.encode(Codec.Box<Element>(wrappedValue: element))
    }
  }
}
