extension Enigma: ExpressibleByNilLiteral {
  /// Creates an explicit null tree value from `nil`.
  public init(nilLiteral: ()) {
    self = .null
  }
}
