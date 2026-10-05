import Foundation
import XCTest
@testable import Enigmatic

final class SerializationContractTests: XCTestCase {
  func testSingleValueDecoderFallbackTypes() throws {
    let date = Date(timeIntervalSince1970: 12)
    let data = Data([0, 1, 255])
    let values: [(Any, Enigma)] = [
      (true, .bool(true)),
      (UInt(300), .uint16(300)),
      (Int(-300), .int16(-300)),
      (Double.greatestFiniteMagnitude, .double(.greatestFiniteMagnitude)),
      ("text", .string("text")),
      (data, .data(data)),
      (date, .date(date)),
      (Float.greatestFiniteMagnitude, .float(.greatestFiniteMagnitude)),
      (UInt8.max, .uint8(.max)),
      (Int8.min, .int8(.min)),
      (UInt16.max, .uint16(.max)),
      (Int16.min, .int16(.min)),
      (UInt32.max, .uint32(.max)),
      (Int32.min, .int32(.min)),
      (UInt64.max, .uint64(.max)),
      (Int64.min, .int64(.min)),
    ]

    for (value, expected) in values {
      XCTAssertEqual(try Enigma(from: ExactSingleValueDecoder(value: value)), expected)
    }

    XCTAssertThrowsError(try Enigma(from: ExactSingleValueDecoder(value: NSObject())))
    XCTAssertThrowsError(try Enigma(from: NoContainerDecoder()))
  }

  func testJSONAndPlistErrorPaths() throws {
    for value in [Enigma.data(Data()), .date(Date()), .double(.infinity), .float(.nan)] {
      let tree: Enigma = ["values": .array([value])]
      XCTAssertEqual(try Enigma(cast: tree.asSwiftAny), tree)
      XCTAssertThrowsError(try tree.asJsonObject) { error in
        guard case EncodingError.invalidValue(_, let context) = error else { return XCTFail("\(error)") }
        XCTAssertEqual(context.codingPath.map(Enigma.Pin.init), ["values", 0])
      }
    }
    let tree: Enigma = ["values": [nil]]
    XCTAssertThrowsError(try tree.asPlistObject) { error in
      guard case EncodingError.invalidValue(_, let context) = error else { return XCTFail("\(error)") }
      XCTAssertEqual(context.codingPath.map(Enigma.Pin.init), ["values", 0])
    }
    XCTAssertEqual(try Enigma(cast: tree.asJsonObject), tree)
  }

  func testSerializationAndFoundationBridging() throws {
    let tree: Enigma = ["list": [.bool(true), .int8(-1), .uint64(.max), .double(1.25), "text"], "empty": [:]]
    XCTAssertEqual(try Enigma(cast: tree.asSwiftAny), tree)
    XCTAssertEqual(try Enigma(cast: tree.asJsonObject), tree)
    let bytes = try JSONSerialization.data(withJSONObject: tree.asJsonObject)
    XCTAssertEqual(try Enigma(cast: JSONSerialization.jsonObject(with: bytes)), tree)
    let plist: Enigma = ["date": .date(Date(timeIntervalSince1970: 0)), "data": .data(Data([0, 255]))]
    for format in [PropertyListSerialization.PropertyListFormat.xml, .binary] {
      let data = try PropertyListSerialization.data(fromPropertyList: plist.asPlistObject, format: format, options: 0)
      XCTAssertEqual(try Enigma(cast: PropertyListSerialization.propertyList(from: data, format: nil)), plist)
    }
    XCTAssertEqual(try Enigma(cast: NSNumber(value: true)).asBool, true)
    XCTAssertEqual(try Enigma(cast: NSNumber(value: 2)).asInt, 2)
    XCTAssertEqual(try Enigma(cast: NSNull()), .null)
    XCTAssertEqual(try Enigma(cast: nil), .null)
  }

  func testAllCasesThroughTypedAccessors() {
    var values: [Enigma] = [
      .null, .bool(true), .int(1), .int64(1), .int32(1), .int16(1), .int8(1),
      .uint(1), .uint64(1), .uint32(1), .uint16(1), .uint8(1), .double(1.5),
      .float(1.5), .string("text"), .array([.null]), .dictionary(["key": .null]),
      .data(Data([1])), .date(Date(timeIntervalSince1970: 1)),
    ]
    if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
      values += [.int128(.init(1)), .uint128(.init(1))]
    }

