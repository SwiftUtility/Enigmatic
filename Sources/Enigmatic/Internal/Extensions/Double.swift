extension Double {
  @usableFromInline
  var asFloat: Float? {
    guard isFinite else { return Float(self) }
    return Float(exactly: self) ?? NumberComponents(self).asFloat
  }

  func isSame(double value: Double?) -> Bool {
    guard let value else { return false }
    guard !isNaN else { return value.isNaN }
    return self == value
  }

  func isSame<T: FixedWidthInteger>(integer value: T) -> Bool {
    guard Self(value) == self else { return false }
    guard T(exactly: self) != value else { return true }
    return NumberComponents(value).asDouble == self
  }

  @usableFromInline
  func asInteger<T: FixedWidthInteger>(_: T.Type = T.self) -> T? {
    guard isFinite else { return nil }
    return T(exactly: self) ?? NumberComponents(self).asInteger()
  }
}
