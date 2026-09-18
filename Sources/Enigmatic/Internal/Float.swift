extension Float {
  func isSame(double: Double) -> Bool {
    guard !isNaN else { return double.isNaN }
    let float = Float(double)
    guard float.isFinite else { return Double(self) == double }
    return self == float
  }

  func isSame(float: Float?) -> Bool {
    guard let float else { return false }
    guard !isNaN else { return float.isNaN }
    return self == float
  }
}
