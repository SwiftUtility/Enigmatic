extension Enigma: ExpressibleByIntegerLiteral {
  /// Creates an integer tree value from an integer literal.
  /// - Complexity: O(1) for the literal value.
  public init(integerLiteral value: IntegerLiteralType) {
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
    } else {
      .int(value)
    }
  }
}
