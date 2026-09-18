import Foundation

extension Enigma: Equatable {
  /// Equality check
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch lhs {
    case .null: rhs.isNull
    case .bool(let lhs): lhs == rhs.asBool
    case .int(let lhs): lhs == rhs.asInt
    case .int64(let lhs): lhs == rhs.asInt64
    case .int32(let lhs): lhs == rhs.asInt32
    case .int16(let lhs): lhs == rhs.asInt16
    case .int8(let lhs): lhs == rhs.asInt8
    case .uint(let lhs): lhs == rhs.asUInt
    case .uint64(let lhs): lhs == rhs.asUInt64
    case .uint32(let lhs): lhs == rhs.asUInt32
    case .uint16(let lhs): lhs == rhs.asUInt16
    case .uint8(let lhs): lhs == rhs.asUInt8
    case .double(let lhs):
      if case .float(let rhs) = rhs { rhs.isSame(double: lhs) } else { lhs.isSame(double: rhs.asDouble) }
    case .float(let lhs):
        if case .double(let rhs) = rhs { lhs.isSame(double: rhs) } else { lhs.isSame(float: rhs.asFloat) }
    case .string(let lhs): lhs == rhs.asString
    case .date(let lhs): lhs == rhs.asDate
    case .data(let lhs): lhs == rhs.asData
    case .array(let lhs): lhs == rhs.asArray
    case .dictionary(let lhs): lhs == rhs.asDictionary
    }
  }
}
