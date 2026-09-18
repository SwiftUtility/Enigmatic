import Foundation

extension Enigma {
  public enum Base64Data: DecodeStrategy, EncodeStrategy, Error {
    case invalidString(String)

    public static func decode(key: String) throws -> Data {
      if let data = Data(base64Encoded: key) {
        data
      } else {
        throw Self.invalidString(key)
      }
    }

    public static func encode(value: Data) throws -> String {
      value.base64EncodedString()
    }

    public typealias CodecValue = Data
    public typealias CodecKey = String
  }
}