    for value in values {
      _ = value.asSwiftAny
      _ = value.array
      _ = value.dictionary
      _ = value.allPaths
      _ = value.isNull
      _ = value.isArray
      _ = value.isDictionary
      _ = value.asBool
      _ = value.asInt
      _ = value.asInt64
      _ = value.asInt32
      _ = value.asInt16
      _ = value.asInt8
      _ = value.asUInt
      _ = value.asUInt64
      _ = value.asUInt32
      _ = value.asUInt16
      _ = value.asUInt8
      _ = value.asFloat
      _ = value.asDouble
      _ = value.asString
      _ = value.asData
      _ = value.asDate
      _ = value.asArray
      _ = value.asDictionary
      _ = value.description
      _ = value.debugDescription
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        _ = value.asInt128
        _ = value.asUInt128
      }
    }
  }

  func testEveryTreeCaseThroughRootKeyedAndUnkeyedEncoders() throws {
    var values: [Enigma] = [
      .null, .bool(true), .int(1), .int64(1), .int32(1), .int16(1), .int8(1),
      .uint(1), .uint64(1), .uint32(1), .uint16(1), .uint8(1), .double(1.5),
      .float(1.5), .string("text"), .data(Data([1, 2])), .date(Date(timeIntervalSince1970: 1)),
      .array([.int(2)]), .dictionary(["nested": .string("value")]),
    ]
    if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
      values.append(.int128(.init(1)))
      values.append(.uint128(.init(1)))
    }

    for value in values {
      let rootData = try JSONEncoder().encode(value)
      XCTAssertNoThrow(try JSONDecoder().decode(Enigma.self, from: rootData))

      let arrayData = try JSONEncoder().encode([value])
      XCTAssertNoThrow(try JSONDecoder().decode(Enigma.self, from: arrayData))

      let dictionaryData = try JSONEncoder().encode(["value": value])
      XCTAssertNoThrow(try JSONDecoder().decode(Enigma.self, from: dictionaryData))

      switch value {
      case .data, .date, .int128, .uint128:
        XCTAssertThrowsError(try value.asJsonObject)
      case .double(let number) where !number.isFinite:
        XCTAssertThrowsError(try value.asJsonObject)
      case .float(let number) where !number.isFinite:
        XCTAssertThrowsError(try value.asJsonObject)
      default:
        XCTAssertNoThrow(try value.asJsonObject)
      }

      switch value {
      case .null, .int128, .uint128:
        XCTAssertThrowsError(try value.asPlistObject)
      default:
        XCTAssertNoThrow(try value.asPlistObject)
      }
    }
    let nestedValues: Enigma = ["values": .array(values)]
    XCTAssertNoThrow(try JSONEncoder().encode(nestedValues))
    let bridged = Enigma.array(values).asSwiftAny as? [Any]
    XCTAssertEqual(bridged?.count, values.count)

    let plistTree: Enigma = ["values": [.data(Data([1, 2])), .date(Date(timeIntervalSince1970: 2))]]
    let plistData = try PropertyListEncoder().encode(plistTree)
    XCTAssertGreaterThan(try PropertyListDecoder().decode(Enigma.self, from: plistData).allPaths.count, 3)
  }

  func testUnsupportedObjectsAndCollidingKeysReportErrors() {
    struct Unsupported {}
    assertDecodingError("dataCorrupted", path: ["items", 0]) {
      _ = try Enigma(cast: ["items": [Unsupported()]])
    }
    let keys: [AnyHashable: Any] = [AnyHashable(1): true, AnyHashable("1"): false]
    assertDecodingError("dataCorrupted", path: []) { _ = try Enigma(cast: keys) }
  }

  @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
  func testInt128NativeValuesAndSerializationRestrictions() throws {
    for value in [Int128.min, -1, 0, 1, Int128.max] {
      let tree = try Enigma(encode: value)
      XCTAssertEqual(tree.asSwiftAny as? Int128, value)
      XCTAssertEqual(try tree.decode(Int128.self), value)
      XCTAssertEqual(try Enigma(cast: tree.asSwiftAny), tree)
      XCTAssertEqual(tree.description, String(describing: value))
      XCTAssertEqual(tree.debugDescription, String(reflecting: value))
      XCTAssertThrowsError(try tree.asJsonObject)
      XCTAssertThrowsError(try tree.asPlistObject)
    }
    for value in [UInt128.min, 1, UInt128.max] {
      let tree = try Enigma(encode: value)
      XCTAssertEqual(tree.asSwiftAny as? UInt128, value)
      XCTAssertEqual(try tree.decode(UInt128.self), value)
      XCTAssertEqual(try Enigma(cast: tree.asSwiftAny), tree)
      XCTAssertEqual(tree.description, String(describing: value))
      XCTAssertEqual(tree.debugDescription, String(reflecting: value))
      XCTAssertThrowsError(try tree.asJsonObject)
      XCTAssertThrowsError(try tree.asPlistObject)
    }


  }

  func testJSON64BitIntegerPrecision() throws {
    try checkJSONIntegerPrecision([Int64.min, .min + 1, -9_007_199_254_740_993, 9_007_199_254_740_993, .max - 1, .max])
    try checkJSONIntegerPrecision([UInt64(9_007_199_254_740_993), .max - 1, .max])
  }

  @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
  func testJSON128BitIntegerPrecision() throws {
    try checkJSONIntegerPrecision([Int128.min, .min + 1, Int128(Int64.min) - 1, Int128(UInt64.max) + 2, .max - 1, .max])
    try checkJSONIntegerPrecision([UInt128(UInt64.max) + 2, UInt128(Int128.max) + 1, .max - 1, .max])
  }

  private func checkJSONIntegerPrecision<T: FixedWidthInteger & Codable>(
    _ values: [T], file: StaticString = #filePath, line: UInt = #line
  ) throws {
    for value in values {
      XCTAssertEqual(try JSONDecoder().decode(T.self, from: Data(String(value).utf8)), value, file: file, line: line)
      let leaf = try Enigma(encode: value)
      let documents: [(String, Enigma, [Enigma.Pin])] = [
        ("\(value)", leaf, []),
        ("[\(value)]", .array([leaf]), [0]),
        ("{\"value\":\(value)}", .dictionary(["value": leaf]), ["value"]),
      ]
      for (json, original, path) in documents {
        for data in [Data(json.utf8), try JSONEncoder().encode(original)] {
          let decoded = try JSONDecoder().decode(Enigma.self, from: data)
          let recovered = try XCTUnwrap(decoded[path], file: file, line: line)
          // Compare native integers: Enigma equality can hide a rounded value.
          XCTAssertEqual(try recovered.decode(T.self), value, "\(T.self) \(value) at \(path)", file: file, line: line)
        }
      }
    }
  }

  func testJSONFloatingDownscalingPreservesValues() throws {
    let values: [Double] = [
      0.5, 0.1, Double(Float(0.1)), .leastNonzeroMagnitude, -Double.leastNonzeroMagnitude,
      Double(Float.leastNonzeroMagnitude) / 2, Double(Float.greatestFiniteMagnitude), .greatestFiniteMagnitude,
    ]
    for value in values {
      let leaf = Enigma.double(value)
      let documents: [(Enigma, [Enigma.Pin])] = [
        (leaf, []), (.array([leaf]), [0]), (.dictionary(["value": leaf]), ["value"]),
      ]
      for (original, path) in documents {
        let decoded = try JSONDecoder().decode(Enigma.self, from: JSONEncoder().encode(original))
        XCTAssertEqual(decoded[path]?.asDouble?.bitPattern, value.bitPattern, "\(value) at \(path)")
      }
    }
  }

  func testJSONFloatRoundTripPreservesDecimalEquality() throws {
    let value = Float(0.1)
    let original = Enigma.float(value)
    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(Enigma.self, from: data)
    XCTAssertEqual(decoded.asDouble?.bitPattern, Double(0.1).bitPattern)
    XCTAssertEqual(decoded, original)
    XCTAssertEqual(try decoded.decode(Float.self).bitPattern, value.bitPattern)
    XCTAssertEqual(try JSONDecoder().decode(Float.self, from: data).bitPattern, value.bitPattern)
  }

  func testJSONNumericEqualityAndDownscaling() throws {
    let a = Enigma.double(0.1)
    let b = Enigma.float(0.1)
    let c = Enigma.double(Double(Float(0.1)))
    XCTAssertEqual(try JSONEncoder().encode(a), try JSONEncoder().encode(b))
    XCTAssertNotEqual(try JSONEncoder().encode(b), try JSONEncoder().encode(c))

    var values: [Enigma] = [a, b, c, .float(1e12), .double(1e12), .double(1e23),
                           .double(Double(1e17).nextUp), .double(-0.0),
                           .float(.leastNonzeroMagnitude), .float(.greatestFiniteMagnitude)]
    // Deterministic bit-pattern sampling complements hand-picked boundary cases.
    var bits: UInt32 = 1
    for _ in 0..<256 {
      bits = bits &* 1_664_525 &+ 1_013_904_223
      let value = Float(bitPattern: bits)
      if value.isFinite { values.append(.float(value)) }
    }
    var doubleBits: UInt64 = 1
    for _ in 0..<256 {
      doubleBits = doubleBits &* 6_364_136_223_846_793_005 &+ 1
      let value = Double(bitPattern: doubleBits)
      if value.isFinite { values.append(.double(value)) }
    }
    for value in values {
      for original in [value, .array([value]), .dictionary(["value": .array([value])])] {
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Enigma.self, from: data)
        XCTAssertEqual(original, decoded, String(decoding: data, as: UTF8.self))
      }
    }
    for value in [Double(Float(0.1)), Double(1e17).nextUp, Double(Float.greatestFiniteMagnitude)] {
      let literal = Enigma(floatLiteral: value)
      XCTAssertEqual(literal, .double(value))
      XCTAssertEqual(literal.asDouble?.bitPattern, value.bitPattern)
    }
  }
}

