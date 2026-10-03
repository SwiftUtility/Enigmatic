extension Enigma: CustomDebugStringConvertible {
  /// A diagnostic representation of the tree; it is not a serialization format.
  public var debugDescription: String {
    switch self {
    case .null: "null"
    case .bool(let value): String(reflecting: value)
    case .int(let value): String(reflecting: value)
    case .int64(let value): String(reflecting: value)
    case .int32(let value): String(reflecting: value)
    case .int16(let value): String(reflecting: value)
    case .int8(let value): String(reflecting: value)
    case .uint(let value): String(reflecting: value)
    case .uint64(let value): String(reflecting: value)
    case .uint32(let value): String(reflecting: value)
    case .uint16(let value): String(reflecting: value)
    case .uint8(let value): String(reflecting: value)
    case .double(let value): String(reflecting: value)
    case .float(let value): String(reflecting: value)
    case .string(let value): String(reflecting: value)
    case .date(let value): String(reflecting: value)
    case .data(let value): String(reflecting: value)
    case .array(let value): String(reflecting: value)
    case .dictionary(let value): String(reflecting: value)
    case .int128(let value): String(reflecting: value)
    case .uint128(let value): String(reflecting: value)
    }
  }
}
