extension Set: Codec.Strategy where Element: Codec.Strategy, Element.BoxedValue: Hashable {
  public typealias BoxedValue = Set<Element.BoxedValue>
}

extension Set: Codec.DecodeStrategy where Element: Codec.DecodeStrategy, Element.BoxedValue: Hashable {
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
  @inlinable
  public static func encode(value: BoxedValue, encoder: some Encoder) throws {
    var container = encoder.unkeyedContainer()
    for element in value {
      try container.encode(Codec.Box<Element>(wrappedValue: element))
    }
  }
}
