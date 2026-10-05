import Foundation
import Enigmatic
import XCTest

class Coder: @unchecked Sendable {
  let simpleJson = (JSONEncoder(), JSONDecoder())
  let nonConformingFloatJson = (JSONEncoder(), JSONDecoder())
  let base64DataJson = (JSONEncoder(), JSONDecoder())
  let secondsDateJson = (JSONEncoder(), JSONDecoder())
  let iso8601DateJson = (JSONEncoder(), JSONDecoder())
  let xmlPlistEncoder = PropertyListEncoder()
  let binaryPlistEncoder = PropertyListEncoder()
  let plistDecoder = PropertyListDecoder()

  private init() {
    nonConformingFloatJson.0.nonConformingFloatEncodingStrategy = .convertToString(
      positiveInfinity: "Infinity", negativeInfinity: "-Infinity", nan: "NaN"
    )
    nonConformingFloatJson.1.nonConformingFloatDecodingStrategy = .convertFromString(
      positiveInfinity: "Infinity", negativeInfinity: "-Infinity", nan: "NaN"
    )
    base64DataJson.0.dataEncodingStrategy = .base64
    base64DataJson.1.dataDecodingStrategy = .base64
    secondsDateJson.0.dateEncodingStrategy = .secondsSince1970
    secondsDateJson.1.dateDecodingStrategy = .secondsSince1970
    iso8601DateJson.0.dateEncodingStrategy = .iso8601
    iso8601DateJson.1.dateDecodingStrategy = .iso8601
    xmlPlistEncoder.outputFormat = .xml
    binaryPlistEncoder.outputFormat = .binary
  }

  private static let shared = Coder()

  static func check<Value: Codable & Equatable>(
    _ value: Value,
    _ checker: Checker,
    _ plistEncoder: KeyPath<Coder, PropertyListEncoder>,
    scenario: String = #function, file: StaticString = #filePath, line: UInt = #line
  ) throws {
    let encoded = try Enigma(encode: value)
    switch encoded {
    case .array, .dictionary:
      let enigmaData = try shared[keyPath: plistEncoder].encode(encoded)
      let valueData = try shared[keyPath: plistEncoder].encode(value)
      let straight = try shared.plistDecoder.decode(Value.self, from: valueData)
      let decoded = try shared.plistDecoder.decode(Enigma.self, from: enigmaData)
      let restored = try decoded.decode(Value.self)
      if value == value {
        XCTAssertEqual(value, straight, "Scenario: \(scenario)", file: file, line: line)
        XCTAssertEqual(value, restored, "Scenario: \(scenario)", file: file, line: line)
        if !checker.hasData, !checker.hasDates {
          XCTAssertEqual(encoded, decoded, "Scenario: \(scenario)", file: file, line: line)
        } else {
          XCTAssertNotEqual(encoded, decoded, "Scenario: \(scenario)", file: file, line: line)
        }
      } else {
        XCTAssertNotEqual(value, straight, "Scenario: \(scenario)", file: file, line: line)
        XCTAssertNotEqual(value, restored, "Scenario: \(scenario)", file: file, line: line)
        XCTAssertNotEqual(encoded, decoded, "Scenario: \(scenario)", file: file, line: line)
      }
    default:
      XCTAssertThrowsError(try shared[keyPath: plistEncoder].encode(encoded), "Scenario: \(scenario)", file: file, line: line)
    }
  }

  static func check<Value: Codable & Equatable>(
    _ value: Value,
    _ checker: Checker,
    _ fmt: PropertyListSerialization.PropertyListFormat,
    scenario: String = #function, file: StaticString = #filePath, line: UInt = #line
  ) throws {
    let encodedEnigma = try Enigma(encode: value)
    if checker.nonPlistSeriablizable {
      XCTAssertThrowsError(try encodedEnigma.asPlistObject, "Scenario: \(scenario)", file: file, line: line)
      XCTAssertThrowsError(try PropertyListSerialization.data(
        fromPropertyList: encodedEnigma.asAny,
        format: fmt,
        options: 0
      ), "Scenario: \(scenario)", file: file, line: line)
    } else {
      let encodedObject = try encodedEnigma.asPlistObject
      let data = try PropertyListSerialization.data(
        fromPropertyList: encodedObject,
        format: fmt,
        options: 0
      )
      let decodedObject = try PropertyListSerialization.propertyList(from: data, format: nil)
      let decodedEnigma = try Enigma(cast: decodedObject)
      let restored = try decodedEnigma.decode(Value.self)
      XCTAssertEqual(encodedEnigma, decodedEnigma, "Scenario: \(scenario)", file: file, line: line)
      if value == value {
        XCTAssertEqual(value, restored, "Scenario: \(scenario)", file: file, line: line)
      } else {
        XCTAssertNotEqual(value, restored, "Scenario: \(scenario)", file: file, line: line)
      }
    }
  }

