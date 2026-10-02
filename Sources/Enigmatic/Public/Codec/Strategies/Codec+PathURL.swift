import Foundation
#if os(anyAppleOS) || os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
import System
#endif

extension Codec {
  /// Encodes a URL as its absolute string; decoding accepts Foundation FilePath syntax
  public enum PathURL: Hashable, DecodeStrategy, EncodeStrategy {
    @inlinable
    public static func decode(decoder: some Decoder) throws -> BoxedValue {
      let value = try String(from: decoder)
      let url: URL?
#if os(anyAppleOS) || os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
      url = if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
        URL(filePath: FilePath(value), directoryHint: .inferFromPath)
      } else {
        URL(fileURLWithPath: value, isDirectory: value.hasSuffix("/"))
      }
#else
      url = URL(fileURLWithPath: value, isDirectory: value.hasSuffix("/"))
#endif
      if let url {
        return url
      } else {
        throw DecodingError.dataCorrupted(DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: "Not valid path string: \(value)"
        ))
      }
    }

    @inlinable
    public static func encode(value: BoxedValue, encoder: some Encoder) throws {
      if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
        try value.path(percentEncoded: false).encode(to: encoder)
      } else {
        try value.path.encode(to: encoder)
      }
    }

    public typealias BoxedValue = URL
  }
}
