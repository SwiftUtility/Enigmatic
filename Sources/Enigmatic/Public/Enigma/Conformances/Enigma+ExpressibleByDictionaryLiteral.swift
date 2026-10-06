extension Enigma: ExpressibleByDictionaryLiteral {
  /// Creates a dictionary tree from string-keyed entries.
  /// - Complexity: O(n) expected in the number of entries, assuming expected
  ///   constant-time string hashing and dictionary insertion.
  public init(dictionaryLiteral elements: (String, Enigma)...) {
    self = .dictionary([String: Enigma](uniqueKeysWithValues: elements))
  }
}
