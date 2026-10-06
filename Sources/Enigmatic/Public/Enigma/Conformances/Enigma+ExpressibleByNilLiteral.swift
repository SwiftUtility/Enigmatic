extension Enigma: ExpressibleByNilLiteral {
  /// Creates an explicit null tree value from `nil`.
  /// - Complexity: O(1) for the literal value.
  public init(nilLiteral: ()) {
    self = .null
  }
}
