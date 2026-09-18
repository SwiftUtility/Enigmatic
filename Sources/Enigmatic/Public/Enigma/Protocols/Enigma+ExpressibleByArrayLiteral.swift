extension Enigma: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: Enigma...) {
    self = .array(elements)
  }
}
