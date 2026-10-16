import Foundation

struct JsonDecoder {
  private let bytes: [UInt8]
  private var index = 0
  private var path: [Enigma.Pin] = []

  init(_ string: String) {
    bytes = Array(string.utf8)
  }

  mutating func decode() throws(DecodingError) -> Enigma {
    // A leading Unicode BOM is permitted for encoded text.
    if bytes.starts(with: [0xEF, 0xBB, 0xBF]) { index = 3 }
    let result = try value()
    whitespace()
    guard index == bytes.count else { throw invalid("Unexpected trailing content") }
    return result
  }

  private mutating func whitespace() {
    while index < bytes.count, [9, 10, 13, 32].contains(bytes[index]) { index += 1 }
  }

  private mutating func take(_ byte: UInt8) -> Bool {
    guard index < bytes.count, bytes[index] == byte else { return false }
    index += 1
    return true
  }

  private func invalid(_ message: String) -> DecodingError {
    .dataCorrupted(.init(codingPath: path, debugDescription: "\(message) at UTF-8 byte \(index)"))
  }

  private mutating func value() throws(DecodingError) -> Enigma {
    whitespace()
    guard path.count < 512 else { throw invalid("JSON nesting limit exceeded") }
    guard index < bytes.count else { throw invalid("Expected a JSON value") }
    switch bytes[index] {
    case 0x22: return .string(try string())
    case 0x7B:
      index += 1
      whitespace()
      var result: [String: Enigma] = [:]
      if take(0x7D) { return .dictionary(result) }
      while true {
        whitespace()
        let key = try string()
        whitespace()
        guard take(0x3A) else { throw invalid("Expected ':'") }
        path.append(.str(key))
        result[key] = try value()
        path.removeLast()
        whitespace()
        if take(0x7D) { return .dictionary(result) }
        guard take(0x2C) else { throw invalid("Expected ',' or '}'") }
      }
    case 0x5B:
      index += 1
      whitespace()
      var result: [Enigma] = []
      if take(0x5D) { return .array(result) }
      while true {
        path.append(.int(result.count))
        result.append(try value())
        path.removeLast()
        whitespace()
        if take(0x5D) { return .array(result) }
        guard take(0x2C) else { throw invalid("Expected ',' or ']'") }
      }
    case 0x74: return try literal("true", value: .bool(true))
    case 0x66: return try literal("false", value: .bool(false))
    case 0x6E: return try literal("null", value: .null)
    case 0x2D, 0x30...0x39: return try number()
    default: throw invalid("Expected a JSON value")
    }
  }

  private mutating func literal(_ text: String, value: Enigma) throws(DecodingError) -> Enigma {
    guard bytes[index...].starts(with: text.utf8) else { throw invalid("Invalid JSON literal") }
    index += text.utf8.count
    return value
  }

  private mutating func string() throws(DecodingError) -> String {
    guard take(0x22) else { throw invalid("Expected a quoted string") }
    var result: [UInt8] = []
    while index < bytes.count {
      let byte = bytes[index]
      index += 1
      if byte == 0x22 { return String(decoding: result, as: UTF8.self) }
      guard byte >= 0x20 else { throw invalid("Unescaped control character") }
      if byte != 0x5C {
        result.append(byte)
        continue
      }
      guard index < bytes.count else { throw invalid("Incomplete escape") }
      let escape = bytes[index]
      index += 1
      switch escape {
      case 0x22, 0x5C, 0x2F: result.append(escape)
      case 0x62: result.append(8)
      case 0x66: result.append(12)
      case 0x6E: result.append(10)
      case 0x72: result.append(13)
      case 0x74: result.append(9)
      case 0x75:
        var code = try hex()
        if (0xD800...0xDBFF).contains(code) {
          guard take(0x5C), take(0x75) else { throw invalid("Missing low surrogate") }
          let low = try hex()
          guard (0xDC00...0xDFFF).contains(low) else { throw invalid("Invalid low surrogate") }
          code = 0x10000 + ((code - 0xD800) << 10) + low - 0xDC00
        }
        guard let scalar = Unicode.Scalar(code) else { throw invalid("Invalid Unicode scalar") }
        result.append(contentsOf: String(scalar).utf8)
      default: throw invalid("Invalid escape")
      }
    }
    throw invalid("Unterminated string")
  }

  private mutating func hex() throws(DecodingError) -> UInt32 {
    var result: UInt32 = 0
    for _ in 0..<4 {
      guard index < bytes.count else { throw invalid("Incomplete Unicode escape") }
      let byte = bytes[index]
      index += 1
      let digit: UInt8
      switch byte {
      case 48...57: digit = byte - 48
      case 65...70: digit = byte - 65 + 10
      case 97...102: digit = byte - 97 + 10
      default: throw invalid("Invalid hexadecimal digit")
      }
      result = result * 16 + UInt32(digit)
    }
    return result
  }

  private mutating func digits() -> Bool {
    let start = index
    while index < bytes.count, (48...57).contains(bytes[index]) { index += 1 }
    return index > start
  }

  private mutating func number() throws(DecodingError) -> Enigma {
    let start = index
    _ = take(45)
    if !take(48) {
      guard digits() else { throw invalid("Expected integer digits") }
    }
    var integer = true
    if take(46) {
      integer = false
      guard digits() else { throw invalid("Expected fractional digits") }
    }
    if take(101) || take(69) {
      integer = false
      if !take(43) { _ = take(45) }
      guard digits() else { throw invalid("Expected exponent digits") }
    }
    let text = String(decoding: bytes[start..<index], as: UTF8.self)
    if integer {
      if let number = Int(text) { return .int(number) }
      if let number = UInt64(text) { return .uint64(number) }
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        if let number = Int128(text) { return .int128(.init(number)) }
        if let number = UInt128(text) { return .uint128(.init(number)) }
      }
      throw invalid("Integer is outside the supported range")
    }
    guard let number = Double(text), number.isFinite else { throw invalid("Number is outside the Double range") }
    return .double(number)
  }
}
