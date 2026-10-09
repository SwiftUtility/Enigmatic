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

  func testUUIDUsesCodableStringRepresentation() throws {
    let uuid = UUID(uuidString: "550e8400-e29b-41d4-a716-446655440000")!
    let tree = try Enigma(encode: uuid)

    XCTAssertEqual(tree, .string(uuid.uuidString))
    XCTAssertEqual(try tree.decode(UUID.self), uuid)
    XCTAssertEqual(try JSONEncoder().encode(tree), try JSONEncoder().encode(uuid))
  }

  func testJSONAndPlistErrorPaths() throws {
    for value in [Enigma.data(Data()), .date(Date()), .double(.infinity), .float(.nan)] {
      let tree: Enigma = ["values": .array([value])]
      XCTAssertEqual(try Enigma(cast: tree.asAny), tree)
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
    XCTAssertEqual(try Enigma(cast: tree.asAny), tree)
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
  }

  func testCanonicalFloatFoundationSerializationRoundTrips() throws {
    let values: [Float] = [
      0.1,
      1.1111111e38,
      -1.1111111e38,
      1.5e-38,
      -1.5e-38,
      Float.leastNonzeroMagnitude,
      Float.greatestFiniteMagnitude,
      -0.0,
    ]

    for value in values {
      let original = Enigma.float(value)
      let canonicalWidening = original.asDouble.map(Enigma.double)

      let jsonData = try JSONSerialization.data(
        withJSONObject: original.asJsonObject,
        options: .fragmentsAllowed
      )
      let jsonValue = try JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed)
      let jsonRoundTrip = try Enigma(cast: jsonValue)
      assertFloatBridgeRoundTrip(jsonRoundTrip, source: value, canonicalWidening: canonicalWidening)

      let plistObject = [try original.asPlistObject]
      for format in [PropertyListSerialization.PropertyListFormat.xml, .binary] {
        let plistData = try PropertyListSerialization.data(
          fromPropertyList: plistObject,
          format: format,
          options: 0
        )
        let plistValues = try PropertyListSerialization.propertyList(from: plistData, format: nil) as! [Any]
        let plistRoundTrip = try Enigma(cast: plistValues[0])
        assertFloatBridgeRoundTrip(plistRoundTrip, source: value, canonicalWidening: canonicalWidening)
      }
    }

    let largest = Enigma.float(.greatestFiniteMagnitude)
    XCTAssertEqual(largest.asDouble.map(Enigma.double), largest)
    XCTAssertEqual(Enigma.double(Double(Float.greatestFiniteMagnitude)), largest)
  }

  private func assertFloatBridgeRoundTrip(
    _ roundTrip: Enigma,
    source: Float,
    canonicalWidening: Enigma?,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    if let canonicalWidening {
      XCTAssertEqual(roundTrip, canonicalWidening, file: file, line: line)
      if source == 0 {
        XCTAssertEqual(roundTrip.asFloat, 0, file: file, line: line)
      } else {
        XCTAssertEqual(roundTrip.asFloat?.bitPattern, source.bitPattern, file: file, line: line)
      }
    } else {
      let binaryWidening = Double(source)
      let original = Enigma.float(source)
      XCTAssertTrue(roundTrip == original || roundTrip == .double(binaryWidening), file: file, line: line)
      XCTAssertEqual(roundTrip.asFloat != nil, roundTrip == original, file: file, line: line)
    }
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
      _ = value.asAny
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
    let bridged = Enigma.array(values).asAny as? [Any]
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
      XCTAssertEqual(tree.asAny as? Int128, value)
      XCTAssertEqual(try tree.decode(Int128.self), value)
      XCTAssertEqual(try Enigma(cast: tree.asAny), tree)
      XCTAssertEqual(tree.description, String(describing: value))
      XCTAssertEqual(tree.debugDescription, String(reflecting: value))
      XCTAssertThrowsError(try tree.asJsonObject)
      XCTAssertThrowsError(try tree.asPlistObject)
    }
    for value in [UInt128.min, 1, UInt128.max] {
      let tree = try Enigma(encode: value)
      XCTAssertEqual(tree.asAny as? UInt128, value)
      XCTAssertEqual(try tree.decode(UInt128.self), value)
      XCTAssertEqual(try Enigma(cast: tree.asAny), tree)
      XCTAssertEqual(tree.description, String(describing: value))
      XCTAssertEqual(tree.debugDescription, String(reflecting: value))
      XCTAssertThrowsError(try tree.asJsonObject)
      XCTAssertThrowsError(try tree.asPlistObject)
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
