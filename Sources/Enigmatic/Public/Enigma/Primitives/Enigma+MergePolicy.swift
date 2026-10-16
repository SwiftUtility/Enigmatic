extension Enigma {
  /// Selects values at merge conflicts and controls how array pairs combine.
  /// Dictionary pairs always merge recursively.
  ///
  /// See [merge policies](https://swiftutility.github.io/Enigmatic/documentation/enigmatic/treeoperations/#Merge-policy) for examples and array behavior.
  public struct MergePolicy: Sendable {
    /// Whether incoming values replace existing values outside array and dictionary pairs.
    public var replaceValue: Bool
    /// The operation applied when both conflicting values are arrays.
    public var arrayAction: ArrayAction

    /// Creates a policy for value conflicts and array pairs.
    /// Dictionary pairs always merge recursively.
    /// - Parameters:
    ///   - replaceValue: Whether incoming values replace existing values when the
    ///     pair is neither two dictionaries nor two arrays.
    ///   - arrayAction: The operation applied when both values are arrays.
    /// - Complexity: O(1).
    public init(replaceValue: Bool, arrayAction: ArrayAction) {
      self.replaceValue = replaceValue
      self.arrayAction = arrayAction
    }

    /// Takes incoming values, including whole arrays.
    public static var replace: Self {
      Self(replaceValue: true, arrayAction: .selectOther)
    }

    /// Keeps existing values, including whole arrays, while inserting new dictionary keys.
    public static var skip: Self {
      Self(replaceValue: false, arrayAction: .selectOriginal)
    }

    /// How to combine two arrays at a merge conflict.
    public enum ArrayAction: Sendable {
      /// Recursively merges matching indices and retains the longer array's tail.
      case zip
      /// Places incoming elements after existing elements.
      case append
      /// Places incoming elements before existing elements.
      case prepend
      /// Keeps the existing array.
      case selectOriginal
      /// Takes the incoming array.
      case selectOther
    }
  }
}
