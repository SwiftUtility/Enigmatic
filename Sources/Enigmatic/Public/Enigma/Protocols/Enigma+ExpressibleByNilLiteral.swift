extension Enigma: ExpressibleByNilLiteral {
  public init(nilLiteral: ()) {
    self = .null
  }
}
