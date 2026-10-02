public extension Enigma {
  /// Recursively merges dictionaries and resolves all other pairs as whole values.
  ///
  /// The original value is unchanged if the resolver throws. Dictionary conflict
  /// visitation order is unspecified.
  mutating func merge<E: Error>(_ other: Self, or resolve: ([Pin], Self, Self) throws(E) -> Self) throws(E) {
    var pins: [Pin] = []
    self = try merge(other, pins: &pins, resolve: resolve)
  }

  /// Attempt to write encoded value merging with original
  mutating func merge(encode value: any Encodable, or resolve: ([Pin], Self, Self) throws -> Self) throws {
    var pins: [Pin] = []
    self = try merge(Enigma(encode: value), pins: &pins, resolve: resolve)
  }

  /// Recursively merges dictionaries and resolves all other pairs as whole values.
  ///
  /// The original value is unchanged if the resolver throws. Dictionary conflict
  /// visitation order is unspecified.
  consuming func merging<E: Error>(_ other: Self, or resolve: ([Pin], Self, Self) throws(E) -> Self) throws(E) -> Self {
    var pins: [Pin] = []
    return try merge(other, pins: &pins, resolve: resolve)
  }

  /// Attempt to write encoded value merging with original
  consuming func merging(encode value: any Encodable, or resolve: ([Pin], Self, Self) throws -> Self) throws -> Self {
    var pins: [Pin] = []
    return try merge(Enigma(encode: value), pins: &pins, resolve: resolve)
  }

  /// Chooses the present value for a conflict.
  static let skip = { @Sendable (_: [Pin], lhs: Self, _: Self) -> Self in
    lhs
  }

  /// Chooses the incoming value for a conflict.
  static let replace = { @Sendable (_: [Pin], _: Self, rhs: Self) -> Self in
    rhs
  }

  /// Accepts equal values, otherwise throws an EncodingError with the conflict path.
  static let skipEqual = { @Sendable (pins: [Pin], lhs: Self, rhs: Self) throws(EncodingError) -> Self in
    if lhs == rhs { lhs } else { try fail(pins, lhs, rhs) }
  }

  /// Rejects every conflict with an EncodingError containing its path.
  static let fail = { @Sendable (pins: [Pin], lhs: Self, rhs: Self) throws(EncodingError) -> Self in
    throw EncodingError.invalidValue(rhs, EncodingError.Context(
      codingPath: pins,
      debugDescription: "attempt to replace \(lhs.debugDescription)"
    ))
  }
}