private struct ExactSingleValueDecoder: Decoder {
  let value: Any
  var codingPath: [any CodingKey] { [] }
  var userInfo: [CodingUserInfoKey: Any] { [:] }

  func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
    throw DecodingError.typeMismatch([String: Any].self, .init(codingPath: codingPath, debugDescription: "Not keyed"))
  }

  func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
    throw DecodingError.typeMismatch([Any].self, .init(codingPath: codingPath, debugDescription: "Not unkeyed"))
  }

  func singleValueContainer() throws -> any SingleValueDecodingContainer {
    ExactSingleValueContainer(value: value)
  }
}

private struct ExactSingleValueContainer: SingleValueDecodingContainer {
  let value: Any
  var codingPath: [any CodingKey] { [] }
  func decodeNil() -> Bool { false }

  private func exact<T>(_ type: T.Type) throws -> T {
    guard let value = value as? T else {
      throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "Unexpected probe value"))
    }
    return value
  }

  func decode(_ type: Bool.Type) throws -> Bool { try exact(type) }
  func decode(_ type: String.Type) throws -> String { try exact(type) }
  func decode(_ type: Double.Type) throws -> Double { try exact(type) }
  func decode(_ type: Float.Type) throws -> Float { try exact(type) }
  func decode(_ type: Int.Type) throws -> Int { try exact(type) }
  func decode(_ type: Int8.Type) throws -> Int8 { try exact(type) }
  func decode(_ type: Int16.Type) throws -> Int16 { try exact(type) }
  func decode(_ type: Int32.Type) throws -> Int32 { try exact(type) }
  func decode(_ type: Int64.Type) throws -> Int64 { try exact(type) }
  func decode(_ type: UInt.Type) throws -> UInt { try exact(type) }
  func decode(_ type: UInt8.Type) throws -> UInt8 { try exact(type) }
  func decode(_ type: UInt16.Type) throws -> UInt16 { try exact(type) }
  func decode(_ type: UInt32.Type) throws -> UInt32 { try exact(type) }
  func decode(_ type: UInt64.Type) throws -> UInt64 { try exact(type) }
  func decode<T>(_ type: T.Type) throws -> T where T: Decodable { try exact(type) }
}

private struct NoContainerDecoder: Decoder {
  var codingPath: [any CodingKey] { [] }
  var userInfo: [CodingUserInfoKey: Any] { [:] }
  func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
    throw DecodingError.typeMismatch([String: Any].self, .init(codingPath: codingPath, debugDescription: "Unavailable"))
  }
  func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
    throw DecodingError.typeMismatch([Any].self, .init(codingPath: codingPath, debugDescription: "Unavailable"))
  }
  func singleValueContainer() throws -> any SingleValueDecodingContainer {
    throw DecodingError.typeMismatch(Any.self, .init(codingPath: codingPath, debugDescription: "Unavailable"))
  }
}
