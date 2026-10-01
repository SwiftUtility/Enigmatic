import Foundation

extension Codec {
  public enum Base64Data: DecodeStrategy, EncodeStrategy {
    @inlinable
    public static func decode(decoder: some Decoder) throws -> BoxedValue {
      let value = try String(from: decoder)
      if let result = Data(base64Encoded: value) {
        return result
      } else {
        throw DecodingError.dataCorrupted(DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: "Not base64 encoded data: \(value)"
        ))
      }
    }

    @inlinable
    public static func encode(value: BoxedValue, encoder: some Encoder) throws {
      try value.base64EncodedString().encode(to: encoder)
    }

    public typealias BoxedValue = Data
  }
}
