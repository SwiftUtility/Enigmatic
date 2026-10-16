extension Double {
  @usableFromInline
  var asFloat: Float? {
    let result = Float(self)
    return if isFinite == result.isFinite, isZero == result.isZero { result } else { nil }
  }

  func isSame(double value: Double?) -> Bool {
    guard let value else { return false }
    guard !isNaN else { return value.isNaN }
    return self == value
  }
}
