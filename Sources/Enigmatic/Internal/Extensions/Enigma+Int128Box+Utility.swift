extension Enigma.Int128Box {
  @usableFromInline
  func asFloatFallback() -> Float? {
    NumberComponents(self).asFloat
  }

  @usableFromInline
  func asDoubleFallback() -> Double? {
    NumberComponents(self).asDouble
  }

  @usableFromInline
  func asIntegerFallback<T: FixedWidthInteger>(_: T.Type = T.self) -> T? {
    if high == 0 {
      T(exactly: low)
    } else if high == .max, low.leadingZeroBitCount == 0 {
      T(exactly: Int64(bitPattern: low))
    } else {
      nil
    }
  }
}
