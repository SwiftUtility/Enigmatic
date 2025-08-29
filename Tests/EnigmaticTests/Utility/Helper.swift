import Foundation

class Helper: @unchecked Sendable {
  private let jsonEncoder = JSONEncoder()
  private let jsonDecoder = JSONDecoder()
  private let xmlEncoder = PropertyListEncoder()
  private let binEncoder = PropertyListEncoder()
  private let plistDecoder = PropertyListDecoder()

  private init() {
    jsonEncoder.nonConformingFloatEncodingStrategy = .convertToString(
      positiveInfinity: "Infinity", negativeInfinity: "-Infinity", nan: "NaN"
    )
    jsonDecoder.nonConformingFloatDecodingStrategy = .convertFromString(
      positiveInfinity: "Infinity", negativeInfinity: "-Infinity", nan: "NaN"
    )
    xmlEncoder.outputFormat = .xml
    binEncoder.outputFormat = .binary
  }

  private static let shared = Helper()

  static func enjson<T: Encodable>(_ value: T) throws -> Data {
    try shared.jsonEncoder.encode(value)
  }

  static func dejson<T: Decodable>(_: T.Type = T.self, from data: Data) throws -> T {
    try shared.jsonDecoder.decode(T.self, from: data)
  }

  static func enxml<T: Encodable>(_ value: T) throws -> Data {
    try shared.xmlEncoder.encode(value)
  }

  static func enbin<T: Encodable>(_ value: T) throws -> Data {
    try shared.binEncoder.encode(value)
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
