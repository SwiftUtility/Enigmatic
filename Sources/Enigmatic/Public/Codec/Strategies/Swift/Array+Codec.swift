extension Array: Codec.Strategy where Element: Codec.Strategy {
  /// An array containing the boxed value of each element.
  public typealias BoxedValue = [Element.BoxedValue]
}

extension Array: Codec.DecodeStrategy where Element: Codec.DecodeStrategy {
  /// Decodes each unkeyed element using `Element`'s strategy.
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
  /// Encodes elements in array order using `Element`'s strategy.
  @inlinable
  public static func encode(value: BoxedValue, encoder: some Encoder) throws {
    var container = encoder.unkeyedContainer()
    for element in value {
      try container.encode(Codec.Box<Element>(wrappedValue: element))
    }
  }
}
