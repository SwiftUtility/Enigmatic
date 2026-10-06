extension Enigma {
  /// Tracks the path currently being visited by a merge strategy.
  public struct MergeContext: ~Copyable {
    /// The pins from the root to the current merge conflict.
    /// - Complexity: O(1) to read the copy-on-write array value.
    public private(set) var pins: [Pin] = []

    /// Creates an encoding error at the current merge path.
    /// - Parameters:
    ///   - value: The value that could not be merged.
    ///   - info: An optional diagnostic description; defaults to `"merge failed"`.
    ///   - other: An optional underlying cause.
    /// - Returns: An `EncodingError.invalidValue` carrying the current path.
    /// - Complexity: O(d) time and space to copy the coding path into the error context, where d is the current
    ///   path depth.
    public func error(_ value: Any, info: String? = nil, other: (any Error)? = nil) -> EncodingError {
      EncodingError.invalidValue(value, EncodingError.Context(
        codingPath: pins,
        debugDescription: info ?? "merge failed",
        underlyingError: other
      ))
    }

    /// Recurses into a conflict while temporarily appending its path pin.
    /// The pin is removed when the strategy returns, including when it fails.
    /// - Parameters:
    ///   - strategy: The strategy used to resolve nested values.
    ///   - pin: The dictionary key or array index for this recursion step.
    ///   - old: The existing value.
    ///   - new: The incoming value.
    /// - Returns: The merged value or the strategy's failure.
    /// - Complexity: O(1) path-stack work, excluding the recursive strategy merge.
    public mutating func recurse<Fail: Error>(
      _ strategy: inout some MergeStrategy<Fail> & ~Copyable,
      pin: Pin,
      old: Enigma,
      new: Enigma
    ) -> Result<Enigma, Fail> {
      pins.append(pin)
      defer { pins.removeLast() }
      return strategy.merge(ctx: &self, old: old, new: new)
    }
  }
}
