import Foundation

/// Container type to allow partial or multi step encoding and decoding operations
public enum Enigma: Sendable {
  case null
  case bool(Bool)
  case int(Int)
  case int64(Int64)
  case int32(Int32)
  case int16(Int16)
  case int8(Int8)
  case uint(UInt)
  case uint64(UInt64)
  case uint32(UInt32)
  case uint16(UInt16)
  case uint8(UInt8)
  case double(Double)
  case float(Float)
  case string(String)
  case array([Self])
  case dictionary([String: Self])
  case data(Data)
  case date(Date)

  /// Create Enigma tree from AnyObject
  ///
  /// - Note: It is usable with JSONSerialization or PropertyListSerialization and [Yams](https://github.com/jpsim/Yams) parser load function output
  public init(cast any: Any?) throws {
    self = try Reducer.reduce(seed: [], any, Self.make(anyObject:))
  }

  /// Create Enigma tree by encoding Encodable instance
  public init(encode value: any Encodable, userInfo: [CodingUserInfoKey: Any] = [:]) throws {
//    self = try value as? Enigma ?? OtherEnigmaEncoder.State.encode(value: value, userInfo: userInfo)
    self = try value as? Enigma ?? EnigmaEncoder.State.encode(value: value, userInfo: userInfo)
}

  /// Get set, or remove value if it is present.
  public subscript(_ pins: Pin...) -> Self? {
    get { self[pins] }
    set { self[pins] = newValue }
  }

  public subscript(_ pins: Pin..., or fallback: @autoclosure () -> Self) -> Self {
    get { self[pins, or: fallback()] }
    set { self[pins, or: fallback()] = newValue }
  }

  /// Get, set or remove value at pins path if it is present. Does not remove root object
  public subscript(_ pins: [Pin]) -> Self? {
    get { getValue(pins: pins) }
    set {
      var pins = ArraySlice(pins)
      if let newValue {
        setValue(newValue, pins: &pins)
      } else {
        delValue(pins: &pins)
      }
    }
  }

  /// Get or set value at pins path if it is present.
  public subscript(_ pins: [Pin], or fallback: @autoclosure () -> Self) -> Self {
    get { getValue(pins: pins) ?? fallback() }
    set {
      var pins = ArraySlice(pins)
      setValue(newValue, pins: &pins)
    }
  }

  /// Attempt to decode value
  public func decode<T: Decodable>(_: T.Type = T.self, userInfo: [CodingUserInfoKey: Any] = [:]) throws -> T {
//      try T(from: ValueDecoder(value: self, path: nil))
//    try T(from: EnigmaDecoder.State.decoder(enigma: self, userInfo: userInfo))
    try T(from: EnigmaDecoderClass.Single.decoder(enigma: self, userInfo: userInfo))
  }
}
