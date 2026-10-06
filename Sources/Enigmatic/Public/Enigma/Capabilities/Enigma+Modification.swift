import Foundation

extension Enigma {
  /// Gets the array value, or an empty array when the root is not an array.
  /// Setting this property replaces the entire root with an array.
  /// - Complexity: O(1) for the enum-case check and copy-on-write value access.
  public var array: [Self] {
    get { asArray ?? [] }
    set { self = .array(newValue) }
  }

  /// Gets the dictionary value, or an empty dictionary when the root is not a dictionary.
  /// Setting this property replaces the entire root with a dictionary.
  /// - Complexity: O(1) for the enum-case check and copy-on-write value access.
  public var dictionary: [String: Self] {
    get { asDictionary ?? [:] }
    set { self = .dictionary(newValue) }
  }

  /// Gets, sets, or removes a value at a variadic path.
  /// Non-nil assignments follow the path creation and container replacement
  /// rules of `subscript(_:)`; nil removes a child, and `.null` stores a null.
  /// - Complexity: O(d) expected for lookup, where d is path depth. Mutations also incur copy-on-write costs for
  ///   modified collections; worst-case work is proportional to the sizes of collections copied along the
  ///   path.
  public subscript(_ pins: Pin...) -> Self? {
    get { self[pins] }
    set { self[pins] = newValue }
  }

  /// Gets or sets a value at a variadic path, using `fallback` when it is absent.
  /// The autoclosure is evaluated only when the path has no value.
  /// Setting follows the same path creation and container replacement rules as
  /// `subscript(_:)`.
  /// - Complexity: O(d) expected for lookup, where d is path depth. Mutations also incur copy-on-write costs for
  ///   modified collections; worst-case work is proportional to the sizes of collections copied along the
  ///   path.
  public subscript(_ pins: Pin..., or fallback: @autoclosure () -> Self) -> Self {
    get { self[pins, or: fallback()] }
    set { self[pins, or: fallback()] = newValue }
  }

  /// Reads, replaces, or removes a value at a path.
  ///
  /// Non-nil assignment creates missing dictionary children, appends at the end
  /// of arrays, and replaces values with dictionaries or arrays when the next
  /// pin requires that container. Array indices below zero or greater than the
  /// array count make the entire assignment a no-op. Nil removes an existing
  /// child without creating containers; `.null` stores a null. An empty path
  /// can replace, but cannot delete, the root.
  /// - Parameter pins: The sequence of dictionary keys and array indices.
  /// - Complexity: O(d) expected for lookup, where d is path depth. Mutations also incur copy-on-write costs for
  ///   modified collections; worst-case work is proportional to the sizes of collections copied along the
  ///   path.
  public subscript(_ pins: [Pin]) -> Self? {
    get { getValue(pins: pins) }
    set {
      var pins = ArraySlice(pins)
      if let newValue {
        _ = Self.setValue(newValue, pins: &pins, original: &self)
      } else {
        delValue(pins: &pins)
      }
    }
  }

  /// Gets or sets a value at a path, using `fallback` when it is absent.
  /// The autoclosure is evaluated only when the path has no value.
  /// Setting follows the same path creation and container replacement rules as
  /// `subscript(_:)`.
  /// - Complexity: O(d) expected for lookup, where d is path depth. Mutations also incur copy-on-write costs for
  ///   modified collections; worst-case work is proportional to the sizes of collections copied along the
  ///   path.
  public subscript(_ pins: [Pin], or fallback: @autoclosure () -> Self) -> Self {
    get { getValue(pins: pins) ?? fallback() }
    set {
      var pins = ArraySlice(pins)
      _ = Self.setValue(newValue, pins: &pins, original: &self)
    }
  }

