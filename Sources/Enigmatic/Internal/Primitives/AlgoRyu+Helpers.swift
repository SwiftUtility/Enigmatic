extension AlgoRyu {
  @inline(__always)
  static func log10Pow2(_ e: Int32) -> UInt32 {
    UInt32((UInt64(UInt32(e)) * 78_913) >> 18)
  }

  @inline(__always)
  static func log10Pow5(_ e: Int32) -> UInt32 {
    UInt32((UInt64(UInt32(e)) * 732_923) >> 20)
  }

  @inline(__always)
  static func pow5Bits(_ e: Int32) -> Int32 {
    Int32((UInt64(UInt32(e)) * 1_217_359) >> 19) + 1
  }

  @inline(__always)
  static func multipleOfPowerOf2(_ value: UInt64, _ p: UInt32) -> Bool {
    p == 0 || value.trailingZeroBitCount >= Int(p)
  }

  @inline(__always)
  static func multipleOfPowerOf5(_ value: UInt64, _ p: UInt32) -> Bool {
    var value = value
    var p = p
    while p != 0 {
      guard value % 5 == 0 else { return false }
      value /= 5
      p -= 1
    }
    return true
  }

  /// `(m * 128-bit multiplier) >> j`, where the multiplier is represented by
  /// two `UInt64` words. This mirrors Ryu's 64x128 -> shifted-64 primitive.
  @inline(__always)
  static func mulShift64(_ m: UInt64, _ mul: Enigma.UInt128Box, _ j: Int32) -> UInt64 {
    let p0 = m.multipliedFullWidth(by: mul.low)
    let p1 = m.multipliedFullWidth(by: mul.high)
    let (middle, carry) = p0.high.addingReportingOverflow(p1.low)
    let high = p1.high &+ (carry ? 1 : 0)
    let shift = Int(j - 64)

    if shift == 0 { return middle }
    return (middle >> shift) | (high << (64 - shift))
  }

  /// Ryu float primitive using the full-width product of a 32-bit significand
  /// and a 64-bit table factor.
  @inline(__always)
  static func mulShift32(_ m: UInt32, _ factor: UInt64, _ shift: Int32) -> UInt32 {
    let product = UInt64(m).multipliedFullWidth(by: factor)
    let shift = Int(shift)
    let result: UInt64
    if shift >= 64 {
      result = product.high >> (shift - 64)
    } else {
      result = (product.low >> shift) | (product.high << (64 - shift))
    }
    return UInt32(result)
  }

  @inline(__always)
  static func mulPow5InvDivPow2(_ m: UInt32, _ q: UInt32, _ j: Int32) -> UInt32 {
    // Ryu f2s reuses the upper word of the double table. The inverse table
    // stores floor(2^k / 5^q) + 1; after dropping the lower 64 bits, one is
    // added again for the float multiplier.
    mulShift32(m, pow5InvSplit[Int(q)].high &+ 1, j)
  }

  @inline(__always)
  static func mulPow5DivPow2(_ m: UInt32, _ i: UInt32, _ j: Int32) -> UInt32 {
    mulShift32(m, pow5Split[Int(i)].high, j)
  }
}
