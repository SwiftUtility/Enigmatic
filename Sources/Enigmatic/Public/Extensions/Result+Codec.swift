extension Result: Codec.Strategy where Success: Codec.Strategy {
  /// The result type formed from the success strategy's boxed value and failure type.
  public typealias BoxedValue = Result<Success.BoxedValue, Failure>
}

extension Result: Codec.DecodeStrategy where Success: Codec.DecodeStrategy, Failure == any Error {
  /// Captures a success value or stores a thrown decoding error as `.failure`.
  /// - Complexity: The cost of the success strategy; a thrown decoding error is captured without retrying
  ///   another strategy.
  @inlinable
  public static func decode(decoder: some Decoder) throws -> BoxedValue {
    do {
      return try .success(Success.decode(decoder: decoder))
    } catch {
      return .failure(error)
    }
  }
}

extension Result: Codec.EncodeStrategy where Success: Codec.EncodeStrategy {
  /// Encodes a success value or throws an encoding error containing the stored failure.
  /// - Complexity: The cost of the success strategy; encoding a failure constructs and throws an error in O(1).
  @inlinable
  public static func encode(value: BoxedValue, encoder: some Encoder) throws {
    switch value {
    case .success(let success): try Success.encode(value: success, encoder: encoder)
    case .failure(let failure):
      throw EncodingError.invalidValue(BoxedValue.self, EncodingError.Context(
        codingPath: encoder.codingPath,
        debugDescription: "delayed error",
        underlyingError: failure
      ))
    }
  }
}
