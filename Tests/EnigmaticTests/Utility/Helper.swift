import Foundation

class Helper {
  private let jsonEncoder = JSONEncoder()
  private let jsonDecoder = JSONDecoder()
  private let plistEncoder = PropertyListEncoder()
  private let plistDecoder = PropertyListDecoder()

  private init() {
    jsonEncoder.nonConformingFloatEncodingStrategy = .convertToString(
      positiveInfinity: "Infinity", negativeInfinity: "-Infinity", nan: "NaN"
    )
    jsonDecoder.nonConformingFloatDecodingStrategy = .convertFromString(
      positiveInfinity: "Infinity", negativeInfinity: "-Infinity", nan: "NaN"
    )
    plistEncoder.outputFormat = .xml
  }

  private static let shared = Helper()

  static func enjson<T: Encodable>(_ value: T) throws -> Data {
    try shared.jsonEncoder.encode(value)
  }

  static func dejson<T: Decodable>(_: T.Type = T.self, from data: Data) throws -> T {
    try shared.jsonDecoder.decode(T.self, from: data)
  }

  static func enplist<T: Encodable>(_ value: T) throws -> Data {
    try shared.plistEncoder.encode(value)
  }

  static func deplist<T: Decodable>(_: T.Type = T.self, from data: Data) throws -> T {
    try shared.plistDecoder.decode(T.self, from: data)
  }

  static func serialize(_ value: Any) throws -> Data {
    try JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed)
  }

  static func deserialize(_ data: Data) throws -> Any {
    try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
  }
}
