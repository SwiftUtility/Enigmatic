import Foundation

extension Enigma {
  /// Create Enigma tree from AnyObject
  ///
  /// - Note: It is usable with JSONSerialization and [Yams](https://github.com/jpsim/Yams) parser load function output
  public init(parse any: Any?) throws {
    try self.init(any: any, path: [])
  }

  /// Create Enigma tree by encoding Encodable instance
  public init<T: Encodable>(encode value: T) throws {
    let context = EncoderContext()
    try value.encode(to: context.makeValue(path: []))
    guard let enigma = context.enigma else {
      throw EncodingError.invalidValue(value, EncodingError.Context(
        codingPath: [],
        debugDescription: "encoded to nothing"
      ))
    }
    self = enigma
  }

  /// Convert Enigma to AnyObject
  ///
  /// - Note: It is usable with JSONSerialization
  ///   and [Stencil](https://github.com/stencilproject/Stencil/tree/master) render
  public var asAnyObject: AnyObject {
    switch self {
    case .null: return NSNull()
    case .bool(let value): return value as NSNumber
    case .int(let value): return value as NSNumber
    case .int64(let value): return value as NSNumber
    case .int32(let value): return value as NSNumber
    case .int16(let value): return value as NSNumber
    case .int8(let value): return value as NSNumber
    case .uint(let value): return value as NSNumber
    case .uint64(let value): return value as NSNumber
    case .uint32(let value): return value as NSNumber
    case .uint16(let value): return value as NSNumber
    case .uint8(let value): return value as NSNumber
    case .double(let value): return value as NSNumber
    case .float(let value): return value as NSNumber
    case .string(let value): return value as NSString
    case .array(let array): return array.map(\.asAnyObject) as NSArray
    case .dictionary(let dictionary): return dictionary.mapValues(\.asAnyObject) as NSDictionary
    case .data(let data): return data as NSData
    case .date(let date): return date as NSDate
    }
  }

  /// Test if root value is null
  public var isNull: Bool {
    if case .null = self { return true } else { return false }
  }

  /// Get value if it is Bool
  public var asBool: Bool? {
    if case .bool(let value) = self { return value } else { return nil }
  }

  /// Get value if it is representable as Int
  public var asInt: Int? {
    switch self {
    case .int(let value): return value
    case .int64(let value): return Int(exactly: value)
    case .int32(let value): return Int(exactly: value)
    case .int16(let value): return Int(exactly: value)
    case .int8(let value): return Int(exactly: value)
    case .uint(let value): return Int(exactly: value)
    case .uint64(let value): return Int(exactly: value)
    case .uint32(let value): return Int(exactly: value)
    case .uint16(let value): return Int(exactly: value)
    case .uint8(let value): return Int(exactly: value)
    case .double(let value): return Int(exactly: value)
    case .float(let value): return Int(exactly: value)
    case .date(let value): return Int(exactly: value.timeIntervalSinceReferenceDate)
    default: return nil
    }
  }

  /// Get value if it is representable as Int64
  public var asInt64: Int64? {
    switch self {
    case .int(let value): return Int64(exactly: value)
    case .int64(let value): return value
    case .int32(let value): return Int64(exactly: value)
    case .int16(let value): return Int64(exactly: value)
    case .int8(let value): return Int64(exactly: value)
    case .uint(let value): return Int64(exactly: value)
    case .uint64(let value): return Int64(exactly: value)
    case .uint32(let value): return Int64(exactly: value)
    case .uint16(let value): return Int64(exactly: value)
    case .uint8(let value): return Int64(exactly: value)
    case .double(let value): return Int64(exactly: value)
    case .float(let value): return Int64(exactly: value)
    case .date(let value): return Int64(exactly: value.timeIntervalSinceReferenceDate)
    default: return nil
    }
  }

  /// Get value if it is representable as Int32
  public var asInt32: Int32? {
    switch self {
    case .int(let value): return Int32(exactly: value)
    case .int64(let value): return Int32(exactly: value)
    case .int32(let value): return value
    case .int16(let value): return Int32(exactly: value)
    case .int8(let value): return Int32(exactly: value)
    case .uint(let value): return Int32(exactly: value)
    case .uint64(let value): return Int32(exactly: value)
    case .uint32(let value): return Int32(exactly: value)
    case .uint16(let value): return Int32(exactly: value)
    case .uint8(let value): return Int32(exactly: value)
    case .double(let value): return Int32(exactly: value)
    case .float(let value): return Int32(exactly: value)
    case .date(let value): return Int32(exactly: value.timeIntervalSinceReferenceDate)
    default: return nil
    }
  }

