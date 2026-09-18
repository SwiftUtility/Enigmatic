import Foundation

extension Enigma {
  public enum StringURL: DecodeStrategy, EncodeStrategy, Error {
    case invalidString(String)

    public static func decode(key: String) throws -> URL {
      if let url = URL(string: key) {
        url
      } else {
        throw Self.invalidString(key)
      }
    }

    public static func encode(value: URL) throws -> String {
      value.absoluteString
    }

    public typealias CodecValue = URL
    public typealias CodecKey = String
  }
}
