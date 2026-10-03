extension Enigma: ExpressibleByArrayLiteral {
  /// Creates an array tree from its elements.
  public init(arrayLiteral elements: Enigma...) {
    self = .array(elements)
  }
}
