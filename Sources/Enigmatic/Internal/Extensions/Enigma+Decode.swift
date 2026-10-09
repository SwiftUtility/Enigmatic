import Foundation

extension Enigma {
  @inline(__always)
  static func decode(
    single container: borrowing some SingleValueDecodingContainer
  ) throws -> Self {
    if container.decodeNil() {
      return .null
    } else if let value = try? container.decode(Bool.self) {
      return .bool(value)
    } else if let value = try? container.decode(UInt.self) {
      return .uint(value)
    } else if let value = try? container.decode(Int.self) {
      return .int(value)
    } else if let value = try? container.decode(Double.self) {
      return .double(value)
    } else if let value = try? container.decode(String.self) {
      return .string(value)
    } else if let value = try? container.decode(Data.self) {
      return .data(value)
    } else if let value = try? container.decode(Date.self) {
      return .date(value)
    } else if let value = try? container.decode(Float.self) {
      return .double(Double(value))
    } else if let value = try? container.decode(UInt8.self) {
      return .uint8(value)
    } else if let value = try? container.decode(Int8.self) {
      return .int8(value)
    } else if let value = try? container.decode(UInt16.self) {
      return .uint16(value)
    } else if let value = try? container.decode(Int16.self) {
      return .int16(value)
    } else if let value = try? container.decode(UInt32.self) {
      return .uint32(value)
    } else if let value = try? container.decode(Int32.self) {
      return .int32(value)
    } else if let value = try? container.decode(UInt64.self) {
      return .uint64(value)
    } else if let value = try? container.decode(Int64.self) {
      return .int64(value)
    } else if
      #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *),
      let value = try? container.decode(Int128.self)
    {
      return .int128(Int128Box(value))
    } else if
      #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *),
      let value = try? container.decode(UInt128.self)
    {
      return .uint128(UInt128Box(value))
    } else {
      throw DecodingError.typeMismatch(Self.self, DecodingError.Context(
        codingPath: container.codingPath,
        debugDescription: "Neither value nor array nor dictionary"
      ))
    }
  }

  static func decode(
    keyed container: inout KeyedDecodingContainer<Pin>
  ) throws -> Self {
    let keys = container.allKeys

    var result: [String: Self] = [:]
    result.reserveCapacity(keys.count)

    for key in keys {
      if var container = try? container.nestedContainer(keyedBy: Pin.self, forKey: key) {
        result[key.stringValue] = try Self.decode(keyed: &container)
      } else if var container = try? container.nestedUnkeyedContainer(forKey: key) {
        result[key.stringValue] = try Self.decode(unkeyed: &container)
      } else if case true = try? container.decodeNil(forKey: key) {
        result[key.stringValue] = .null
      } else if let value = try? container.decode(Bool.self, forKey: key) {
        result[key.stringValue] = .bool(value)
      } else if let value = try? container.decode(UInt.self, forKey: key) {
        result[key.stringValue] = .uint(value)
      } else if let value = try? container.decode(Int.self, forKey: key) {
        result[key.stringValue] = .int(value)
      } else if let value = try? container.decode(Double.self, forKey: key) {
        result[key.stringValue] = .double(value)
      } else if let value = try? container.decode(String.self, forKey: key) {
        result[key.stringValue] = .string(value)
      } else if let value = try? container.decode(Data.self, forKey: key) {
        result[key.stringValue] = .data(value)
      } else if let value = try? container.decode(Date.self, forKey: key) {
        result[key.stringValue] = .date(value)
      } else if let value = try? container.decode(Float.self, forKey: key) {
        result[key.stringValue] = .double(Double(value))
      } else if let value = try? container.decode(UInt8.self, forKey: key) {
        result[key.stringValue] = .uint8(value)
      } else if let value = try? container.decode(Int8.self, forKey: key) {
        result[key.stringValue] = .int8(value)
      } else if let value = try? container.decode(UInt16.self, forKey: key) {
        result[key.stringValue] = .uint16(value)
      } else if let value = try? container.decode(Int16.self, forKey: key) {
        result[key.stringValue] = .int16(value)
      } else if let value = try? container.decode(UInt32.self, forKey: key) {
        result[key.stringValue] = .uint32(value)
      } else if let value = try? container.decode(Int32.self, forKey: key) {
        result[key.stringValue] = .int32(value)
      } else if let value = try? container.decode(UInt64.self, forKey: key) {
        result[key.stringValue] = .uint64(value)
      } else if let value = try? container.decode(Int64.self, forKey: key) {
        result[key.stringValue] = .int64(value)
      } else if
        #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *),
        let value = try? container.decode(Int128.self, forKey: key)
      {
        result[key.stringValue] = .int128(Int128Box(value))
      } else if
        #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *),
        let value = try? container.decode(UInt128.self, forKey: key)
      {
        result[key.stringValue] = .uint128(UInt128Box(value))
      } else {
        throw DecodingError.typeMismatch(Self.self, DecodingError.Context(
          codingPath: container.codingPath,
          debugDescription: "Neither value nor array nor dictionary"
        ))
      }
    }
    return .dictionary(result)
  }

