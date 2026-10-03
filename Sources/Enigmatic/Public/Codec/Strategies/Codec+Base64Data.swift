import Foundation

extension Codec {
  /// Encodes Data as a Base64 string and rejects malformed Base64 on decoding.
  public enum Base64Data: Hashable, DecodeStrategy, EncodeStrategy {
    /// Decodes a Base64 string into `Data`, rejecting malformed input.
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

    /// Encodes data as a standard Base64 string.
    @inlinable
    public static func encode(value: BoxedValue, encoder: some Encoder) throws {
      try value.base64EncodedString().encode(to: encoder)
    }

    /// The decoded and encoded value type.
    public typealias BoxedValue = Data
  }
}
