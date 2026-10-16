import Foundation

extension Enigma {
  /// Paths of all descendants, including containers, excluding the root.
  ///
  /// Traversal is depth first, with ascending array indices and sorted dictionary keys.
  /// - Complexity: O(p + Σ(kᵢ log kᵢ)) time, O(p) output space, and O(d) stack
  ///   space, where p is total emitted pins, kᵢ is the number of keys in each
  ///   visited dictionary, and d is maximum nesting depth.
  public var allPaths: [[Pin]] {
    var result: [[Pin]] = []
    var current: [Pin] = []
    collectPins(into: &result, current: &current)
    return result
  }

  /// Whether the root value is an explicit null.
  /// - Complexity: O(1); it checks the root enum case.
  public var isNull: Bool {
    if case .null = self { true } else { false }
  }

  /// Whether the root value is an array.
  /// - Complexity: O(1); it checks the root enum case.
  public var isArray: Bool {
    if case .array = self { true } else { false }
  }

  /// Whether the root value is a dictionary.
  /// - Complexity: O(1); it checks the root enum case.
  public var isDictionary: Bool {
    if case .dictionary = self { true } else { false }
  }
}
