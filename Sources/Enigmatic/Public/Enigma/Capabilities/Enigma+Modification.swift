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
  /// Assigning nil removes a child; assigning `.null` stores an explicit null.
  public subscript(_ pins: Pin...) -> Self? {
    get { self[pins] }
    set { self[pins] = newValue }
  }

  /// Gets or sets a value at a variadic path, using `fallback` when it is absent.
  /// The autoclosure is evaluated only when the path has no value.
  public subscript(_ pins: Pin..., or fallback: @autoclosure () -> Self) -> Self {
    get { self[pins, or: fallback()] }
    set { self[pins, or: fallback()] = newValue }
  }

  /// Reads, replaces, or removes a value at a path.
  ///
  /// Missing dictionary children and array elements at count can be created.
  /// Incompatible parents and invalid indices are no-ops. Nil deletes a child;
  /// `.null` stores a null. An empty path can replace, but cannot delete, the root.
  /// - Parameter pins: The sequence of dictionary keys and array indices.
  public subscript(_ pins: [Pin]) -> Self? {
    get { getValue(pins: pins) }
    set {
      var pins = ArraySlice(pins)
      if let newValue {
        setValue(newValue, pins: &pins)
      } else {
        delValue(pins: &pins)
      }
    }
  }

  /// Gets or sets a value at a path, using `fallback` when it is absent.
  /// The autoclosure is evaluated only when the path has no value.
  public subscript(_ pins: [Pin], or fallback: @autoclosure () -> Self) -> Self {
    get { getValue(pins: pins) ?? fallback() }
    set {
      var pins = ArraySlice(pins)
      setValue(newValue, pins: &pins)
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
    return try strategy.merge(ctx: &ctx, old: consume self, new: other).get()
  }

  public mutating func merge(_ other: Self, replace: Bool) {
    self = merging(other, strategy: SelectOneMergeStrategy(selectNew: replace))
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
