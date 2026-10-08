extension FixedWidthInteger {
  @usableFromInline
  var asDouble: Double? {
    Double(exactly: self) ?? NumberComponents(self).asDouble
  }

  @usableFromInline
  var asFloat: Float? {
    Float(exactly: self) ?? NumberComponents(self).asFloat
  }
}