  /// Recursively merges dictionary pairs and chooses a value for each other conflict.
  /// When `replace` is true, the incoming value wins; otherwise the existing value wins.
  /// - Complexity: O(n) expected in the values visited and dictionary lookups, plus the resolver cost;
  ///   copy-on-write may copy modified dictionaries. n is the number of visited values.
  public mutating func merge(_ other: Self, replace: Bool) {
    self = SelectOneMergeStrategy(selectNew: replace).merge(old: self, new: other).get()
  }

  /// Returns a recursively merged tree, selecting old or incoming values at conflicts.
  /// When `replace` is true, the incoming value wins; otherwise the existing value wins.
  /// - Complexity: O(n) expected in the values visited and dictionary lookups, plus the resolver cost;
  ///   copy-on-write may copy modified dictionaries. n is the number of visited values.
  public func merging(_ other: Self, replace: Bool) -> Self {
    SelectOneMergeStrategy(selectNew: replace).merge(old: self, new: other).get()
  }

  /// Recursively merges dictionary pairs. Equal conflicts are accepted when
  /// `skipEqual` is true; otherwise every conflict throws `EncodingError.invalidValue`.
  /// - Complexity: O(n) expected in the values visited and dictionary lookups, plus the resolver cost;
  ///   copy-on-write may copy modified dictionaries. n is the number of visited values.
  public mutating func merge(_ other: Self, skipEqual: Bool) throws(EncodingError) {
    self = try InteruptMergeStrategy(skipEqual: skipEqual).merge(old: self, new: other).get()
  }

  /// Returns a recursively merged tree. Equal conflicts are accepted when
  /// `skipEqual` is true; otherwise every conflict throws `EncodingError.invalidValue`.
  /// - Complexity: O(n) expected in the values visited and dictionary lookups, plus the resolver cost;
  ///   copy-on-write may copy modified dictionaries. n is the number of visited values.
  public func merging(_ other: Self, skipEqual: Bool) throws(EncodingError) -> Self {
    try InteruptMergeStrategy(skipEqual: skipEqual).merge(old: self, new: other).get()
  }

  /// Recursively merges dictionaries and resolves all other pairs as whole values.
  ///
  /// The original value is unchanged if the resolver throws. Dictionary conflict
  /// visitation order is unspecified.
  /// - Parameters:
  ///   - other: The incoming tree.
  ///   - #1: The error type inferred from `resolve`.
  ///   - resolve: The callback that selects the value for a non-dictionary conflict.
  /// - Throws: The error thrown by `resolve`; on failure, `self` remains unchanged.
  /// - Complexity: O(n) expected in visited values and dictionary lookups, plus
  ///   resolver work; copy-on-write may copy modified dictionaries.
  public mutating func merge<E: Error>(
    _ other: Self,
    orThrow _: E.Type = E.self,
    resolve: ([Pin], Self, Self) throws(E) -> Self
  ) throws(E) {
    self = try withoutActuallyEscaping(resolve) { block in
      CustomMergeStrategy(block: block).merge(old: self, new: other)
    }
    .get()
  }

  /// Recursively merges dictionaries and resolves all other pairs as whole values.
  ///
  /// The original value is unchanged if the resolver throws. Dictionary conflict
  /// visitation order is unspecified.
  /// - Parameters:
  ///   - other: The incoming tree.
  ///   - type: The error type inferred from `resolve`.
  ///   - resolve: The callback that selects the value for a non-dictionary conflict.
  /// - Returns: The merged tree.
  /// - Throws: The error thrown by `resolve`.
  /// - Complexity: O(n) expected in visited values and dictionary lookups, plus
  ///   resolver work; copy-on-write may copy modified dictionaries.
  public func merging<E: Error>(
    _ other: Self,
    orThrow type: E.Type = E.self,
    resolve: ([Pin], Self, Self) throws(E) -> Self
  ) throws(E) -> Self {
    try withoutActuallyEscaping(resolve) { block in
      CustomMergeStrategy(block: block).merge(old: self, new: other)
    }
    .get()
  }
}