  /// Get value if it is representable as Int16
  public var asInt16: Int16? {
    switch self {
    case .int(let value): return Int16(exactly: value)
    case .int64(let value): return Int16(exactly: value)
    case .int32(let value): return Int16(exactly: value)
    case .int16(let value): return value
    case .int8(let value): return Int16(exactly: value)
    case .uint(let value): return Int16(exactly: value)
    case .uint64(let value): return Int16(exactly: value)
    case .uint32(let value): return Int16(exactly: value)
    case .uint16(let value): return Int16(exactly: value)
    case .uint8(let value): return Int16(exactly: value)
    case .double(let value): return Int16(exactly: value)
    case .float(let value): return Int16(exactly: value)
    case .date(let value): return Int16(exactly: value.timeIntervalSinceReferenceDate)
    default: return nil
    }
  }

  /// Get value if it is representable as Int8
  public var asInt8: Int8? {
    switch self {
    case .int(let value): return Int8(exactly: value)
    case .int64(let value): return Int8(exactly: value)
    case .int32(let value): return Int8(exactly: value)
    case .int16(let value): return Int8(exactly: value)
    case .int8(let value): return value
    case .uint(let value): return Int8(exactly: value)
    case .uint64(let value): return Int8(exactly: value)
    case .uint32(let value): return Int8(exactly: value)
    case .uint16(let value): return Int8(exactly: value)
    case .uint8(let value): return Int8(exactly: value)
    case .double(let value): return Int8(exactly: value)
    case .float(let value): return Int8(exactly: value)
    case .date(let value): return Int8(exactly: value.timeIntervalSinceReferenceDate)
    default: return nil
    }
  }

  /// Get value if it is representable as UInt
  public var asUInt: UInt? {
    switch self {
    case .int(let value): return UInt(exactly: value)
    case .int64(let value): return UInt(exactly: value)
    case .int32(let value): return UInt(exactly: value)
    case .int16(let value): return UInt(exactly: value)
    case .int8(let value): return UInt(exactly: value)
    case .uint(let value): return value
    case .uint64(let value): return UInt(exactly: value)
    case .uint32(let value): return UInt(exactly: value)
    case .uint16(let value): return UInt(exactly: value)
    case .uint8(let value): return UInt(exactly: value)
    case .double(let value): return UInt(exactly: value)
    case .float(let value): return UInt(exactly: value)
    case .date(let value): return UInt(exactly: value.timeIntervalSinceReferenceDate)
    default: return nil
    }
  }

  /// Get value if it is representable as UInt64
  public var asUInt64: UInt64? {
    switch self {
    case .int(let value): return UInt64(exactly: value)
    case .int64(let value): return UInt64(exactly: value)
    case .int32(let value): return UInt64(exactly: value)
    case .int16(let value): return UInt64(exactly: value)
    case .int8(let value): return UInt64(exactly: value)
    case .uint(let value): return UInt64(exactly: value)
    case .uint64(let value): return value
    case .uint32(let value): return UInt64(exactly: value)
    case .uint16(let value): return UInt64(exactly: value)
    case .uint8(let value): return UInt64(exactly: value)
    case .double(let value): return UInt64(exactly: value)
    case .float(let value): return UInt64(exactly: value)
    case .date(let value): return UInt64(exactly: value.timeIntervalSinceReferenceDate)
    default: return nil
    }
  }

  /// Get value if it is representable as UInt32
  public var asUInt32: UInt32? {
    switch self {
    case .int(let value): return UInt32(exactly: value)
    case .int64(let value): return UInt32(exactly: value)
    case .int32(let value): return UInt32(exactly: value)
    case .int16(let value): return UInt32(exactly: value)
    case .int8(let value): return UInt32(exactly: value)
    case .uint(let value): return UInt32(exactly: value)
    case .uint64(let value): return UInt32(exactly: value)
    case .uint32(let value): return value
    case .uint16(let value): return UInt32(exactly: value)
    case .uint8(let value): return UInt32(exactly: value)
    case .double(let value): return UInt32(exactly: value)
    case .float(let value): return UInt32(exactly: value)
    case .date(let value): return UInt32(exactly: value.timeIntervalSinceReferenceDate)
    default: return nil
    }
  }

