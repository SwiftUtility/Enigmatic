extension AlgoRyu {
  struct DoubleComponents {
    let mantissa: UInt64
    let exponent: Int32

    @inline(__always)
    static func resolve(double value: Double) -> Self {
      let bits = value.bitPattern
      let ieeeMantissa = bits & mantissaMask
      let ieeeExponent = UInt32((bits & exponentMask) >> mantissaBits)
      return smallInteger(
        ieeeMantissa: ieeeMantissa, ieeeExponent: ieeeExponent
      ) ?? double(
        ieeeMantissa: ieeeMantissa, ieeeExponent: ieeeExponent
      )
    }

    @inline(__always)
    static func smallInteger(ieeeMantissa: UInt64, ieeeExponent: UInt32) -> Self? {
      guard ieeeExponent != 0 else { return nil }

      let m2 = (UInt64(1) << mantissaBits) | ieeeMantissa
      let e2 = Int32(ieeeExponent) - bias - mantissaBits
      guard e2 <= 0, e2 >= -mantissaBits else { return nil }

      let shift = Int(-e2)
      let mask: UInt64 = shift == 0 ? 0 : (UInt64(1) << shift) - 1
      guard (m2 & mask) == 0 else { return nil }

      return Self(mantissa: m2 >> shift, exponent: 0)
    }

    @inline(__always)
    static func double(ieeeMantissa: UInt64, ieeeExponent: UInt32) -> Self {
      let e2: Int32
      let m2: UInt64

      if ieeeExponent == 0 {
        e2 = 1 - bias - mantissaBits - 2
        m2 = ieeeMantissa
      } else {
        e2 = Int32(ieeeExponent) - bias - mantissaBits - 2
        m2 = (UInt64(1) << mantissaBits) | ieeeMantissa
      }

      let acceptBounds = (m2 & 1) == 0
      let mv = 4 &* m2
      let mmShift: UInt64 = (ieeeMantissa != 0 || ieeeExponent <= 1) ? 1 : 0

      var vr: UInt64
      var vp: UInt64
      var vm: UInt64
      let e10: Int32
      var vmTrailing = false
      var vrTrailing = false

      if e2 >= 0 {
        let q = log10Pow2(e2) - (e2 > 3 ? 1 : 0)
        e10 = Int32(q)
        let k = pow5InvBitCount + pow5Bits(Int32(q)) - 1
        let i = -e2 + Int32(q) + k
        let mul = pow5InvSplit[Int(q)]

        vr = mulShift64(4 &* m2, mul, i)
        vp = mulShift64(4 &* m2 &+ 2, mul, i)
        vm = mulShift64(4 &* m2 &- 1 &- mmShift, mul, i)

        if q <= 21 {
          if mv % 5 == 0 {
            vrTrailing = multipleOfPowerOf5(mv, q)
          } else if acceptBounds {
            vmTrailing = multipleOfPowerOf5(mv &- 1 &- mmShift, q)
          } else if multipleOfPowerOf5(mv &+ 2, q) {
            vp &-= 1
          }
        }
      } else {
        let minusE2 = -e2
        let q = log10Pow5(minusE2) - (minusE2 > 1 ? 1 : 0)
        e10 = Int32(q) + e2
        let i = minusE2 - Int32(q)
        let k = pow5Bits(i) - pow5BitCount
        let j = Int32(q) - k
        let mul = pow5Split[Int(i)]

        vr = mulShift64(4 &* m2, mul, j)
        vp = mulShift64(4 &* m2 &+ 2, mul, j)
        vm = mulShift64(4 &* m2 &- 1 &- mmShift, mul, j)

        if q <= 1 {
          vrTrailing = true
          if acceptBounds {
            vmTrailing = mmShift == 1
          } else {
            vp &-= 1
          }
        } else if q < 63 {
          vrTrailing = multipleOfPowerOf2(mv, q)
        }
      }

      var removed: Int32 = 0
      var lastRemovedDigit: UInt64 = 0
      let output: UInt64

      if vmTrailing || vrTrailing {
        while true {
          let vp10 = vp / 10
          let vm10 = vm / 10
          if vp10 <= vm10 { break }

          let vmDigit = vm - vm10 * 10
          let vr10 = vr / 10
          let vrDigit = vr - vr10 * 10

          vmTrailing = vmTrailing && vmDigit == 0
          vrTrailing = vrTrailing && lastRemovedDigit == 0
          lastRemovedDigit = vrDigit
          vr = vr10
          vp = vp10
          vm = vm10
          removed += 1
        }

        if vmTrailing {
          while true {
            let vm10 = vm / 10
            let vmDigit = vm - vm10 * 10
            if vmDigit != 0 { break }

            let vp10 = vp / 10
            let vr10 = vr / 10
            let vrDigit = vr - vr10 * 10
            vrTrailing = vrTrailing && lastRemovedDigit == 0
            lastRemovedDigit = vrDigit
            vr = vr10
            vp = vp10
            vm = vm10
            removed += 1
          }
        }

        if vrTrailing && lastRemovedDigit == 5 && (vr & 1) == 0 {
          lastRemovedDigit = 4
        }

        let roundUp =
        (vr == vm && (!acceptBounds || !vmTrailing)) ||
        lastRemovedDigit >= 5
        output = vr + (roundUp ? 1 : 0)
      } else {
        var roundUp = false

        let vp100 = vp / 100
        let vm100 = vm / 100
        if vp100 > vm100 {
          let vr100 = vr / 100
          roundUp = vr - vr100 * 100 >= 50
          vr = vr100
          vp = vp100
          vm = vm100
          removed += 2
        }

        while true {
          let vp10 = vp / 10
          let vm10 = vm / 10
          if vp10 <= vm10 { break }

          let vr10 = vr / 10
          roundUp = vr - vr10 * 10 >= 5
          vr = vr10
          vp = vp10
          vm = vm10
          removed += 1
        }

        output = vr + ((vr == vm || roundUp) ? 1 : 0)
      }

      return Self(mantissa: output, exponent: e10 + removed)
    }

    static let exponentMask: UInt64 = 0x7FF0_0000_0000_0000
    static let mantissaMask: UInt64 = 0x000F_FFFF_FFFF_FFFF
    static let mantissaBits: Int32 = 52
    static let bias: Int32 = 1023
    static let pow5InvBitCount: Int32 = 125
    static let pow5BitCount: Int32 = 125
  }
}
