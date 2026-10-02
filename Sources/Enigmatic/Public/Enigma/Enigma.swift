import Foundation

/// A typed value tree for partial encoding, editing, merging, and decoding.
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
  case int128(Int128Value)
  case uint128(UInt128Value)
  /// Create Enigma tree from AnyObject
  ///
  /// - Note: It is usable with JSONSerialization or PropertyListSerialization and [Yams](https://github.com/jpsim/Yams) parser load function output
  public init(cast any: Any?) throws {
    self = try Reducer.reduce(seed: [], any, Self.make(anyObject:))
  }

  /// Encodes a model into a tree, preserving Date and Data at every position.
  public init(encode value: any Encodable, userInfo: [CodingUserInfoKey: Any] = [:]) throws {
    self = try value as? Enigma ?? EnigmaEncoder.encode(value: value, userInfo: userInfo)
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

  /// Reads, replaces, or removes a value at a path.
  ///
  /// Missing dictionary children and array elements at count can be created.
  /// Incompatible parents and invalid indices are no-ops. Nil deletes a child;
  /// `.null` stores a null. An empty path can replace, but cannot delete, the root.
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

  /// Decodes a model from this tree, passing userInfo to nested decoders.
  public func decode<T: Decodable>(_: T.Type = T.self, userInfo: [CodingUserInfoKey: Any] = [:]) throws -> T {
    try EnigmaDecoder.decoder(enigma: self, userInfo: userInfo).decode(T.self)
  }
}
