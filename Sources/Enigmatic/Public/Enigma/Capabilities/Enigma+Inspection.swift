import Foundation

extension Enigma {
  /// Paths of all descendants, including containers, excluding the root.
  ///
  /// Traversal is depth first, with ascending array indices and sorted dictionary keys.
  public var allPaths: [[Pin]] {
    var result: [[Pin]] = []
    var current: [Pin] = []
    collectPins(into: &result, current: &current)
    return result
  }

  /// Whether the root value is an explicit null.
  public var isNull: Bool {
    if case .null = self { true } else { false }
  }

  /// Whether the root value is an array.
  public var isArray: Bool {
    if case .array = self { true } else { false }
  }

  /// Whether the root value is a dictionary.
  public var isDictionary: Bool {
    if case .dictionary = self { true } else { false }
  }
}
