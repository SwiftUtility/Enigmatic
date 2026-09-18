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

  func check<Value: Codable & Equatable>(value: Value) {
    for check in Check.allCases {
      XCTAssertNoThrow(try check.perform(value: value, checker: self))
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

    func perform<Value: Codable & Equatable>(value: Value, checker: Checker) throws {
      switch self {
      case .enigmaAndBack:
        let encoded = try Enigma(encode: value)
        let decoded = try encoded.decode() as Value
        let erased = encoded.rawObject
        let restored = try Enigma(cast: erased)
        if value == value {
          XCTAssertEqual(value, decoded)
          XCTAssertEqual(encoded, restored)
        } else {
          XCTAssertNotEqual(value, decoded)
          XCTAssertNotEqual(encoded, restored)
        }
      case .xmlPlistEncodeDecode:
        try Coder.check(value, checker, \.xmlPlistEncoder)
      case .binaryPlistEncodeDecode:
        try Coder.check(value, checker, \.binaryPlistEncoder)
      case .serializedXmlPlistEncodeDecode:
        try Coder.check(value, checker, .xml)
      case .serializedBinaryPlistEncodeDecode:
        try Coder.check(value, checker, .binary)
      case .simpleJsonEncodeDecode:
        try Coder.check(value, checker, \.simpleJson)
      case .nonConformingFloatJsonEncodeDecode:
        try Coder.check(value, checker, \.nonConformingFloatJson)
      case .base64DataJsonEncodeDecode:
        try Coder.check(value, checker, \.base64DataJson)
      case .secondsDateJsonEncodeDecode:
        try Coder.check(value, checker, \.secondsDateJson)
      case .iso8601DateJsonEncodeDecode:
        try Coder.check(value, checker, \.iso8601DateJson)
      case .serializedJsonEncodeDecode:
        try Coder.check(value, checker)
      }
    }
  }
}
