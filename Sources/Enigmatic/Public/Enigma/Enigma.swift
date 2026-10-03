import Foundation

/// A typed value tree for partial encoding, editing, merging, and decoding.
public enum Enigma: Sendable {
  /// An explicit null value.
  case null
  /// A Boolean value.
  case bool(Bool)
  /// A platform-sized signed integer.
  case int(Int)
  /// A signed 64-bit integer.
  case int64(Int64)
  /// A signed 32-bit integer.
  case int32(Int32)
  /// A signed 16-bit integer.
  case int16(Int16)
  /// A signed 8-bit integer.
  case int8(Int8)
  /// A platform-sized unsigned integer.
  case uint(UInt)
  /// An unsigned 64-bit integer.
  case uint64(UInt64)
  /// An unsigned 32-bit integer.
  case uint32(UInt32)
  /// An unsigned 16-bit integer.
  case uint16(UInt16)
  /// An unsigned 8-bit integer.
  case uint8(UInt8)
  /// A 64-bit floating-point value.
  case double(Double)
  /// A 32-bit floating-point value.
  case float(Float)
  /// A string value.
  case string(String)
  /// An ordered sequence of values.
  case array([Self])
  /// A string-keyed collection of values.
  case dictionary([String: Self])
  /// Binary data retained in its native form.
  case data(Data)
  /// A date retained in its native form.
  case date(Date)
  /// A signed 128-bit integer on supported operating systems.
  case int128(Int128Value)
  /// An unsigned 128-bit integer on supported operating systems.
  case uint128(UInt128Value)
  /// Creates a tree from Foundation-compatible objects or supported Swift values.
  ///
  /// Use values from `JSONSerialization`, `PropertyListSerialization`, or a YAML parser.
  /// - Parameter any: The optional root value to convert.
  /// - Throws: An encoding error when a value cannot be represented by Enigma.
  public init(cast any: Any?) throws {
    self = try Reducer.reduce(seed: [], any, Self.make(anyObject:))
  }

  /// Encodes a model into a tree, preserving Date and Data at every position.
  /// - Parameters:
  ///   - value: The value to encode.
  ///   - userInfo: Context passed to the encoder and nested encoders.
  /// - Throws: An encoding error when the value cannot be represented.
  public init(encode value: any Encodable, userInfo: [CodingUserInfoKey: Any] = [:]) throws {
    self = try value as? Enigma ?? EnigmaEncoder.encode(value: value, userInfo: userInfo)
  }

  /// Gets, sets, or removes a value at a variadic path.
  /// Assigning nil removes a child; assigning `.null` stores an explicit null.
  public subscript(_ pins: Pin...) -> Self? {
    get { self[pins] }
    set { self[pins] = newValue }
  }

  /// Gets or sets a value at a variadic path, using `fallback` when it is absent.
  /// The autoclosure is evaluated only when the path has no value.
  public subscript(_ pins: Pin..., or fallback: @autoclosure () -> Self) -> Self {
    get { self[pins, or: fallback()] }
    set { self[pins, or: fallback()] = newValue }
  }

  /// Reads, replaces, or removes a value at a path.
  ///
  /// Missing dictionary children and array elements at count can be created.
  /// Incompatible parents and invalid indices are no-ops. Nil deletes a child;
  /// `.null` stores a null. An empty path can replace, but cannot delete, the root.
  /// - Parameter pins: The sequence of dictionary keys and array indices.
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

  /// Gets or sets a value at a path, using `fallback` when it is absent.
  /// The autoclosure is evaluated only when the path has no value.
  public subscript(_ pins: [Pin], or fallback: @autoclosure () -> Self) -> Self {
    get { getValue(pins: pins) ?? fallback() }
    set {
      var pins = ArraySlice(pins)
      setValue(newValue, pins: &pins)
    }
  }

  /// Decodes a model from this tree, passing userInfo to nested decoders.
  /// - Parameters:
  ///   - type: The model type to decode; defaults to the inferred type.
  ///   - userInfo: Context passed to the decoder and nested decoders.
  /// - Returns: The decoded model.
  /// - Throws: A decoding error when the tree does not match the requested type.
  public func decode<T: Decodable>(_: T.Type = T.self, userInfo: [CodingUserInfoKey: Any] = [:]) throws -> T {
    try EnigmaDecoder.decoder(enigma: self, userInfo: userInfo).decode(T.self)
  }
}
