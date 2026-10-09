extension AlgoRyu {
  struct FloatComponents {
    let mantissa: UInt32
    let exponent: Int32

    @inline(__always)
    static func resolve(float: Float) -> Self {
      let bits = float.bitPattern
      let ieeeMantissa = bits & 0x007F_FFFF
      let ieeeExponent = (bits >> mantissaBits) & exponentMask

      let e2: Int32
      let m2: UInt32

      if ieeeExponent == 0 {
        e2 = 1 - bias - mantissaBits - 2
        m2 = ieeeMantissa
      } else {
        e2 = Int32(ieeeExponent) - bias - mantissaBits - 2
        m2 = (UInt32(1) << mantissaBits) | ieeeMantissa
      }

      let acceptBounds = (m2 & 1) == 0
      let mv = 4 &* m2
      let mp = 4 &* m2 &+ 2
      let mmShift: UInt32 = (ieeeMantissa != 0 || ieeeExponent <= 1) ? 1 : 0
      let mm = 4 &* m2 &- 1 &- mmShift

      var vr: UInt32
      var vp: UInt32
      var vm: UInt32
      let e10: Int32
      var vmTrailing = false
      var vrTrailing = false
      var lastRemovedDigit: UInt32 = 0

      if e2 >= 0 {
        let q = log10Pow2(e2)
        e10 = Int32(q)
        let k = pow5InvBitCount + pow5Bits(Int32(q)) - 1
        let i = -e2 + Int32(q) + k

        vr = mulPow5InvDivPow2(mv, q, i)
        vp = mulPow5InvDivPow2(mp, q, i)
        vm = mulPow5InvDivPow2(mm, q, i)

        if q != 0 && (vp - 1) / 10 <= vm / 10 {
          let q1 = q - 1
          let l = pow5InvBitCount + pow5Bits(Int32(q1)) - 1
          lastRemovedDigit = mulPow5InvDivPow2(
            mv,
            q1,
            -e2 + Int32(q) - 1 + l
          ) % 10
        }

        if q <= 9 {
          if mv % 5 == 0 {
            vrTrailing = multipleOfPowerOf5(UInt64(mv), q)
          } else if acceptBounds {
            vmTrailing = multipleOfPowerOf5(UInt64(mm), q)
          } else if multipleOfPowerOf5(UInt64(mp), q) {
            vp &-= 1
          }
        }
      } else {
        let minusE2 = -e2
        let q = log10Pow5(minusE2)
        e10 = Int32(q) + e2
        let i = minusE2 - Int32(q)
        let k = pow5Bits(i) - pow5BitCount
        var j = Int32(q) - k

        vr = mulPow5DivPow2(mv, UInt32(i), j)
        vp = mulPow5DivPow2(mp, UInt32(i), j)
        vm = mulPow5DivPow2(mm, UInt32(i), j)

        if q != 0 && (vp - 1) / 10 <= vm / 10 {
          j = Int32(q) - 1 - (pow5Bits(i + 1) - pow5BitCount)
          lastRemovedDigit = mulPow5DivPow2(mv, UInt32(i + 1), j) % 10
        }

        if q <= 1 {
          vrTrailing = true
          if acceptBounds {
            vmTrailing = mmShift == 1
          } else {
            vp &-= 1
          }
        } else if q < 31 {
          vrTrailing = UInt64(mv).trailingZeroBitCount >= Int(q - 1)
        }
      }

      var removed: Int32 = 0
      let output: UInt32

      if vmTrailing || vrTrailing {
        while true {
          let (vp10, _) = vp.quotientAndRemainder(dividingBy: 10)
          let (vm10, vmDigit) = vm.quotientAndRemainder(dividingBy: 10)
          if vp10 <= vm10 { break }

          let (vr10, vrDigit) = vr.quotientAndRemainder(dividingBy: 10)
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
            let (vm10, vmDigit) = vm.quotientAndRemainder(dividingBy: 10)
            if vmDigit != 0 { break }

            let (vp10, _) = vp.quotientAndRemainder(dividingBy: 10)
            let (vr10, vrDigit) = vr.quotientAndRemainder(dividingBy: 10)
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

        output = vr + (
          (vr == vm && (!acceptBounds || !vmTrailing)) || lastRemovedDigit >= 5
          ? 1 : 0
        )
      } else {
        var roundUp = false

        let (vp100, _) = vp.quotientAndRemainder(dividingBy: 100)
        let (vm100, _) = vm.quotientAndRemainder(dividingBy: 100)
        if vp100 > vm100 {
          let (vr100, vrRemainder) = vr.quotientAndRemainder(dividingBy: 100)
          roundUp = vrRemainder >= 50
          vr = vr100
          vp = vp100
          vm = vm100
          removed += 2
        }

        while true {
          let (vp10, _) = vp.quotientAndRemainder(dividingBy: 10)
          let (vm10, _) = vm.quotientAndRemainder(dividingBy: 10)
          if vp10 <= vm10 { break }

          let (vr10, vrRemainder) = vr.quotientAndRemainder(dividingBy: 10)
          roundUp = vrRemainder >= 5
          vr = vr10
          vp = vp10
          vm = vm10
          removed += 1
        }
        output = vr + ((vr == vm || roundUp) ? 1 : 0)
      }

      return Self(mantissa: output, exponent: e10 + removed)
    }

    static let exponentMask: UInt32 = 0xFF
    static let mantissaMask: UInt32 = 0x007F_FFFF
    static let mantissaBits: Int32 = 23
    static let bias: Int32 = 127
    static let pow5InvBitCount: Int32 = DoubleComponents.pow5InvBitCount - 64
    static let pow5BitCount: Int32 = DoubleComponents.pow5BitCount - 64
  }
}
