extension Array: Codec.Strategy where Element: Codec.Strategy {
  public typealias BoxedValue = [Element.BoxedValue]
}

extension Array: Codec.DecodeStrategy where Element: Codec.DecodeStrategy {
  @inlinable
  public static func decode(decoder: some Decoder) throws -> BoxedValue {
    var container = try decoder.unkeyedContainer()
    var result: BoxedValue = []
    if let count = container.count {
      result.reserveCapacity(count)
    }
    while !container.isAtEnd {
      try result.append(container.decode(Codec.Box<Element>.self).wrappedValue)
    }
    return result
  }
}

extension Array: Codec.EncodeStrategy where Element: Codec.EncodeStrategy {
  @inlinable
  public static func encode(value: BoxedValue, encoder: some Encoder) throws {
    var container = encoder.unkeyedContainer()
    for element in value {
      try container.encode(Codec.Box<Element>(wrappedValue: element))
    }
  }
}
