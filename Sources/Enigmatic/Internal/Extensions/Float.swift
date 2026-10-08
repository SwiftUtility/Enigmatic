extension Float {
  @usableFromInline
  var asDouble: Double? {
    guard isFinite else { return Double(self) }
    return NumberComponents(self).asDouble
  }

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
    guard isFinite else { return false }
    guard value.isOverFloat else { return Self(value) == self }
    return NumberComponents(value).asFloat == self
  }

  @usableFromInline
  func asInteger<T: FixedWidthInteger>(_: T.Type = T.self) -> T? {
    guard isFinite else { return nil }
    guard magnitude > Self(NumberComponents.exactFloat) else { return T(exactly: self) }
    return NumberComponents(self).asInteger()
  }
}
