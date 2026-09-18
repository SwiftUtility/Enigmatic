import Foundation

extension Enigma {
  @available(anyAppleOS 26, *)
  public enum UnixIntDate<let scale: Int>: DecodeStrategy, EncodeStrategy, Error {
    case keyScaledToInfinity(Int)
    case invalidValue(Date)
    case outOfIntScaledValue(Date)

    public static func decode(key: Int) throws -> Date {
      let double = Double(key) / pow(10.0, Double(Self.scale))
      guard double.isFinite else { throw Self.keyScaledToInfinity(key) }
      return Date(timeIntervalSince1970: double)
    }

    public static func encode(value: Date) throws -> Int {
      var key = value.timeIntervalSince1970
      guard key.isFinite else { throw Self.invalidValue(value) }
      key *= pow(10.0, Double(Self.scale))
      guard key < Double(Int.max), key > Double(Int.min) else { throw Self.outOfIntScaledValue(value) }
      return Int(key)
    }

    public typealias CodecValue = Date
    public typealias CodecKey = Int
  }

  @available(anyAppleOS, deprecated: 26.0)
  public enum UnixIntSecondsDate: DecodeStrategy, EncodeStrategy, Error {
    case invalidValue(Date)
    case outOfIntValue(Date)

    public static func decode(key: Int) throws -> Date {
      Date(timeIntervalSince1970: Double(key))
    }

    public static func encode(value: Date) throws -> Int {
      let key = value.timeIntervalSince1970
      guard key.isFinite else { throw Self.invalidValue(value) }
      guard key < Double(Int.max), key > Double(Int.min) else { throw Self.outOfIntValue(value) }
      return Int(key)
    }

    public typealias CodecValue = Date
    public typealias CodecKey = Int
  }

  @available(anyAppleOS, deprecated: 26.0)
  public enum UnixIntMillisecondsDate: DecodeStrategy, EncodeStrategy, Error {
    case invalidValue(Date)
    case outOfIntScaledValue(Date)

    public static func decode(key: Int) throws -> Date {
      Date(timeIntervalSince1970: Double(key) / 1000)
    }

    public static func encode(value: Date) throws -> Int {
      var key = value.timeIntervalSince1970
      guard key.isFinite else { throw Self.invalidValue(value) }
      key *= 1000
      guard key < Double(Int.max), key > Double(Int.min) else { throw Self.outOfIntScaledValue(value) }
      return Int(key)
    }

    public typealias CodecValue = Date
    public typealias CodecKey = Int
  }
}
