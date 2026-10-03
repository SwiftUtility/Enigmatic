import Foundation

extension Codec {
  /// Encodes a URL as its absolute string; decoding accepts Foundation URL syntax, including relative URLs.
  public enum StringURL: Hashable, DecodeStrategy, EncodeStrategy {
    /// Decodes a string using Foundation's URL parser.
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

    /// Encodes the URL's absolute string representation.
    @inlinable
    public static func encode(value: BoxedValue, encoder: some Encoder) throws {
      try value.absoluteString.encode(to: encoder)
    }

    /// The decoded and encoded value type.
    public typealias BoxedValue = URL
  }
}
