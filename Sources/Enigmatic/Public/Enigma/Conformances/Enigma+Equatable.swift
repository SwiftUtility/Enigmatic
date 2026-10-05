import Foundation

extension Enigma: Equatable {
  /// Compares trees using normalized decimal representations for numeric values.
  /// Float and Double use their shortest decimal descriptions, so both literals `0.1`
  /// compare equal. Integer widths and equivalent decimal/exponent forms are ignored.
  /// NaN compares equal to NaN, including Date timestamps. Signed zeros compare equal.
  /// Equality does not imply identical storage or an exact typed numeric conversion.
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch lhs {
    case .null: rhs.isNull
    case .bool(let lhs): lhs == rhs.asBool
    case .int, .int64, .int32, .int16, .int8, .uint, .uint64, .uint32, .uint16, .uint8, .double, .float:
      lhs.hasSameNumber(as: rhs)
    case .string(let lhs): lhs == rhs.asString
    case .date(let lhs): lhs.timeIntervalSinceReferenceDate.isSame(double: rhs.asDate?.timeIntervalSinceReferenceDate)
    case .data(let lhs): lhs == rhs.asData
    case .array(let lhs): lhs == rhs.asArray
    case .dictionary(let lhs): lhs == rhs.asDictionary
    case .int128(let value):
      if case .int128(let other) = rhs {
        value.low == other.low && value.high == other.high
      } else {
        lhs.hasSameNumber(as: rhs)
      }
    case .uint128(let value):
      if case .uint128(let other) = rhs {
        value.low == other.low && value.high == other.high
      } else {
        lhs.hasSameNumber(as: rhs)
      }
    }
  }
}

private extension Enigma {
  func hasSameNumber(as other: Self) -> Bool {
    guard let lhs = numericEqualityKey, let rhs = other.numericEqualityKey else { return false }
    return lhs == rhs
  }

  var numericEqualityKey: String? {
    switch self {
    case .int, .int64, .int32, .int16, .int8, .uint, .uint64, .uint32, .uint16, .uint8, .double, .float:
      break
    case .int128, .uint128:
      guard #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) else { return nil }
    default: return nil
    }

    // Numeric descriptions use Swift's shortest decimal form. Normalize text without
    // converting through Double or Decimal, which cannot retain every numeric range.
    var text = description[...]
    let negative = text.first == "-"
    if negative { text.removeFirst() }
    if text == "nan" { return "nan" }
    if text == "inf" { return negative ? "-inf" : "inf" }
    let parts = text.split(separator: "e", maxSplits: 1)
    let mantissa = parts[0]
    var exponent = parts.count == 2 ? Int(parts[1])! : 0
    if let dot = mantissa.firstIndex(of: ".") {
      exponent -= mantissa.distance(from: mantissa.index(after: dot), to: mantissa.endIndex)
    }
    var digits = mantissa.filter { $0 != "." }
    while digits.first == "0" { digits.removeFirst() }
    if digits.isEmpty { return "0" }
    while digits.last == "0" {
      digits.removeLast()
      exponent += 1
    }
    return "\(negative ? "-" : "")\(digits)e\(exponent)"
  }
}