  static func decode(
    unkeyed container: inout some UnkeyedDecodingContainer
  ) throws -> Self {
    var result: [Self] = []

    if let count = container.count {
      result.reserveCapacity(count)
    }

    while !container.isAtEnd {
      if var container = try? container.nestedContainer(keyedBy: Pin.self) {
        try result.append(Self.decode(keyed: &container))
      } else if var container = try? container.nestedUnkeyedContainer() {
        try result.append(Self.decode(unkeyed: &container))
      } else if case true = try? container.decodeNil() {
        result.append(.null)
      } else if let value = try? container.decode(Bool.self) {
        result.append(.bool(value))
      } else if let value = try? container.decode(UInt.self) {
        result.append(.uint(value))
      } else if let value = try? container.decode(Int.self) {
        result.append(.int(value))
      } else if let value = try? container.decode(Double.self) {
        result.append(.double(value))
      } else if let value = try? container.decode(String.self) {
        result.append(.string(value))
      } else if let value = try? container.decode(Data.self) {
        result.append(.data(value))
      } else if let value = try? container.decode(Date.self) {
        result.append(.date(value))
      } else if let value = try? container.decode(Float.self) {
        result.append(.double(Double(value)))
      } else if let value = try? container.decode(UInt8.self) {
        result.append(.uint8(value))
      } else if let value = try? container.decode(Int8.self) {
        result.append(.int8(value))
      } else if let value = try? container.decode(UInt16.self) {
        result.append(.uint16(value))
      } else if let value = try? container.decode(Int16.self) {
        result.append(.int16(value))
      } else if let value = try? container.decode(UInt32.self) {
        result.append(.uint32(value))
      } else if let value = try? container.decode(Int32.self) {
        result.append(.int32(value))
      } else if let value = try? container.decode(UInt64.self) {
        result.append(.uint64(value))
      } else if let value = try? container.decode(Int64.self) {
        result.append(.int64(value))
      } else if
        #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *),
        let value = try? container.decode(Int128.self)
      {
        result.append(.int128(Int128Box(value)))
      } else if
        #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *),
        let value = try? container.decode(UInt128.self)
      {
        result.append(.uint128(UInt128Box(value)))
      } else {
        throw DecodingError.typeMismatch(Self.self, DecodingError.Context(
          codingPath: container.codingPath,
          debugDescription: "Neither value nor array nor dictionary"
        ))
      }
    }
    return .array(result)
  }

  func decodingError(_ path: [any CodingKey], type: Any.Type) -> DecodingError {
    var description = "Found null"
    var isNil = false
    switch self {
    case .null: isNil = true
    case .bool: description = "Found Bool"
    case .int: description = "Found Int"
    case .int64: description = "Found Int64"
    case .int32: description = "Found Int32"
    case .int16: description = "Found Int16"
    case .int8: description = "Found Int8"
    case .uint: description = "Found UInt"
    case .uint64: description = "Found UInt64"
    case .uint32: description = "Found UInt32"
    case .uint16: description = "Found UInt16"
    case .uint8: description = "Found UInt8"
    case .double: description = "Found Double"
    case .string: description = "Found String"
    case .date: description = "Found Date"
    case .data: description = "Found Data"
    case .array: description = "Found [Any]"
    case .dictionary: description = "Found [String: Any]"
    case .int128: description = "Found Int128"
    case .uint128: description = "Found UInt128"
    }
    if isNil {
      return DecodingError.valueNotFound(type, DecodingError.Context(
        codingPath: path,
        debugDescription: description
      ))
    } else {
      return DecodingError.typeMismatch(type, DecodingError.Context(
        codingPath: path,
        debugDescription: description
      ))
    }
  }
}
