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

  /// Recursively merges dictionary pairs, handles array pairs with `policy.arrayAction`,
  /// and selects other values with `policy.replaceValue`.
  /// - Complexity: O(n) expected in visited or concatenated values and dictionary lookups;
  ///   shared collection storage is copied when modified.
  public mutating func merge(_ other: consuming Self, policy: MergePolicy) {
    _ = PoliteMergeStrategy(policy: policy).inplaceMerge(old: &self, new: &other)
  }

  /// Returns a recursively merged tree using `policy` for arrays and value conflicts.
  /// - Complexity: O(n) expected in visited or concatenated values and dictionary lookups;
  ///   shared collection storage is copied when modified.
  public consuming func merging(_ other: consuming Self, policy: MergePolicy) -> Self {
    _ = PoliteMergeStrategy(policy: policy).inplaceMerge(old: &self, new: &other)
    return consume self
  }

  /// Recursively merges dictionary pairs. Equal conflicts are accepted when
  /// `skipEqual` is true; otherwise every conflict throws `EncodingError.invalidValue`.
  /// - Complexity: O(n) expected in the values visited and dictionary lookups, plus the resolver cost;
  ///   copy-on-write may copy modified dictionaries. n is the number of visited values.
  public mutating func merge(
    _ other: consuming Self,
    skipEqual: Bool
  ) throws(EncodingError) {
    if let fail = InteruptMergeStrategy(skipEqual: skipEqual).atomicMerge(old: &self, new: &other) {
      throw fail
    }
  }

  /// Returns a recursively merged tree. Equal conflicts are accepted when
  /// `skipEqual` is true; otherwise every conflict throws `EncodingError.invalidValue`.
  /// - Complexity: O(n) expected in the values visited and dictionary lookups, plus the resolver cost;
  ///   copy-on-write may copy modified dictionaries. n is the number of visited values.
  public consuming func merging(
    _ other: consuming Self,
    skipEqual: Bool
  ) throws(EncodingError) -> Self {
    let fail = InteruptMergeStrategy(skipEqual: skipEqual).inplaceMerge(old: &self, new: &other)
    if let fail { throw fail } else { return self }
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
    _ other: consuming Self,
    orThrow _: E.Type = E.self,
    resolve: ([Pin], Self, Self) throws(E) -> Self
  ) throws(E) {
    let fail = withoutActuallyEscaping(resolve) { block in
      CustomMergeStrategy(block: block).atomicMerge(old: &self, new: &other)
    }
    if let fail { throw fail }
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
  public consuming func merging<E: Error>(
    _ other: consuming Self,
    orThrow type: E.Type = E.self,
    resolve: ([Pin], Self, Self) throws(E) -> Self
  ) throws(E) -> Self {
    let fail = withoutActuallyEscaping(resolve) { block in
      CustomMergeStrategy(block: block).inplaceMerge(old: &self, new: &other)
    }
    if let fail { throw fail } else { return self }
  }
}