  /// Get value if it is representable as UInt16
  public var asUInt16: UInt16? {
    switch self {
    case .int(let value): return UInt16(exactly: value)
    case .int64(let value): return UInt16(exactly: value)
    case .int32(let value): return UInt16(exactly: value)
    case .int16(let value): return UInt16(exactly: value)
    case .int8(let value): return UInt16(exactly: value)
    case .uint(let value): return UInt16(exactly: value)
    case .uint64(let value): return UInt16(exactly: value)
    case .uint32(let value): return UInt16(exactly: value)
    case .uint16(let value): return value
    case .uint8(let value): return UInt16(exactly: value)
    case .double(let value): return UInt16(exactly: value)
    case .float(let value): return UInt16(exactly: value)
    case .date(let value): return UInt16(exactly: value.timeIntervalSinceReferenceDate)
    default: return nil
    }
  }

  /// Get value if it is representable as UInt8
  public var asUInt8: UInt8? {
    switch self {
    case .int(let value): return UInt8(exactly: value)
    case .int64(let value): return UInt8(exactly: value)
    case .int32(let value): return UInt8(exactly: value)
    case .int16(let value): return UInt8(exactly: value)
    case .int8(let value): return UInt8(exactly: value)
    case .uint(let value): return UInt8(exactly: value)
    case .uint64(let value): return UInt8(exactly: value)
    case .uint32(let value): return UInt8(exactly: value)
    case .uint16(let value): return UInt8(exactly: value)
    case .uint8(let value): return value
    case .double(let value): return UInt8(exactly: value)
    case .float(let value): return UInt8(exactly: value)
    case .date(let value): return UInt8(exactly: value.timeIntervalSinceReferenceDate)
    default: return nil
    }
  }

  /// Get value if it is representable as Float
  public var asFloat: Float? {
    switch self {
    case .int(let value): return Float(value)
    case .int64(let value): return Float(value)
    case .int32(let value): return Float(value)
    case .int16(let value): return Float(value)
    case .int8(let value): return Float(value)
    case .uint(let value): return Float(value)
    case .uint64(let value): return Float(value)
    case .uint32(let value): return Float(value)
    case .uint16(let value): return Float(value)
    case .uint8(let value): return Float(value)
    case .double(let value):
        let result = Float(value)
        return if result.isFinite || !value.isFinite { result } else { nil }
    case .float(let value): return value
    case .date(let value): return Float(value.timeIntervalSinceReferenceDate)
    default: return nil
    }
  }

  /// Get value if it is representable as Double
  public var asDouble: Double? {
    switch self {
    case .int(let value): return Double(value)
    case .int64(let value): return Double(value)
    case .int32(let value): return Double(value)
    case .int16(let value): return Double(value)
    case .int8(let value): return Double(value)
    case .uint(let value): return Double(value)
    case .uint64(let value): return Double(value)
    case .uint32(let value): return Double(value)
    case .uint16(let value): return Double(value)
    case .uint8(let value): return Double(value)
    case .double(let value): return value
    case .float(let value): return Double(value)
    case .date(let value): return value.timeIntervalSinceReferenceDate
    default: return nil
    }
  }

  /// Get value if it is representable as String
  public var asString: String? {
    if case .string(let value) = self { return value } else { return nil }
  }

  /// Get value if it is exactly Data
  public var asData: Data? {
    if case .data(let value) = self { return value } else { return nil }
  }

  /// Get value if it is exactly Date
  public var asDate: Date? {
    switch self {
    case .int(let value): return Date(timeIntervalSinceReferenceDate: Double(value))
    case .int64(let value): return Date(timeIntervalSinceReferenceDate: Double(value))
    case .int32(let value): return Date(timeIntervalSinceReferenceDate: Double(value))
    case .int16(let value): return Date(timeIntervalSinceReferenceDate: Double(value))
    case .int8(let value): return Date(timeIntervalSinceReferenceDate: Double(value))
    case .uint(let value): return Date(timeIntervalSinceReferenceDate: Double(value))
    case .uint64(let value): return Date(timeIntervalSinceReferenceDate: Double(value))
    case .uint32(let value): return Date(timeIntervalSinceReferenceDate: Double(value))
    case .uint16(let value): return Date(timeIntervalSinceReferenceDate: Double(value))
    case .uint8(let value): return Date(timeIntervalSinceReferenceDate: Double(value))
    case .double(let value): return Date(timeIntervalSinceReferenceDate: value)
    case .float(let value): return Date(timeIntervalSinceReferenceDate: Double(value))
    case .date(let value): return value
    default: return nil
    }
  }

