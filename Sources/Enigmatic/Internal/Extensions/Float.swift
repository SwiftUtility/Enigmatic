extension Float {
  func isSame(float value: Float) -> Bool {
    guard !isNaN else { return value.isNaN }
    return self == value
  }

  func isSame(double value: Double) -> Bool {
    guard !isNaN else { return value.isNaN }
    guard Self(value) == self else { return false }
    return NumberComponents(self).asDouble == value
  }

  func isSame<T: FixedWidthInteger>(integer value: T) -> Bool {
    guard !isNaN else { return false }
    guard Self(value) == self else { return false }
    guard T(exactly: self) != value else { return true }
    return NumberComponents(value).asFloat == self
  }

  @usableFromInline
  func asInteger<T: FixedWidthInteger>(_: T.Type = T.self) -> T? {
    guard isFinite else { return nil }
    return T(exactly: self) ?? NumberComponents(self).asInteger()
  }
}
