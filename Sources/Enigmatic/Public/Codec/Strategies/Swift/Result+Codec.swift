extension Result: Codec.Strategy where Success: Codec.Strategy {
  public typealias BoxedValue = Result<Success.BoxedValue, Failure>
}

extension Result: Codec.DecodeStrategy where Success: Codec.DecodeStrategy, Failure == any Error {
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
