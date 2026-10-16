import Foundation
import XCTest
@testable import Enigmatic

final class SerializationContractTests: XCTestCase {
  private var exactDecoderValues: [(Any, Enigma)] {
    let date = Date(timeIntervalSince1970: 12)
    let data = Data([0, 1, 255])
    return [
      (true, .bool(true)),
      (UInt(300), .uint(300)),
      (Int(-300), .int(-300)),
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
  }

  func testSingleValueDecoderFallbackTypes() throws {
    for (value, expected) in exactDecoderValues {
      XCTAssertEqual(try Enigma(from: ExactValueDecoder(value: value)), expected)
    }

    XCTAssertThrowsError(try Enigma(from: ExactValueDecoder(value: NSObject()))) { error in
      guard case DecodingError.dataCorrupted(let context) = error else {
        return XCTFail("Expected DecodingError.dataCorrupted, got \(error)")
      }
      XCTAssertTrue(context.underlyingError is Enigma.CompositeError)
    }
    XCTAssertThrowsError(try Enigma(from: NoContainerDecoder())) { error in
      guard case DecodingError.dataCorrupted(let context) = error else {
        return XCTFail("Expected DecodingError.dataCorrupted, got \(error)")
      }
      XCTAssertTrue(context.underlyingError is Enigma.CompositeError)
    }
  }

  func testKeyedDecoderFallbackTypes() throws {
    for (value, expected) in exactDecoderValues {
      let decoder = ExactValueDecoder(value: ["outer": [["value": value]]])
      let tree = try Enigma(from: decoder)
      XCTAssertEqual(tree, ["outer": [["value": expected]]])
      let decoded = try XCTUnwrap(tree["outer", 0, "value"])
      XCTAssertTrue(type(of: decoded.asAny) == type(of: expected.asAny), "Storage type for \(type(of: value))")
    }
  }

  func testUnkeyedDecoderFallbackTypesWithUnknownCount() throws {
    let values = exactDecoderValues
    let input: [Any] = [NSNull()] + values.map(\.0) + ["after"]
    let expected: [Enigma] = [.null] + values.map(\.1) + ["after"]
    let decoder = ExactValueDecoder(value: input, codingPath: [Enigma.Pin.str("outer")])
    XCTAssertNil(try decoder.unkeyedContainer().count)
    let tree = try Enigma(from: decoder)
    XCTAssertEqual(tree, .array(expected))
    for (index, value) in expected.enumerated() {
      let decoded = try XCTUnwrap(tree[.int(index)])
      XCTAssertTrue(type(of: decoded.asAny) == type(of: value.asAny), "Storage type at \(index)")
    }
  }

  func testExactDecoderFailuresKeepTheirPathsAndArrayPosition() throws {
    func checkFailure(_ error: Error, path: [Enigma.Pin]) {
      guard case DecodingError.dataCorrupted(let context) = error,
            let causes = context.underlyingError as? Enigma.CompositeError else {
        return XCTFail("Expected aggregated decoding errors, got \(error)")
      }
      XCTAssertEqual(context.codingPath.map(Enigma.Pin.init), path)
      XCTAssertGreaterThan(causes.errors.count, 1)
      for cause in causes.errors {
        guard case DecodingError.typeMismatch = cause else {
          return XCTFail("Unexpected cause: \(cause)")
        }
      }
    }
    let prefix: [Enigma.Pin] = ["outer", 2]
    let keyed = ExactValueDecoder(value: ["bad": NSObject()], codingPath: prefix)
    XCTAssertThrowsError(try Enigma(from: keyed)) { checkFailure($0, path: prefix + ["bad"]) }
    var array = ExactUnkeyedContainer(values: [Int8.min, NSObject(), UInt8.max], codingPath: prefix)
    XCTAssertThrowsError(try Enigma.decode(unkeyed: &array)) { checkFailure($0, path: prefix + [1]) }
    XCTAssertEqual(array.currentIndex, 1)
    let skipped = try array.superDecoder()
    XCTAssertEqual(skipped.codingPath.map(Enigma.Pin.init), prefix + [1])
    XCTAssertEqual(try array.decode(UInt8.self), .max)
    XCTAssertTrue(array.isAtEnd)
  }

  func testNumericTypeMismatchDiagnosticsAcrossContainers() {
    let values: [(Enigma, String)] = [
      (.int8(-1), "Int8"), (.int16(-1), "Int16"), (.int32(-1), "Int32"),
      (.uint(1), "UInt"), (.uint16(1), "UInt16"), (.uint32(1), "UInt32"),
    ]
    for (value, name) in values {
      let decodes: [([Enigma.Pin], () throws -> Void)] = [
        ([], { _ = try value.decode(String.self) }),
        (["value"], { _ = try Enigma.dictionary(["value": value]).decode([String: String].self) }),
        ([0], { _ = try Enigma.array([value]).decode([String].self) }),
      ]
      for (path, decode) in decodes {
        XCTAssertThrowsError(try decode()) { error in
          guard case DecodingError.typeMismatch(let type, let context) = error else {
            return XCTFail("Unexpected error: \(error)")
          }
          XCTAssertTrue(type == String.self)
          XCTAssertEqual(context.codingPath.map(Enigma.Pin.init), path)
          XCTAssertEqual(context.debugDescription, "Found \(name)")
        }
      }
    }
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

  func testFloatFoundationSerializationRoundTrips() throws {
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

  func testUnsupportedNativeDictionaryKeysKeepNestedPaths() {
    struct UnsupportedKey: Hashable { let id: Int }
    for dictionary: Any in [[UnsupportedKey(id: 1): true], [UUID(): true], [true: 1]] {
      assertDecodingError("dataCorrupted", path: ["outer", 0, "value"]) {
        _ = try Enigma(cast: ["outer": [["value": dictionary]]])
      }
    }
  }

  func testDefaultObjectConversionReturnsNilAndCastRejectsIt() throws {
    final class UnsupportedObject: EnigmaConvertibleObject {}
    let object = UnsupportedObject()
    var pins: [Enigma.Pin] = ["outer", 0]
    XCTAssertNil(try object.convert(pins: &pins))
    XCTAssertEqual(pins, ["outer", 0])
    assertDecodingError("dataCorrupted", path: pins) {
      _ = try Enigma(cast: ["outer": [object]])
    }
  }

  func testNSValueRejectsUnsupportedEncodingsAtTheNestedPath() {
    var byte: UInt8 = 7
    let value = "[1C]".withCString { encoding in
      withUnsafePointer(to: &byte) { NSValue(bytes: $0, objCType: encoding) }
    }
    assertDecodingError("dataCorrupted", path: ["outer", 0, "value"]) {
      _ = try Enigma(cast: ["outer": [["value": value]]])
    }
  }

  @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
  func testNSValueExtractsSignedAndUnsignedInt128() throws {
    func boxed<T>(_ value: T, encoding: String) -> NSValue {
      encoding.withCString { type in
        withUnsafeBytes(of: value) { bytes in
#if os(anyAppleOS) || os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
          NSValue(bytes: bytes.baseAddress!, objCType: type)
#else
          // Corelibs Foundation cannot construct NSValue with t/T encodings.
          // Supply the same encoding and bytes through NSValue's primitive API.
          BitInt128Value(bytes: bytes.baseAddress!, objCType: type)
#endif
        }
      }
    }
    for value in [Int128.min, .max, -1, 0, Int128(1) << 64] {
      let source = boxed(value, encoding: "t")
      XCTAssertEqual(String(cString: source.objCType), "t")
      let tree = try Enigma(cast: ["outer": [source]])
      XCTAssertEqual(tree["outer", 0]?.asInt128, value)
      guard case .int128? = tree["outer", 0] else { return XCTFail("Expected signed storage") }
    }
    for value in [UInt128.min, .max, 1, UInt128(1) << 64] {
      let source = boxed(value, encoding: "T")
      XCTAssertEqual(String(cString: source.objCType), "T")
      let tree = try Enigma(cast: ["outer": [source]])
      XCTAssertEqual(tree["outer", 0]?.asUInt128, value)
      guard case .uint128? = tree["outer", 0] else { return XCTFail("Expected unsigned storage") }
    }
  }

  func testIntegerAndAnyHashableDictionaryKeysNormalizeWithoutLosingValues() throws {
    let integers = [Int.min: 1, -2: 2, 0: 3, Int.max: 4]
    XCTAssertEqual(try Enigma(cast: integers), .dictionary([
      String(Int.min): 1, "-2": 2, "0": 3, String(Int.max): 4,
    ]))
    let keys: [AnyHashable: Any] = [AnyHashable(Int8(-1)): true, AnyHashable(UInt64.max): "large"]
    XCTAssertEqual(try Enigma(cast: keys), .dictionary(["-1": true, String(UInt64.max): "large"]))
    assertDecodingError("dataCorrupted", path: ["outer", -2, 0]) {
      _ = try Enigma(cast: ["outer": [-2: [NSObject()]]])
    }
    assertDecodingError("dataCorrupted", path: ["outer"]) {
      _ = try Enigma(cast: ["outer": [AnyHashable(UUID()): 1]])
    }
  }

  @available(macOS 12.3, iOS 15.4, watchOS 8.5, tvOS 15.4, *)
  func testCodingKeyRepresentableCastAndCollisionPaths() throws {
    enum Key: String, CodingKeyRepresentable { case first, second }
    let values: [Key: Enigma] = [.first: [1, nil], .second: true]
    XCTAssertEqual(try Enigma(cast: values), ["first": [1, nil], "second": true])
    assertDecodingError("dataCorrupted", path: ["outer", "first", 0]) {
      _ = try Enigma(cast: ["outer": [Key.first: [NSObject()]]])
    }
    enum CollidingKey: String, CodingKeyRepresentable {
      case first, second
      var codingKey: any CodingKey { Enigma.Pin.str("shared") }
    }
    assertDecodingError("dataCorrupted", path: ["outer"]) {
      _ = try Enigma(cast: ["outer": [CollidingKey.first: 1, .second: 2]])
    }
  }

  func testAnyHashableValuesAndSetBridges() throws {
    let date = Date(timeIntervalSince1970: 123)
    let data = Data([1, 255])
    let values: [AnyHashable] = [true, 42, "text", AnyHashable(date), AnyHashable(data)]
    XCTAssertEqual(try Enigma(cast: values), .array([true, 42, "text", .date(date), .data(data)]))
    for set: Any in [Set([1, 2]), NSSet(array: [1, 2])] {
      XCTAssertEqual(Set(try Enigma(cast: set).decode([Int].self)), [1, 2])
    }
    assertDecodingError("dataCorrupted", path: ["items", 0]) {
      _ = try Enigma(cast: ["items": Set([UUID()])])
    }
    assertDecodingError("dataCorrupted", path: ["items", 0]) {
      _ = try Enigma(cast: ["items": NSSet(array: [NSObject()])])
    }
  }

  func testFloatCastsPreserveTheWidenedBinaryValue() throws {
    for value in [Float(0.1), .leastNonzeroMagnitude, .greatestFiniteMagnitude, -0.0] {
      for source: Any in [value, NSNumber(value: value), AnyHashable(value)] {
        let tree = try Enigma(cast: source)
        XCTAssertEqual(tree.asDouble?.bitPattern, Double(value).bitPattern)
        XCTAssertEqual(tree.asFloat?.bitPattern, value.bitPattern)
      }
    }
  }

  func testFoundationDictionariesRejectUnsupportedAndCollidingKeys() {
    let unsupported = NSDictionary(object: 1, forKey: NSNumber(value: 1))
    assertDecodingError("dataCorrupted", path: ["outer"]) {
      _ = try Enigma(cast: ["outer": unsupported])
    }
#if os(anyAppleOS) || os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    // NSString can distinguish keys that Swift String considers canonically equal.
    let colliding = NSDictionary(objects: [1, 2], forKeys: ["café" as NSString, "cafe\u{301}" as NSString])
    XCTAssertEqual(colliding.count, 2)
    assertDecodingError("dataCorrupted", path: ["outer", "café"]) {
      _ = try Enigma(cast: ["outer": colliding])
    }
#endif
  }

  @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
  func testTreeDecodingRetainsNativeValuesAcrossContainers() throws {
    struct Payload: Decodable { var value: Enigma }
    let values: [Enigma] = [
      .null, false, "text", [], [:],
      .date(Date(timeIntervalSince1970: 123.25)), .data(Data([1, 255])),
      .int128(.init(.min)), .uint128(.init(.max)), .uint64(.max),
      .int8(1), .int16(1), .int32(1), .int64(1), .int(1),
      .uint8(1), .uint16(1), .uint32(1), .uint64(1), .uint(1),
      .double(-0.0), .double(.nan), .double(.infinity),
    ]
    for value in values {
      for tree in [value, .array([value]), .dictionary(["value": value])] {
        let decoder = EnigmaDecoder.decoder(enigma: tree, userInfo: [:])
        XCTAssertEqual(try Enigma(from: decoder), tree)
      }
      let keyed = try Enigma.dictionary(["value": value]).decode(Payload.self).value
      let unkeyed = try Enigma.array([value]).decode([Enigma].self)[0]
      let single = try EnigmaDecoder.decoder(enigma: value, userInfo: [:])
        .singleValueContainer().decode(Enigma.self)
      for decoded in [keyed, unkeyed, single] {
        XCTAssertEqual(decoded, value)
        // Numeric equality alone would miss a change in integer storage width.
        XCTAssertTrue(type(of: decoded.asAny) == type(of: value.asAny))
        if case .double(let number) = value, number.isZero {
          XCTAssertEqual(decoded.asDouble?.sign, number.sign)
        }
      }
    }
  }

  @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
  func testInt128BoxSettersPreserveValuesAndCopyIndependence() {
    let signed = Enigma.Int128Box(-1)
    var signedCopy = signed
    for value in [Int128.min, .max, 0, -1, 1, Int128(1) << 64] {
      signedCopy.value = value
      XCTAssertEqual(signedCopy.value, value)
      XCTAssertEqual(signed.value, -1)
    }
    let unsigned = Enigma.UInt128Box(1)
    var unsignedCopy = unsigned
    for value in [UInt128.min, .max, 1, UInt128(1) << 64] {
      unsignedCopy.value = value
      XCTAssertEqual(unsignedCopy.value, value)
      XCTAssertEqual(unsigned.value, 1)
    }
  }

  @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
  func testJSONEncoderEncodesInt128InDictionaryTrees() throws {
    let signed = Enigma.int128(.init(.min))
    let unsigned = Enigma.uint128(.init(.max))
    let tree = Enigma.dictionary([
      "signed": signed, "unsigned": unsigned,
      "nested": .dictionary(["signed": signed, "unsigned": unsigned]),
    ])
    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    let json = String(decoding: try encoder.encode(tree), as: UTF8.self)
    let pair = "\"signed\":\(Int128.min),\"unsigned\":\(UInt128.max)"
    XCTAssertEqual(json, "{\"nested\":{\(pair)},\(pair)}")
    struct Values: Decodable, Equatable {
      let signed: Int128
      let unsigned: UInt128
    }
    struct Root: Decodable {
      let signed: Int128
      let unsigned: UInt128
      let nested: Values
    }
    let decoded = try JSONDecoder().decode(Root.self, from: Data(json.utf8))
    XCTAssertEqual(decoded.signed, .min)
    XCTAssertEqual(decoded.unsigned, .max)
    XCTAssertEqual(decoded.nested, Values(signed: .min, unsigned: .max))
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

#if !(os(anyAppleOS) || os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS))
private final class BitInt128Value: NSValue, @unchecked Sendable {
  private let storage: Data
  private let encoding: UnsafeMutablePointer<CChar>

  required init(bytes value: UnsafeRawPointer, objCType type: UnsafePointer<CChar>) {
    storage = Data(bytes: value, count: 16)
    encoding = .allocate(capacity: 2)
    encoding[0] = type.pointee
    encoding[1] = 0
    super.init()
  }

  required init?(coder: NSCoder) { return nil }
  deinit { encoding.deallocate() }
  override var objCType: UnsafePointer<CChar> { UnsafePointer(encoding) }
  override func getValue(_ value: UnsafeMutableRawPointer) {
    storage.copyBytes(to: value.assumingMemoryBound(to: UInt8.self), count: storage.count)
  }
}
#endif

private struct ExactValueDecoder: Decoder {
  let value: Any
  var codingPath: [any CodingKey] = []
  var userInfo: [CodingUserInfoKey: Any] { [:] }

  func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
    guard let values = value as? [String: Any] else {
      throw DecodingError.typeMismatch([String: Any].self, .init(codingPath: codingPath, debugDescription: "Not keyed"))
    }
    return KeyedDecodingContainer(ExactKeyedContainer<Key>(values: values, codingPath: codingPath))
  }

  func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
    guard let values = value as? [Any] else {
      throw DecodingError.typeMismatch([Any].self, .init(codingPath: codingPath, debugDescription: "Not unkeyed"))
    }
    return ExactUnkeyedContainer(values: values, codingPath: codingPath)
  }

  func singleValueContainer() throws -> any SingleValueDecodingContainer {
    ExactSingleValueContainer(value: value, codingPath: codingPath)
  }
}

private struct ExactSingleValueContainer: SingleValueDecodingContainer {
  let value: Any
  var codingPath: [any CodingKey] = []
  func decodeNil() -> Bool { value is NSNull }

  private func exact<T>(_ type: T.Type) throws -> T {
    guard Swift.type(of: value) == type, let value = value as? T else {
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

private struct ExactKeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
  let values: [String: Any]
  let codingPath: [any CodingKey]
  var allKeys: [Key] { values.keys.compactMap(Key.init(stringValue:)) }
  func contains(_ key: Key) -> Bool { values[key.stringValue] != nil }

  private func decoder(for key: any CodingKey) throws -> ExactValueDecoder {
    guard let value = values[key.stringValue] else {
      throw DecodingError.keyNotFound(key, .init(codingPath: codingPath, debugDescription: "Missing probe key"))
    }
    return ExactValueDecoder(value: value, codingPath: codingPath + [key])
  }

  func superDecoder(forKey key: Key) throws -> any Decoder { try decoder(for: key) }
  func superDecoder() throws -> any Decoder { try decoder(for: Enigma.Pin.super) }

  func decodeNil(forKey key: Key) throws -> Bool {
    try superDecoder(forKey: key).singleValueContainer().decodeNil()
  }

  func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
    try superDecoder(forKey: key).singleValueContainer().decode(type)
  }

  func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
    try superDecoder(forKey: key).container(keyedBy: type)
  }

  func nestedUnkeyedContainer(forKey key: Key) throws -> any UnkeyedDecodingContainer {
    try superDecoder(forKey: key).unkeyedContainer()
  }
}

private struct ExactUnkeyedContainer: UnkeyedDecodingContainer {
  let values: [Any]
  let codingPath: [any CodingKey]
  var currentIndex = 0
  var count: Int? { nil }
  var isAtEnd: Bool { currentIndex == values.count }

  private func current() throws -> ExactValueDecoder {
    guard !isAtEnd else {
      throw DecodingError.valueNotFound(Any.self, .init(codingPath: codingPath, debugDescription: "Probe at end"))
    }
    return ExactValueDecoder(value: values[currentIndex], codingPath: codingPath + [Enigma.Pin.int(currentIndex)])
  }

  private mutating func read<T>(_ body: (ExactValueDecoder) throws -> T) throws -> T {
    let value = try body(current())
    currentIndex += 1
    return value
  }

  mutating func decodeNil() throws -> Bool {
    guard try current().singleValueContainer().decodeNil() else { return false }
    currentIndex += 1
    return true
  }

  mutating func decode<T: Decodable>(_ type: T.Type) throws -> T {
    try read { try $0.singleValueContainer().decode(type) }
  }

  mutating func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
    try read { try $0.container(keyedBy: type) }
  }

  mutating func nestedUnkeyedContainer() throws -> any UnkeyedDecodingContainer {
    try read { try $0.unkeyedContainer() }
  }

  mutating func superDecoder() throws -> any Decoder { try read { $0 } }
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
