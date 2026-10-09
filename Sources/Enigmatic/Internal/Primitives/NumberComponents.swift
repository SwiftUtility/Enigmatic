import Foundation

@usableFromInline
struct NumberComponents: Equatable {
  var low: UInt64 = 0
  var high: UInt64 = 0
  var exponent: Int32 = 0
  var isNegative: Bool = false
  var isInfinite: Bool = false
  var isNan: Bool = false

  @usableFromInline
  init(_ box: Enigma.UInt128Box) {
    low = box.low
    high = box.high
    normalize()
  }

  @usableFromInline
  init(_ box: Enigma.Int128Box) {
    isNegative = box.high >> 63 != 0
    if isNegative {
      let (magnitudeLow, carry) = (~box.low).addingReportingOverflow(1)
      low = magnitudeLow
      high = (~box.high) &+ (carry ? 1 : 0)
    } else {
      low = box.low
      high = box.high
    }
    normalize()
  }

  @usableFromInline
  init<T: FixedWidthInteger>(_ value: T) {
    guard value != 0 else { return }
    isNegative = value < 0
    let magnitude = value.magnitude
    high = UInt64(magnitude >> 64)
    low = UInt64(truncatingIfNeeded: magnitude)
    normalize()
  }

  @usableFromInline
  init(_ value: Float) {
    guard value != 0 else { return }
    isNan = value.isNaN
    guard !isNan else { return }
    isNegative = value < 0
    isInfinite = !value.isFinite
    guard !isInfinite else { return }
    let components = AlgoRyu.FloatComponents.resolve(float: value)
    low = UInt64(components.mantissa)
    exponent = components.exponent
    normalize()
  }

  @usableFromInline
  init(_ value: Double) {
    guard value != 0 else { return }
    isNan = value.isNaN
    guard !isNan else { return }
    isNegative = value < 0
    isInfinite = !value.isFinite
    guard !isInfinite else { return }
    let components = AlgoRyu.DoubleComponents.resolve(double: value)
    low = components.mantissa
    exponent = components.exponent
    normalize()
  }

  @usableFromInline
  func asInteger<T: FixedWidthInteger>(_: T.Type = T.self) -> T? {
    guard exponent >= 0, !isNan, !isInfinite else { return nil }
    guard high != 0 || low != 0 else { return exponent == 0 ? 0 : nil }
    guard T.isSigned || !isNegative else { return nil }

    var magnitude: T.Magnitude

    if T.bitWidth == 128 {
      magnitude = (T.Magnitude(high) << 64) | T.Magnitude(truncatingIfNeeded: low)
    } else if high == 0, let value = T.Magnitude(exactly: low) {
      magnitude = value
    } else {
      return nil
    }

    for _ in 0..<exponent {
      let (value, overflow) = magnitude.multipliedReportingOverflow(by: 10)
      guard !overflow else { return nil }
      magnitude = value
    }

    if isNegative {
      guard magnitude <= T.max.magnitude + 1 else { return nil }
      let bits = T(truncatingIfNeeded: magnitude)
      return 0 &- bits
    } else {
      guard magnitude <= T.max.magnitude else { return nil }
      return T(truncatingIfNeeded: magnitude)
    }

  }

  @usableFromInline
  var asFloat: Float? {
    guard !isNan else { return .nan }
    guard !isInfinite else { return isNegative ? -.infinity : .infinity }
    guard let value = restoredDecimal else { return nil }
    let result = Float(value)
    guard result.isFinite else { return nil }
    guard NumberComponents(result) == self else { return nil }
    return result
  }

  @usableFromInline
  var asDouble: Double? {
    guard !isNan else { return .nan }
    guard !isInfinite else { return isNegative ? -.infinity : .infinity }
    guard let result = restoredDecimal else { return nil }
    guard NumberComponents(result) == self else { return nil }
    return result
  }

  @inline(__always)
  var restoredDecimal: Double? {
    var result = Double(high) * 18_446_744_073_709_551_616.0 + Double(low)
    var power = exponent
    while power >= 8 {
      result *= 100_000_000.0
      power -= 8
    }
    while power <= -8 {
      result /= 100_000_000.0
      power += 8
    }
    if power > 0 {
      result *= pow(10.0, Double(power))
    } else if power < 0 {
      result /= pow(10.0, Double(-power))
    }
    guard result.isFinite else { return nil }
    return isNegative ? -result : result
  }

  @usableFromInline
  mutating func normalize() {
    guard low != 0 || high != 0 else {
      exponent = 0
      isNegative = false
      return
    }
    let divisor = 10 as UInt64
    while true {
      if high == 0 {
        let pair = low.quotientAndRemainder(dividingBy: divisor)
        guard pair.remainder == 0 else { break }
        low = pair.quotient
      } else {
        let highPair = high.quotientAndRemainder(dividingBy: divisor)
        let lowPair = divisor.dividingFullWidth((high: highPair.remainder, low: low))
        guard lowPair.remainder == 0 else { break }
        high = highPair.quotient
        low = lowPair.quotient
      }
      exponent += 1
    }
  }

  static let exactFloat: UInt32 = 16_777_216
  static let exactDouble: UInt64 = 9_007_199_254_740_992
}
