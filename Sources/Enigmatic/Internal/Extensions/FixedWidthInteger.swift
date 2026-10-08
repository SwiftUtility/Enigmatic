extension FixedWidthInteger {
  @usableFromInline
  var asDouble: Double? {
    guard isOverDouble else { return Double(exactly: self) }
    return NumberComponents(self).asDouble
  }

  @usableFromInline
  var asFloat: Float? {
    guard isOverFloat else { return Float(exactly: self) }
    return NumberComponents(self).asFloat
  }

  var isOverDouble: Bool {
    if let limit = Magnitude(exactly: NumberComponents.exactDouble) {
      magnitude > limit
    } else {
      true
    }
  }

  var isOverFloat: Bool {
    if let limit = Magnitude(exactly: NumberComponents.exactFloat) {
      magnitude > limit
    } else {
      true
    }
  }
}
