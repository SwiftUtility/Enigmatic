import Foundation

enum JsonEncoder {
  static func encode(_ value: Enigma, path: [Enigma.Pin] = []) throws(EncodingError) -> String {
    guard path.count < 512 else { throw invalid(value, path: path) }
    switch value {
    case .null: return "null"
    case .bool(let value): return value ? "true" : "false"
    case .int(let value): return String(value)
    case .int8(let value): return String(value)
    case .int16(let value): return String(value)
    case .int32(let value): return String(value)
    case .int64(let value): return String(value)
    case .uint(let value): return String(value)
    case .uint8(let value): return String(value)
    case .uint16(let value): return String(value)
    case .uint32(let value): return String(value)
    case .uint64(let value): return String(value)
    case .double(let number):
      guard number.isFinite else { throw invalid(value, path: path) }
      return String(number)
    case .string(let value): return quote(value)
    case .array(let values):
      var items: [String] = []
      for (index, value) in values.enumerated() {
        items.append(try encode(value, path: path + [.int(index)]))
      }
      return "[" + items.joined(separator: ",") + "]"
    case .dictionary(let values):
      var items: [String] = []
      for key in values.keys.sorted() {
        if let value = values[key] {
          items.append(quote(key) + ":" + (try encode(value, path: path + [.str(key)])))
        }
      }
      return "{" + items.joined(separator: ",") + "}"
    case .int128(let number):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        return String(number.value)
      }
      throw invalid(value, path: path)
    case .uint128(let number):
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        return String(number.value)
      }
      throw invalid(value, path: path)
    case .date, .data: throw invalid(value, path: path)
    }
  }

  private static func invalid(_ value: Enigma, path: [Enigma.Pin]) -> EncodingError {
    .invalidValue(value, .init(codingPath: path, debugDescription: "Value is not representable in JSON"))
  }

  private static func quote(_ value: String) -> String {
    var result = "\""
    for scalar in value.unicodeScalars {
      switch scalar.value {
      case 0x22: result += "\\\""
      case 0x5C: result += "\\\\"
      case 0...0x1F:
        let hex = String(scalar.value, radix: 16)
        result += "\\u" + String(repeating: "0", count: 4 - hex.count) + hex
      default: result.unicodeScalars.append(scalar)
      }
    }
    return result + "\""
  }
}
