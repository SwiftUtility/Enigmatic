import Foundation

extension Codec {
  public enum StringURL: DecodeStrategy, EncodeStrategy {
    @inlinable
    public static func decode(decoder: some Decoder) throws -> BoxedValue {
      let value = try String(from: decoder)
      if let result = URL(string: value) {
        return result
      } else {
        throw DecodingError.dataCorrupted(DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: "Not valid URL string: \(value)"
        ))
      }
    }

    @inlinable
    public static func encode(value: BoxedValue, encoder: some Encoder) throws {
      try value.absoluteString.encode(to: encoder)
    }

    public typealias BoxedValue = URL
  }
}
