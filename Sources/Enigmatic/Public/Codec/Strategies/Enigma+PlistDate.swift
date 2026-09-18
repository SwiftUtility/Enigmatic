import Foundation

extension Enigma {
  public enum PlistDate: DecodeStrategy, EncodeStrategy, Error {
    case invalidKey(Double)
    case invalidValue(Date)

    public static func decode(key: Double) throws -> Date {
      guard key.isFinite else { throw Self.invalidKey(key) }
      return Date(timeIntervalSinceReferenceDate: key)
    }

    public static func encode(value: Date) throws -> Double {
      let key = value.timeIntervalSinceReferenceDate
      guard key.isFinite else { throw Self.invalidValue(value) }
      return key
    }

    public typealias CodecValue = Date
    public typealias CodecKey = Double
  }
}
