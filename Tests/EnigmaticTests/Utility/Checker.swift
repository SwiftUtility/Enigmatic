import Foundation
import Enigmatic
import XCTest

struct Checker {
  var nonConformingFloats: Bool = false
  var topLevelNil: Bool = false
  var hasData: Bool = false
  var hasDates: Bool = false
  var hasUrls: Bool = false
  var hasDeepNulls: Bool = false

  var failJsonEncode: Set<KeyPath<Coder, (JSONEncoder, JSONDecoder)>> {
    guard nonConformingFloats else { return [] }
    return [
      \.simpleJson,
      \.base64DataJson,
      \.iso8601DateJson,
      \.secondsDateJson,
    ]
  }

  var nonJsonSeriablizable: Bool {
    nonConformingFloats || hasData || hasDates
  }

  var nonPlistSeriablizable: Bool {
    hasDeepNulls || topLevelNil
  }
  var nonPlistCodable: Bool {
    topLevelNil
  }

  func check<Value: Codable & Equatable>(value: Value, file: StaticString = #filePath, line: UInt = #line) {
    for check in Check.allCases {
      XCTAssertNoThrow(try check.perform(value: value, checker: self, file: file, line: line), "Scenario: \(check)", file: file, line: line)
    }
  }

  private enum Check: Hashable, CaseIterable {
    case enigmaAndBack
    case xmlPlistEncodeDecode
    case binaryPlistEncodeDecode
    case serializedXmlPlistEncodeDecode
    case serializedBinaryPlistEncodeDecode
    case simpleJsonEncodeDecode
    case nonConformingFloatJsonEncodeDecode
    case base64DataJsonEncodeDecode
    case secondsDateJsonEncodeDecode
    case iso8601DateJsonEncodeDecode
    case serializedJsonEncodeDecode

    func perform<Value: Codable & Equatable>(value: Value, checker: Checker, file: StaticString, line: UInt) throws {
      switch self {
      case .enigmaAndBack:
        let encoded = try Enigma(encode: value)
        let decoded = try encoded.decode() as Value
        let restored = try Enigma(cast: encoded.asAny)
        if value == value {
          XCTAssertEqual(value, decoded, "Scenario: \(self)", file: file, line: line)
          XCTAssertEqual(encoded, restored, "Scenario: \(self)", file: file, line: line)
        } else {
          XCTAssertNotEqual(value, decoded, "Scenario: \(self)", file: file, line: line)
          XCTAssertNotEqual(encoded, restored, "Scenario: \(self)", file: file, line: line)
        }
      case .xmlPlistEncodeDecode:
        try Coder.check(value, checker, \.xmlPlistEncoder, scenario: String(describing: self), file: file, line: line)
      case .binaryPlistEncodeDecode:
        try Coder.check(value, checker, \.binaryPlistEncoder, scenario: String(describing: self), file: file, line: line)
      case .serializedXmlPlistEncodeDecode:
        try Coder.check(value, checker, .xml, scenario: String(describing: self), file: file, line: line)
      case .serializedBinaryPlistEncodeDecode:
        try Coder.check(value, checker, .binary, scenario: String(describing: self), file: file, line: line)
      case .simpleJsonEncodeDecode:
        try Coder.check(value, checker, \.simpleJson, scenario: String(describing: self), file: file, line: line)
      case .nonConformingFloatJsonEncodeDecode:
        try Coder.check(value, checker, \.nonConformingFloatJson, scenario: String(describing: self), file: file, line: line)
      case .base64DataJsonEncodeDecode:
        try Coder.check(value, checker, \.base64DataJson, scenario: String(describing: self), file: file, line: line)
      case .secondsDateJsonEncodeDecode:
        try Coder.check(value, checker, \.secondsDateJson, scenario: String(describing: self), file: file, line: line)
      case .iso8601DateJsonEncodeDecode:
        try Coder.check(value, checker, \.iso8601DateJson, scenario: String(describing: self), file: file, line: line)
      case .serializedJsonEncodeDecode:
        try Coder.check(value, checker, scenario: String(describing: self), file: file, line: line)
      }
    }
  }
}
