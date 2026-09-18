extension Enigma: ExpressibleByStringLiteral {
  public init(stringLiteral value: StringLiteralType) {
    self = .string(value)
  }
}
