extension BinaryFloatingPoint {
  static func isNearlyEqual(_ lhs: Self?, _ rhs: Self?) -> Bool {
    guard let lhs, let rhs else { return false }
    guard lhs != rhs else { return true }
    let absLhs = abs(lhs)
    let absRhs = abs(rhs)
    let diff = abs(lhs - rhs)
    let sum = absLhs + absRhs
    return if lhs == .zero || rhs == .zero || sum < .leastNormalMagnitude {
      diff < .ulpOfOne * .leastNormalMagnitude
    } else {
      diff < .ulpOfOne * min(sum, .greatestFiniteMagnitude)
    }
  }

  var asFloat: Float? {
    let result = Float(self)
    return if result.isFinite || !isFinite { result } else { nil }
  }
}
