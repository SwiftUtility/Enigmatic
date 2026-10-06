extension Enigma {
  /// Defines how a merge resolves pairs that are not recursively merged dictionaries.
  /// The default `merge` implementation recursively combines dictionary pairs
  /// and calls `resolve` for every other conflict.
  public protocol MergeStrategy<Fail>: ~Copyable {
    /// Merges two values using the context's current coding path.
    /// Implement this requirement to customize recursion; the protocol extension
    /// supplies the standard dictionary-recursive implementation.
    /// - Parameters:
    ///   - ctx: The mutable path context for this merge.
    ///   - old: The existing value.
    ///   - new: The incoming value.
    /// - Returns: The merged tree, or a strategy-specific failure.
    /// - Complexity: Defined by the implementation. The default is expected O(n)
    ///   in visited values and dictionary operations, excluding resolver work.
    mutating func merge(ctx: inout MergeContext, old: Enigma, new: Enigma) -> Result<Enigma, Fail>

    /// Resolves a pair that the merge algorithm treats as a conflict.
    /// - Parameters:
    ///   - ctx: The mutable path context at the conflict.
    ///   - old: The existing value.
    ///   - new: The incoming value.
    /// - Returns: The selected value, or a strategy-specific failure.
    /// - Complexity: Defined by the conforming implementation.
    mutating func resolve(ctx: inout MergeContext, old: Enigma, new: Enigma) -> Result<Enigma, Fail>

    /// The failure type returned by this strategy.
    associatedtype Fail: Error
  }
}

extension Enigma.MergeStrategy where Self: ~Copyable {
  /// Recursively merges dictionaries and delegates all other conflicts to `resolve`.
  /// Newly encountered dictionary keys are copied directly from `new`.
  ///
  /// - Parameters:
  ///   - ctx: The path context used to report recursive conflicts.
  ///   - old: The existing tree.
  ///   - new: The incoming tree.
  /// - Returns: The merged dictionary or the first failure returned by `resolve`.
  /// - Complexity: O(n) expected over visited dictionary entries and recursive conflicts, plus the resolver
  ///   cost; copy-on-write can copy dictionaries. n is the number of visited values.
  public mutating func merge(
    ctx: inout Enigma.MergeContext,
    old: Enigma,
    new: Enigma
  ) -> Result<Enigma, Fail> {
    guard case (.dictionary(var result), .dictionary(let new)) = (old, new) else {
      return resolve(ctx: &ctx, old: old, new: new)
    }
    for (key, value) in new {
      if let old = result[key] {
        switch ctx.recurse(&self, pin: .str(key), old: old, new: value) {
        case .success(let value): result[key] = value
        case .failure(let error): return .failure(error)
        }
      } else {
        result[key] = value
      }
    }
    return .success(.dictionary(result))
  }
}