  static func check<Value: Codable & Equatable>(
    _ value: Value,
    _ checker: Checker,
    _ jsonCodecs: KeyPath<Coder, (JSONEncoder, JSONDecoder)>,
    scenario: String = #function, file: StaticString = #filePath, line: UInt = #line
  ) throws {
    let encoded = try Enigma(encode: value)
    if checker.failJsonEncode.contains(jsonCodecs) {
      XCTAssertThrowsError(try shared[keyPath: jsonCodecs].0.encode(encoded), "Scenario: \(scenario)", file: file, line: line)
    } else {
      let enigmaData = try shared[keyPath: jsonCodecs].0.encode(encoded)
      let valueData = try shared[keyPath: jsonCodecs].0.encode(value)
      let straight = try shared[keyPath: jsonCodecs].1.decode(Value.self, from: valueData)
      let decoded = try shared[keyPath: jsonCodecs].1.decode(Enigma.self, from: enigmaData)
      let restored = try decoded.decode(Value.self)
      if value == value {
        XCTAssertEqual(value, straight, "Scenario: \(scenario)", file: file, line: line)
        XCTAssertEqual(value, restored, "Scenario: \(scenario)", file: file, line: line)
        if !checker.hasData, !checker.hasDates {
          XCTAssertEqual(encoded, decoded, "Scenario: \(scenario)", file: file, line: line)
        } else {
          XCTAssertNotEqual(encoded, decoded, "Scenario: \(scenario)", file: file, line: line)
        }
      } else {
        XCTAssertNotEqual(value, straight, "Scenario: \(scenario)", file: file, line: line)
        XCTAssertNotEqual(value, restored, "Scenario: \(scenario)", file: file, line: line)
        XCTAssertNotEqual(encoded, decoded, "Scenario: \(scenario)", file: file, line: line)
      }
    }
  }

  static func check<Value: Codable & Equatable>(
    _ value: Value,
    _ checker: Checker,
    scenario: String = #function, file: StaticString = #filePath, line: UInt = #line
  ) throws {
    let encodedEnigma = try Enigma(encode: value)
    if checker.nonJsonSeriablizable {
      XCTAssertThrowsError(try encodedEnigma.asJsonObject, "Scenario: \(scenario)", file: file, line: line)
    } else {
      let encodedObject = try encodedEnigma.asJsonObject
      let data = try JSONSerialization.data(
        withJSONObject: encodedObject,
        options: .fragmentsAllowed
      )
      let decodedObject = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
      let decodedEnigma = try Enigma(cast: decodedObject)
      let restored = try decodedEnigma.decode(Value.self)
      XCTAssertEqual(encodedEnigma, decodedEnigma, "Scenario: \(scenario)", file: file, line: line)
      if value == value {
        XCTAssertEqual(value, restored, "Scenario: \(scenario)", file: file, line: line)
      } else {
        XCTAssertNotEqual(value, restored, "Scenario: \(scenario)", file: file, line: line)
      }
    }
  }

  static func encode<Value: Codable>(
    _ value: Value,
    _ codec: KeyPath<Coder, (JSONEncoder, JSONDecoder)>
  ) throws -> Data {
    try shared[keyPath: codec].0.encode(value)
  }

  static func decode<Value: Codable>(
    _ value: Value.Type,
    _ data: Data,
    _ json: KeyPath<Coder, (JSONEncoder, JSONDecoder)>? = nil
  ) throws -> Value {
    if let json {
      try shared[keyPath: json].1.decode(Value.self, from: data)
    } else {
      try shared.plistDecoder.decode(Value.self, from: data)
    }
  }

  static func encode<Value: Codable>(
    _ value: Value,
    _ codec: KeyPath<Coder, PropertyListEncoder>
  ) throws -> Data {
    try shared[keyPath: codec].encode(value)
  }

  static func serialize(
    _ value: Any,
    _ fmt: PropertyListSerialization.PropertyListFormat? = nil
  ) throws -> Data {
    if let fmt {
      try PropertyListSerialization.data(
        fromPropertyList: value,
        format: fmt,
        options: 0
      )
    } else {
      try JSONSerialization.data(
        withJSONObject: value,
        options: .fragmentsAllowed
      )
    }
  }

  static func deserialize(
    _ data: Data,
    json: Bool
  ) throws -> Any {
    if json {
      try JSONSerialization.jsonObject(with: data)
    } else {
      try PropertyListSerialization.propertyList(from: data, format: nil)
    }
  }
}
