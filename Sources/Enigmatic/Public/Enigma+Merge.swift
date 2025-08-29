public extension Enigma {
  /// Attempt to combine value with original
  mutating func merge<E: Error>(_ other: Self, or resolve: ([Pin], Self, Self) throws(E) -> Self) throws(E) {
    var pins: [Pin] = []
    self = try merge(other, pins: &pins, resolve: resolve)
  }

  /// Attempt to write encoded value merging with original
  mutating func merge(encode value: any Encodable, or resolve: ([Pin], Self, Self) throws -> Self) throws {
    var pins: [Pin] = []
    self = try merge(Enigma(encode: value), pins: &pins, resolve: resolve)
  }

  /// Attempt to combine value with original
  func merging<E: Error>(_ other: Self, or resolve: ([Pin], Self, Self) throws(E) -> Self) throws(E) -> Self {
    var pins: [Pin] = []
    return try merge(other, pins: &pins, resolve: resolve)
  }

  /// Attempt to write encoded value merging with original
  func merging(encode value: any Encodable, or resolve: ([Pin], Self, Self) throws -> Self) throws -> Self {
    var pins: [Pin] = []
    return try merge(Enigma(encode: value), pins: &pins, resolve: resolve)
  }

  static let replace = { @Sendable (_: [Pin], _: Self, rhs: Self) -> Self in
    rhs
  }

  static let skipEqual = { @Sendable (pins: [Pin], lhs: Self, rhs: Self) throws(EncodingError) -> Self in
    if lhs == rhs { lhs } else { try fail(pins, lhs, rhs) }
  }

  static let fail = { @Sendable (pins: [Pin], lhs: Self, rhs: Self) throws(EncodingError) -> Self in
    throw EncodingError.invalidValue(rhs, EncodingError.Context(
      codingPath: pins,
      debugDescription: "attempt to replace \(lhs.debugDescription)"
    ))
  }
}
