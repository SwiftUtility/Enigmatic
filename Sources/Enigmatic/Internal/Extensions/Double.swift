extension Double {
  var asFloat: Float? {
    let retult = Float(self)
    return if !isFinite || retult.isFinite { retult } else { nil }
  }

  func isSame(double: Double?) -> Bool {
    guard let double else { return false }
    guard !isNaN else { return double.isNaN }
    return self == double
  }
}
