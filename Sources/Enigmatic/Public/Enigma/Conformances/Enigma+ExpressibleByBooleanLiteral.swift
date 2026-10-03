extension Enigma: ExpressibleByBooleanLiteral {
  /// Creates a Boolean tree value from a Boolean literal.
  public init(booleanLiteral value: BooleanLiteralType) {
    self = .bool(value)
  }
}
