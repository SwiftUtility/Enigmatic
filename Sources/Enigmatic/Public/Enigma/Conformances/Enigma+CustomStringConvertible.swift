extension Enigma: CustomStringConvertible {
  /// A human-readable description. This is not a JSON serialization.
  public var description: String {
    switch self {
    case .null: "null"
    case .bool(let value): String(describing: value)
    case .int(let value): String(describing: value)
    case .int64(let value): String(describing: value)
    case .int32(let value): String(describing: value)
    case .int16(let value): String(describing: value)
    case .int8(let value): String(describing: value)
    case .uint(let value): String(describing: value)
    case .uint64(let value): String(describing: value)
    case .uint32(let value): String(describing: value)
    case .uint16(let value): String(describing: value)
    case .uint8(let value): String(describing: value)
    case .double(let value): String(describing: value)
    case .float(let value): String(describing: value)
    case .string(let value): String(describing: value)
    case .date(let value): String(describing: value)
    case .data(let value): String(describing: value)
    case .array(let value): String(describing: value)
    case .dictionary(let value): String(describing: value)
    case .int128(let value): String(describing: value)
    case .uint128(let value): String(describing: value)
    }
  }
}