  /// Get value if it is Array, emply Dictionary or Data
  public var asArray: [Self]? {
    switch self {
    case .array(let value): return value
    case .dictionary([:]): return []
    case .data(let data): return data.map(Enigma.uint8(_:))
    default: return nil
    }
  }

  /// Get value if it is Dictionary
  public var asDictionary: [String: Self]? {
    if case .dictionary(let value) = self { return value } else { return nil }
  }

  /// Get value if it is Array, emply Dictionary or Data, empty array otherwise
  public var array: [Self] {
    get { asArray ?? [] }
    set { self = .array(newValue) }
  }

  /// Get value if it is Dictionary, empty dictionary otherwise
  public var dictionary: [String: Self] {
    get { asDictionary ?? [:] }
    set { self = .dictionary(newValue) }
  }

  /// Get or set value if it is present, index is correct and root element is Array
  public subscript(_ index: Int) -> Self? {
    get {
      guard let array = asArray, index < array.count else { return nil }
      return array[index]
    }
    set {
      guard let newValue = newValue, var array = asArray, index < array.count
      else { return }
      array[index] = newValue
      self = .array(array)
    }
  }

  /// Get, add or overwrite value
  public subscript(_ index: Int, or defaultValue: Self) -> Self {
    get {
      guard let array = asArray, index < array.count else { return defaultValue }
      return array[index]
    }
    set {
      var array: [Self]
      if let value = asArray { array = value } else { array = [] }
      while index > array.count { array.append(defaultValue) }
      if index < array.count { array[index] = newValue } else { array.append(newValue) }
      self = .array(array)
    }
  }

  /// Get, add, overwrite or delete value
  public subscript(_ key: String) -> Self? {
    get {
      guard case .dictionary(let value) = self else { return nil }
      return value[key]
    }
    set {
      guard case .dictionary(var value) = self else { return }
      value[key] = newValue
      self = .dictionary(value)
    }
  }

  /// Get or add or overwrite value
  public subscript(_ key: String, or defaultValue: Self) -> Self {
    get {
      guard case .dictionary(let value) = self else { return defaultValue }
      return value[key] ?? defaultValue
    }
    set {
      var dictionary: [String: Self]
      if case .dictionary(let value) = self { dictionary = value } else { dictionary = [:] }
      dictionary[key] = newValue
      self = .dictionary(dictionary)
    }
  }

  /// Get or set value if it is encoded/decoded successfully
  public subscript<T: Codable>(_ _: T.Type = T.self) -> T? {
    get { try? makeValue(path: []).decode(T.self) }
    set { if let value = try? newValue.map(Self.init(encode:)) { self = value } }
  }

  /// Get or merge value if it is encoded/decoded successfully
  public subscript<T: Codable>(mask _: T.Type = T.self) -> T? {
    get { try? makeValue(path: []).decode(T.self) }
    set {
      guard let value = try? newValue.map(Self.init(encode:)) else { return }
      if let value = try? merge(value, path: [], overwrite: true) { self = value }
    }
  }

  /// Get decoded or default value, set encoded value or null
  public subscript<T: Codable>(_ _: T.Type = T.self, or defaultValue: T) -> T {
    get {
      do { return try makeValue(path: []).decode(T.self) }
      catch { return defaultValue }
    }
    set {
      do { self = try Self(encode: newValue) }
      catch { self = .null }
    }
  }

  /// Get decoded or default value, merge newValue if encoded successfully
  public subscript<T: Codable>(mask _: T.Type = T.self, or defaultValue: T) -> T {
    get {
      do { return try makeValue(path: []).decode(T.self) }
      catch { return defaultValue }
    }
    set {
      if let value = try? merge(Self(encode: newValue), path: [], overwrite: true) { self = value }
    }
  }

  /// Attempt to decode value
  public func decode<T: Decodable>(_: T.Type = T.self) throws -> T {
    try makeValue(path: []).decode(T.self)
  }

  /// Attempt to merge current and encoded ortagonal value
  public mutating func encode<T: Encodable>(_ value: T) throws {
    self = try merge(Self(encode: value), path: [], overwrite: false)
  }

  /// Attempt to write encoded value overwriting original
  public mutating func merge<T: Encodable>(_ value: T) throws {
    self = try merge(Self(encode: value), path: [], overwrite: true)
  }
}
