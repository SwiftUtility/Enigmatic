import Foundation
#if os(anyAppleOS) || os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
import System
#endif

extension Codec {
  /// Encodes a file URL as its filesystem path and decodes path strings as file URLs.
  public enum PathURL: Hashable, DecodeStrategy, EncodeStrategy {
    /// Decodes a filesystem path string as a file URL.
    /// - Complexity: O(n) in the URL or path string length.
    @inlinable
    public static func decode(decoder: some Decoder) throws -> BoxedValue {
      let value = try String(from: decoder)
#if os(anyAppleOS) || os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
      if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
        guard let url = URL(filePath: FilePath(value), directoryHint: .inferFromPath) else {
          throw DecodingError.dataCorrupted(DecodingError.Context(
             codingPath: decoder.codingPath,
             debugDescription: "Not valid path string: \(value)"
           ))
        }
        return url
      } else {
        return URL(fileURLWithPath: value, isDirectory: value.hasSuffix("/"))
      }
#elseif os(Linux)
      return URL(fileURLWithPath: value, isDirectory: value.hasSuffix("/"))
#elseif os(Windows)
      return URL(fileURLWithPath: value, isDirectory: value.hasSuffix("/") || value.hasSuffix("\\"))
#else
#error("Unsupported platform: Enigmatic supports Apple platforms, Linux, and Windows.")
#endif
    }

    /// Encodes the URL's unescaped filesystem path as a string.
    /// Windows paths use forward slashes and preserve a trailing directory separator.
    /// - Complexity: O(n) in the URL or path string length.
    @inlinable
    public static func encode(value: BoxedValue, encoder: some Encoder) throws {
#if os(anyAppleOS) || os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
      if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
        try value.path(percentEncoded: false).encode(to: encoder)
      } else {
        try value.path.encode(to: encoder)
      }
#elseif os(Linux)
      try value.path(percentEncoded: false).encode(to: encoder)
#elseif os(Windows)
      var path = value.path
      if value.hasDirectoryPath && !path.hasSuffix("/") { path += "/" }
      try path.encode(to: encoder)
#else
#error("Unsupported platform: Enigmatic supports Apple platforms, Linux, and Windows.")
#endif
    }

    /// The decoded and encoded value type.
    public typealias BoxedValue = URL
  }
}
