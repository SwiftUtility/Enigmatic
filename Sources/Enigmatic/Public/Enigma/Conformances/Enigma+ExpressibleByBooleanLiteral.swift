extension Enigma: ExpressibleByBooleanLiteral {
  /// Creates a Boolean tree value from a Boolean literal.
  /// - Complexity: O(1) for the literal value.
  public init(booleanLiteral value: BooleanLiteralType) {
    self = .bool(value)
  }
}
