import Foundation

extension Enigma: Decodable {
  public init(from decoder: Decoder) throws {
    if let container = try? decoder.container(keyedBy: Pin.self) {
      self = .dictionary(try Self.decodeDictionary(from: container))
    } else if var container = try? decoder.unkeyedContainer() {
      self = .array(try Self.decodeArray(from: &container))
    } else {
      let container = try decoder.singleValueContainer()
      if container.decodeNil() {
        self = .null
      } else if let value = try? container.decode(Bool.self) {
        self = .bool(value)
      } else if let value = try? container.decode(UInt.self) {
        self = Self.downscale(value)
      } else if let value = try? container.decode(Int.self) {
        self = Self.downscale(value)
      } else if let value = try? container.decode(Double.self) {
        self = Self.downscale(value)
      } else if let value = try? container.decode(String.self) {
        self = .string(value)
      } else if let value = try? container.decode(Data.self) {
        self = .data(value)
      } else if let value = try? container.decode(Date.self) {
        self = .date(value)
      } else if let value = try? container.decode(Float.self) {
        self = .float(value)
      } else if let value = try? container.decode(UInt8.self) {
        self = .uint8(value)
      } else if let value = try? container.decode(Int8.self) {
        self = .int8(value)
      } else if let value = try? container.decode(UInt16.self) {
        self = .uint16(value)
      } else if let value = try? container.decode(Int16.self) {
        self = .int16(value)
      } else if let value = try? container.decode(UInt32.self) {
        self = .uint32(value)
      } else if let value = try? container.decode(Int32.self) {
        self = .int32(value)
      } else if let value = try? container.decode(UInt64.self) {
        self = .uint64(value)
      } else if let value = try? container.decode(Int64.self) {
        self = .int64(value)
      } else {
        throw DecodingError.typeMismatch(Self.self, DecodingError.Context(
          codingPath: container.codingPath,
          debugDescription: "Neither value nor array nor dictionary"
        ))
      }
    }
  }
}

private extension Enigma {
  static func decodeDictionary(
    from container: KeyedDecodingContainer<Pin>
  ) throws -> [String: Self] {
    let keys = container.allKeys

    var result: [String: Self] = [:]
    result.reserveCapacity(keys.count)

    for key in keys {
      result[key.stringValue] = try container.decode(Self.self, forKey: key)
    }

    return result
  }

  static func decodeArray(
    from container: inout UnkeyedDecodingContainer
  ) throws -> [Self] {
    var result: [Self] = []

    if let count = container.count {
      result.reserveCapacity(count)
    }

    while !container.isAtEnd {
      result.append(try container.decode(Self.self))
    }

    return result
  }

  @inline(__always)
  static func downscale(_ value: UInt) -> Self {
    if let value = UInt8(exactly: value) {
      .uint8(value)
    } else if let value = UInt16(exactly: value) {
      .uint16(value)
    } else if let value = UInt32(exactly: value) {
      .uint32(value)
    } else {
      .uint(value)
    }
  }

  @inline(__always)
  static func downscale(_ value: Int) -> Self {
    if let value = Int8(exactly: value) {
      .int8(value)
    } else if let value = Int16(exactly: value) {
      .int16(value)
    } else if let value = Int32(exactly: value) {
      .int32(value)
    } else {
      .int(value)
    }
  }

  @inline(__always)
  static func downscale(_ value: Double) -> Self {
    if let value = Float(exactly: value) {
      .float(value)
    } else {
      .double(value)
    }
  }
}
