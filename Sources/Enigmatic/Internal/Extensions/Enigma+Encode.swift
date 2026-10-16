extension Enigma {
  func encode(unkeyed container: inout some UnkeyedEncodingContainer) throws {
    switch self {
    case .null:
      try container.encodeNil()
    case .bool(let value): try container.encode(value)
    case .int(let value): try container.encode(value)
    case .int64(let value): try container.encode(value)
    case .int32(let value): try container.encode(value)
    case .int16(let value): try container.encode(value)
    case .int8(let value): try container.encode(value)
    case .uint(let value): try container.encode(value)
    case .uint64(let value): try container.encode(value)
    case .uint32(let value): try container.encode(value)
    case .uint16(let value): try container.encode(value)
    case .uint8(let value): try container.encode(value)
    case .double(let value): try container.encode(value)
    case .string(let value): try container.encode(value)
    case .array(let array):
      var container = container.nestedUnkeyedContainer()
      for value in array {
        try value.encode(unkeyed: &container)
      }
    case .dictionary(let dictionary):
      var container = container.nestedContainer(keyedBy: Pin.self)
      for (key, value) in dictionary {
        try value.encode(pin: Pin.str(key), keyed: &container)
      }
    case .data, .date: try container.encode(self)
    case .int128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        try container.encode(value.value)
      } else {
        throw EncodingError.invalidValue(value, EncodingError.Context(
          codingPath: container.codingPath,
          debugDescription: "Int128 not available"
        ))
      }
    case .uint128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        try container.encode(value.value)
      } else {
        throw EncodingError.invalidValue(value, EncodingError.Context(
          codingPath: container.codingPath,
          debugDescription: "UInt128 not available"
        ))
      }
    }
  }

  func encode(pin: consuming Pin, keyed container: inout KeyedEncodingContainer<Pin>) throws {
    switch self {
    case .null: try container.encodeNil(forKey: pin)
    case .bool(let value): try container.encode(value, forKey: pin)
    case .int(let value): try container.encode(value, forKey: pin)
    case .int64(let value): try container.encode(value, forKey: pin)
    case .int32(let value): try container.encode(value, forKey: pin)
    case .int16(let value): try container.encode(value, forKey: pin)
    case .int8(let value): try container.encode(value, forKey: pin)
    case .uint(let value): try container.encode(value, forKey: pin)
    case .uint64(let value): try container.encode(value, forKey: pin)
    case .uint32(let value): try container.encode(value, forKey: pin)
    case .uint16(let value): try container.encode(value, forKey: pin)
    case .uint8(let value): try container.encode(value, forKey: pin)
    case .double(let value): try container.encode(value, forKey: pin)
    case .string(let value): try container.encode(value, forKey: pin)
    case .array(let array):
      var container = container.nestedUnkeyedContainer(forKey: pin)
      for value in array {
        try value.encode(unkeyed: &container)
      }
    case .dictionary(let dictionary):
      var container = container.nestedContainer(keyedBy: Pin.self, forKey: pin)
      for (key, value) in dictionary {
        try value.encode(pin: Pin.str(key), keyed: &container)
      }
    case .data, .date: try container.encode(self, forKey: pin)
    case .int128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        try container.encode(value.value, forKey: pin)
      } else {
        throw EncodingError.invalidValue(value, EncodingError.Context(
          codingPath: container.codingPath,
          debugDescription: "Int128 not available"
        ))
      }
    case .uint128(let value):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        try container.encode(value.value, forKey: pin)
      } else {
        throw EncodingError.invalidValue(value, EncodingError.Context(
          codingPath: container.codingPath,
          debugDescription: "UInt128 not available"
        ))
      }
    }
  }
}
