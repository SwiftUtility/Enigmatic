extension Double {
  @usableFromInline
  var asFloat: Float? {
    guard isFinite else { return Float(self) }
    return NumberComponents(self).asFloat
  }

  func isSame(double value: Double?) -> Bool {
    guard let value else { return false }
    guard !isNaN else { return value.isNaN }
    return self == value
  }

  func isSame<T: FixedWidthInteger>(integer value: T) -> Bool {
    guard isFinite else { return false }
    guard value.isOverDouble else { return Self(value) == self }
    return NumberComponents(value).asDouble == self
  }

  @usableFromInline
  func asInteger<T: FixedWidthInteger>(_: T.Type = T.self) -> T? {
    guard isFinite else { return nil }
    guard magnitude > Self(NumberComponents.exactDouble) else { return T(exactly: self) }
    return NumberComponents(self).asInteger()
  }
}
