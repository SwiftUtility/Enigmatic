extension Enigma: ExpressibleByStringLiteral {
  /// Creates a string tree value from a string literal.
  /// - Complexity: O(1) for the literal value.
  public init(stringLiteral value: StringLiteralType) {
    self = .string(value)
  }
}
