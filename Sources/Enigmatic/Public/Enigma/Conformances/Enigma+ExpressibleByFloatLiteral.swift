extension Enigma: ExpressibleByFloatLiteral {
  /// Creates a floating-point tree value from a floating-point literal.
  public init(floatLiteral value: FloatLiteralType) {
    self = if let value = UInt8(exactly: value) {
      .uint8(value)
    } else if let value = Int8(exactly: value) {
      .int8(value)
    } else if let value = UInt16(exactly: value) {
      .uint16(value)
    } else if let value = Int16(exactly: value) {
      .int16(value)
    } else if let value = UInt32(exactly: value) {
      .uint32(value)
    } else if let value = Int32(exactly: value) {
      .int32(value)
    } else if let value = UInt64(exactly: value) {
      .uint64(value)
    } else if let value = Int64(exactly: value) {
      .int64(value)
    } else if let value = UInt(exactly: value) {
      .uint(value)
    } else if let value = Int(exactly: value) {
      .int(value)
    } else if let value = Float(exactly: value) {
      .float(value)
    } else {
      .double(value)
    }
  }
}
