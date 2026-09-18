extension Enigma: Encodable {
  /// In fact it never throws for json coders, and for plist if root element is collection
  public func encode(to encoder: Encoder) throws {
    switch self {
    case .null:
      var container = encoder.singleValueContainer()
      try container.encodeNil()
    case .bool(let value): try value.encode(to: encoder)
    case .int(let value): try value.encode(to: encoder)
    case .int64(let value): try value.encode(to: encoder)
    case .int32(let value): try value.encode(to: encoder)
    case .int16(let value): try value.encode(to: encoder)
    case .int8(let value): try value.encode(to: encoder)
    case .uint(let value): try value.encode(to: encoder)
    case .uint64(let value): try value.encode(to: encoder)
    case .uint32(let value): try value.encode(to: encoder)
    case .uint16(let value): try value.encode(to: encoder)
    case .uint8(let value): try value.encode(to: encoder)
    case .double(let value): try value.encode(to: encoder)
    case .float(let value): try value.encode(to: encoder)
    case .string(let value): try value.encode(to: encoder)
    case .array(let value): try value.encode(to: encoder)
    case .dictionary(let value): try value.encode(to: encoder)
    case .data(let value): try value.encode(to: encoder)
    case .date(let value): try value.encode(to: encoder)
    }
  }
}
