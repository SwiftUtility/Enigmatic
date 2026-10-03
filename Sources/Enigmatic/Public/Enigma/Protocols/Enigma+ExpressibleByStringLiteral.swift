extension Enigma: ExpressibleByStringLiteral {
  /// Creates a string tree value from a string literal.
  public init(stringLiteral value: StringLiteralType) {
    self = .string(value)
  }
}
