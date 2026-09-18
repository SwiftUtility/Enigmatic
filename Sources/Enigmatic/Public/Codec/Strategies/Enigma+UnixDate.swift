import Foundation

extension Enigma {
  @available(anyAppleOS 26, *)
  public enum UnixDate<let scale: Int>: DecodeStrategy, EncodeStrategy, Error {
    case invalidKey(Double)
    case keyScaledToInfinity(Double)
    case invalidValue(Date)
    case valueScaledToInfinity(Date)

    public static func decode(key: Double) throws -> Date {
      guard key.isFinite else { throw Self.invalidKey(key) }
      let key = key / pow(10.0, Double(Self.scale))
      guard key.isFinite else { throw Self.keyScaledToInfinity(key) }
      return Date(timeIntervalSince1970: key)
    }

    public static func encode(value: Date) throws -> Double {
      var key = value.timeIntervalSince1970
      guard key.isFinite else { throw Self.invalidValue(value) }
      key *= pow(10.0, Double(Self.scale))
      guard key.isFinite else { throw Self.valueScaledToInfinity(value) }
      return key
    }

    public typealias CodecValue = Date
    public typealias CodecKey = Double
  }

  @available(anyAppleOS, deprecated: 26.0)
  public enum UnixSecondsDate: DecodeStrategy, EncodeStrategy, Error {
    case invalidKey(Double)
    case invalidValue(Date)

    public static func decode(key: Double) throws -> Date {
      guard key.isFinite else { throw Self.invalidKey(key) }
      return Date(timeIntervalSince1970: key)
    }

    public static func encode(value: Date) throws -> Double {
      let key = value.timeIntervalSince1970
      guard key.isFinite else { throw Self.invalidValue(value) }
      return key
    }

    public typealias CodecValue = Date
    public typealias CodecKey = Double
  }

  @available(anyAppleOS, deprecated: 26.0)
  public enum UnixMillisecondsDate: DecodeStrategy, EncodeStrategy, Error {
    case invalidKey(Double)
    case invalidValue(Date)
    case valueScaledToInfinity(Date)

    public static func decode(key: Double) throws -> Date {
      guard key.isFinite else { throw Self.invalidKey(key) }
      return Date(timeIntervalSince1970: key / 1000)
    }

    public static func encode(value: Date) throws -> Double {
      var key = value.timeIntervalSince1970
      guard key.isFinite else { throw Self.invalidValue(value) }
      key *= 1000
      guard key.isFinite else { throw Self.valueScaledToInfinity(value) }
      return key
    }

    public typealias CodecValue = Date
    public typealias CodecKey = Double
  }
}
