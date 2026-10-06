import Foundation

extension Enigma {
  /// Get the array value, or an empty array for other cases.
  public var array: [Self] {
    get { asArray ?? [] }
    set { self = .array(newValue) }
  }

  /// Get value if it is Dictionary, empty dictionary otherwise
  public var dictionary: [String: Self] {
    get { asDictionary ?? [:] }
    set { self = .dictionary(newValue) }
  }

  /// Gets, sets, or removes a value at a variadic path.
  /// Non-nil assignments follow the path creation and container replacement
  /// rules of `subscript(_:)`; nil removes a child, and `.null` stores a null.
  public subscript(_ pins: Pin...) -> Self? {
    get { self[pins] }
    set { self[pins] = newValue }
  }

  /// Gets or sets a value at a variadic path, using `fallback` when it is absent.
  /// The autoclosure is evaluated only when the path has no value.
  /// Setting follows the same path creation and container replacement rules as
  /// `subscript(_:)`.
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
  public subscript(_ pins: [Pin], or fallback: @autoclosure () -> Self) -> Self {
    get { getValue(pins: pins) ?? fallback() }
    set {
      var pins = ArraySlice(pins)
      _ = Self.setValue(newValue, pins: &pins, original: &self)
    }
  }

  public mutating func merge<E: Error>(
    _ other: Self,
    strategy: inout some MergeStrategy<E> & ~Copyable
  ) throws(E) {
    var ctx = MergeContext()
    self = try strategy.merge(ctx: &ctx, old: self, new: other).get()
  }

  public consuming func merging<E: Error>(
    _ other: Self,
    strategy: consuming some MergeStrategy<E> & ~Copyable
  ) throws(E) -> Self {
    var ctx = MergeContext()
    var strategy = consume strategy
    return try strategy.merge(ctx: &ctx, old: self, new: other).get()
  }

  public mutating func merge(_ other: Self, replace: Bool) {
    var ctx = MergeContext()
    var strategy = SelectOneMergeStrategy(selectNew: replace)
    self = strategy.merge(ctx: &ctx, old: self, new: other).get()
  }

  public consuming func merging(_ other: Self, replace: Bool) -> Self {
    merging(other, strategy: SelectOneMergeStrategy(selectNew: replace))
  }

  public mutating func merge(_ other: Self, skipEqual: Bool) throws(EncodingError) {
    self = try merging(other, strategy: InteruptMergeStrategy(skipEqual: skipEqual))
  }

  public consuming func merging(_ other: Self, skipEqual: Bool) throws(EncodingError) -> Self {
    try merging(other, strategy: InteruptMergeStrategy(skipEqual: skipEqual))
  }

  /// Recursively merges dictionaries and resolves all other pairs as whole values.
  ///
  /// The original value is unchanged if the resolver throws. Dictionary conflict
  /// visitation order is unspecified.
  public mutating func merge<E: Error>(
    _ other: Self,
    throws _: E.Type = E.self,
    resolve: ([Pin], Self, Self) throws(E) -> Self
  ) throws(E) {
    self = try withoutActuallyEscaping(resolve) { block in
      var ctx = MergeContext()
      var strategy = SimpleCustomMergeStrategy(block: block)
      return strategy.merge(ctx: &ctx, old: self, new: other)
    }.get()
  }

  /// Recursively merges dictionaries and resolves all other pairs as whole values.
  ///
  /// The original value is unchanged if the resolver throws. Dictionary conflict
  /// visitation order is unspecified.
  public consuming func merging<E: Error>(
    _ other: Self,
    throws type: E.Type = E.self,
    resolve: ([Pin], Self, Self) throws(E) -> Self
  ) throws(E) -> Self {
    try withoutActuallyEscaping(resolve) { block in
      var ctx = MergeContext()
      var strategy = SimpleCustomMergeStrategy(block: block)
      return strategy.merge(ctx: &ctx, old: self, new: other)
    }.get()
  }
}
