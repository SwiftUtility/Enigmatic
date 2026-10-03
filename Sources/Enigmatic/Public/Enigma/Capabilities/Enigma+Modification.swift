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
}
