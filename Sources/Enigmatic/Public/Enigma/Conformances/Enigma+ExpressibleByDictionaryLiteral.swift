extension Enigma: ExpressibleByDictionaryLiteral {
  /// Creates a dictionary tree from string-keyed entries.
  public init(dictionaryLiteral elements: (String, Enigma)...) {
    self = .dictionary([String: Enigma](uniqueKeysWithValues: elements))
  }
}
