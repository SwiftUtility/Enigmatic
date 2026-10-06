extension Enigma: ExpressibleByArrayLiteral {
  /// Creates an array tree from its elements.
  /// - Complexity: O(n) in the number of elements; elements are stored in order.
  public init(arrayLiteral elements: Enigma...) {
    self = .array(elements)
  }
}
