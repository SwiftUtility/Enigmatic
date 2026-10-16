import Foundation
import XCTest
@testable import Enigmatic

final class StrategyContractTests: XCTestCase {
  func roundTrip<S: Codec.EncodeStrategy & Codec.DecodeStrategy>(
    _ strategy: S.Type, _ value: S.BoxedValue, expected: Enigma,
    file: StaticString = #filePath, line: UInt = #line
  ) throws where S.BoxedValue: Equatable {
    let box = Codec.Box<S>(wrappedValue: value)
    let tree = try Enigma(encode: box)
    XCTAssertEqual(tree, expected, file: file, line: line)
    XCTAssertEqual(try tree.decode(Codec.Box<S>.self).wrappedValue, value, file: file, line: line)
    XCTAssertEqual(try JSONDecoder().decode(Codec.Box<S>.self, from: JSONEncoder().encode(box)), box, file: file, line: line)
  }

  func testScalarAndCollectionStrategies() throws {
    try roundTrip(Codec.Id<Int>.self, 42, expected: 42)
    try roundTrip(Codec.Base64Data.self, Data([1, 2, 3]), expected: "AQID")
    try roundTrip(Codec.Base64Data.self, Data(), expected: "")
    try roundTrip(Codec.Base64Data?.self, nil, expected: nil)
    try roundTrip(Codec.StringURL.self, URL(string: "https://example.com/a")!, expected: "https://example.com/a")
    try roundTrip(Codec.PathURL.self, URL(fileURLWithPath: "/tmp/enigmatic/path with spaces"), expected: "/tmp/enigmatic/path with spaces")
    try roundTrip([Codec.Id<Int>].self, [], expected: [])
    try roundTrip([String: Codec.Id<Int>].self, ["x": 1], expected: ["x": 1])
    try roundTrip([String: [Codec.Id<Int>?]].self, ["values": [1, nil, 3]], expected: ["values": [1, nil, 3]])
    let set = try Enigma.array([1, 1, 2]).decode(Codec.Box<Set<Codec.Id<Int>>>.self)
    XCTAssertEqual(set.wrappedValue, [1, 2])
    let encoded = try Enigma(encode: set)
    XCTAssertEqual(Set(try encoded.decode([Int].self)), [1, 2])
    try roundTrip(Set<Codec.Id<Int>>.self, [], expected: [])
    assertDecodingError("dataCorrupted", path: ["data"]) {
      _ = try Enigma.dictionary(["data": "!"]).decode([String: Codec.Box<Codec.Base64Data>].self)
    }
    assertDecodingError("dataCorrupted", path: []) {
      _ = try Enigma.string("http://[").decode(Codec.Box<Codec.StringURL>.self)
    }
    assertDecodingError("typeMismatch", path: [1]) {
      _ = try Enigma.array([1, "x"]).decode(Codec.Box<Set<Codec.Id<Int>>>.self)
    }
    assertDecodingError("dataCorrupted", path: ["values", 1]) {
      _ = try Enigma.dictionary(["values": .array(["AQID", "!"])]).decode([String: [Codec.Box<Codec.Base64Data>]].self)
    }
  }

  func testCanonicalFloatUsesDecimalSpellingAndRoundTripsFiniteValues() throws {
    for value: Float in [0.1, -0.1, .pi, .leastNonzeroMagnitude, -.leastNonzeroMagnitude,
                         .leastNormalMagnitude, .greatestFiniteMagnitude, -.greatestFiniteMagnitude] {
      let expected = Enigma.double(Double(String(value))!)
      try roundTrip(Codec.CanonicalFloat.self, value, expected: expected)
      let decoded = try expected.decode(Codec.Box<Codec.CanonicalFloat>.self).wrappedValue
      XCTAssertEqual(decoded.bitPattern, value.bitPattern)
    }
    let canonical = try Enigma(encode: Codec.Box<Codec.CanonicalFloat>(wrappedValue: 0.1))
    XCTAssertEqual(canonical, .double(0.1))
    XCTAssertNotEqual(canonical, .float(0.1))
    // The decimal spelling is above a Float midpoint whose binary value ties to even.
    let midpoint = Enigma.double(1.0000000596046448)
    XCTAssertEqual(midpoint.asFloat, 1)
    XCTAssertEqual(try midpoint.decode(Codec.Box<Codec.CanonicalFloat>.self).wrappedValue, Float(1).nextUp)
  }

  func testCanonicalFloatPreservesZeroSignsAndNonFiniteValues() throws {
    for value: Float in [0, -0.0, .infinity, -.infinity, .nan] {
      let box = Codec.Box<Codec.CanonicalFloat>(wrappedValue: value)
      let tree = try Enigma(encode: box)
      let decoded = try tree.decode(Codec.Box<Codec.CanonicalFloat>.self).wrappedValue
      if value.isNaN {
        XCTAssertTrue(tree.asDouble?.isNaN == true)
        XCTAssertTrue(decoded.isNaN)
      } else {
        XCTAssertEqual(decoded.bitPattern, value.bitPattern)
        XCTAssertEqual(tree.asDouble?.sign, value.sign)
      }
    }
    let encoder = JSONEncoder()
    encoder.nonConformingFloatEncodingStrategy = .convertToString(
      positiveInfinity: "inf", negativeInfinity: "-inf", nan: "nan"
    )
    let decoder = JSONDecoder()
    decoder.nonConformingFloatDecodingStrategy = .convertFromString(
      positiveInfinity: "inf", negativeInfinity: "-inf", nan: "nan"
    )
    let box = Codec.Box<[Codec.CanonicalFloat]>(wrappedValue: [.infinity, -.infinity, .nan])
    let values = try decoder.decode(type(of: box), from: encoder.encode(box)).wrappedValue
    XCTAssertEqual(Array(values.prefix(2)), [.infinity, -.infinity])
    XCTAssertTrue(values[2].isNaN)
    assertEncodingError(path: []) {
      _ = try JSONEncoder().encode(Codec.Box<Codec.CanonicalFloat>(wrappedValue: .infinity))
    }
  }

  func testCanonicalFloatRejectsOverflowUnderflowAndWrongTypesAtTheValuePath() throws {
    struct Payload: Decodable {
      @Codec.Box<[Codec.CanonicalFloat]> var values: [Float]
    }
    for value in [Double.greatestFiniteMagnitude, -Double.greatestFiniteMagnitude,
                  Double.leastNonzeroMagnitude, -Double.leastNonzeroMagnitude] {
      let tree: Enigma = ["values": [0, .double(value)]]
      assertDecodingError("dataCorrupted", path: ["values", 1]) { _ = try tree.decode(Payload.self) }
      let json = try JSONEncoder().encode(tree)
      assertDecodingError("dataCorrupted", path: ["values", 1]) {
        _ = try JSONDecoder().decode(Payload.self, from: json)
      }
    }
    assertDecodingError("typeMismatch", path: ["values", 0]) {
      _ = try Enigma.dictionary(["values": ["text"]]).decode(Payload.self)
    }
    assertDecodingError("valueNotFound", path: ["values", 0]) {
      _ = try Enigma.dictionary(["values": [nil]]).decode(Payload.self)
    }
  }

  func testDictionaryStrategiesSupportIntegerAndUnkeyedKeys() throws {
    let data = Data([1, 2, 3])
    try roundTrip([Int: Codec.Base64Data].self, [-2: data], expected: ["-2": "AQID"])
    // Codable uses alternating keys and values for keys such as Bool and enums.
    try roundTrip([Bool: Codec.Base64Data?].self, [true: data], expected: [true, "AQID"])
    try roundTrip([IntKeys: Codec.Base64Data?].self, [.one: nil], expected: [1, nil])
    assertDecodingError("dataCorrupted", path: [1]) {
      _ = try Enigma.array([true, "!"]).decode(Codec.Box<[Bool: Codec.Base64Data]>.self)
    }
  }

  func testStringDictionaryStrategiesKeepKeysAndOptionalValues() throws {
    struct Payload: Codable, Equatable {
      @Codec.Box<[String: Codec.Base64Data?]> var values: [String: Data?]
    }
    let payload = Payload(values: ["": Data(), "camelCase": Data([1, 2, 3]), "01": nil, "café": Data([255])])
    let expected: Enigma = ["values": ["": "", "camelCase": "AQID", "01": nil, "café": "/w=="]]
    XCTAssertEqual(try Enigma(encode: payload), expected)
    XCTAssertEqual(try expected.decode(Payload.self), payload)
    XCTAssertEqual(try JSONDecoder().decode(Payload.self, from: JSONEncoder().encode(payload)), payload)
    try roundTrip([String: Codec.Id<Int>].self, [:], expected: [:])
  }

  func testStringDictionaryStrategiesKeepValueCodingPaths() throws {
    struct Decoded: Decodable {
      @Codec.Box<[String: Codec.Base64Data]> var values: [String: Data]
    }
    enum Failure: Error { case invalid }
    struct Encoded: Encodable {
      @Codec.Box<[String: Result<Codec.Id<Never>, Failure>]> var values: [String: Result<Never, Failure>]
    }
    for key in ["", "01", "-2", "key"] {
      func checkPath(_ error: Error) {
        let path: [any CodingKey]
        switch error {
        case DecodingError.dataCorrupted(let context): path = context.codingPath
        case EncodingError.invalidValue(_, let context): path = context.codingPath
        default: return XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(path.map(\.stringValue), ["values", key])
        XCTAssertEqual(path.map(\.intValue), [nil, Int(key)])
      }
      let tree: Enigma = ["values": .dictionary([key: "!"])]
      let json = try JSONSerialization.data(withJSONObject: ["values": [key: "!"]])
      XCTAssertThrowsError(try tree.decode(Decoded.self)) { checkPath($0) }
      XCTAssertThrowsError(try JSONDecoder().decode(Decoded.self, from: json)) { checkPath($0) }
      let value = Encoded(values: [key: .failure(.invalid)])
      XCTAssertThrowsError(try Enigma(encode: value)) { checkPath($0) }
      XCTAssertThrowsError(try JSONEncoder().encode(value)) { checkPath($0) }
    }
  }

  func testStringDictionaryStrategiesKeepJSONKeyStrategies() throws {
    typealias Strategy = [String: Codec.Id<Int>]
    let box = Codec.Box<Strategy>(wrappedValue: ["camelCase": 1])
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    let data = try encoder.encode(box)
    XCTAssertEqual(try JSONSerialization.jsonObject(with: data) as? [String: Int], ["camel_case": 1])
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    XCTAssertEqual(try decoder.decode(Codec.Box<Strategy>.self, from: data), box)
  }

  @available(macOS 12.3, iOS 15.4, watchOS 8.5, tvOS 15.4, *)
  func testDictionaryStrategiesSupportCodingKeyRepresentableKeys() throws {
    enum Key: String, Codable, CodingKeyRepresentable { case first, second }
    try roundTrip([Key: Codec.Base64Data?].self, [.first: Data([1, 2, 3]), .second: nil],
                  expected: ["first": "AQID", "second": nil])
  }

  @available(macOS 12.3, iOS 15.4, watchOS 8.5, tvOS 15.4, *)
  func testExplicitCodingKeyedStrategySupportsKeysWithoutCodable() throws {
    enum Key: String, CodingKeyRepresentable { case first, second }
    try roundTrip(Codec.CodingKeyedDictionary<Key, Codec.Base64Data?>.self,
                  [.first: Data([1]), .second: nil], expected: ["first": "AQ==", "second": nil])
    try roundTrip([Key: Codec.Base64Data?].CodingKeyed.self, [:], expected: [:])
    try roundTrip([Enigma.Pin: Codec.Id<Int>].CodingKeyed.self,
                  [.int(-2): 1, .str("key"): 2], expected: ["-2": 1, "key": 2])
  }

  @available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
  func testCodingKeyedDictionariesKeepEncodeAndDecodeCapabilitiesSeparate() throws {
    enum Key: String, Codable, CodingKeyRepresentable { case item }
    struct Decoded: Decodable { let value: Int }
    struct Encoded: Encodable { let value: Int }
    let tree: Enigma = ["item": ["value": 1]]
    let automatic = try tree.decode(Codec.Box<[Key: Codec.Id<Decoded>]>.self)
    let explicit = try tree.decode(Codec.Box<[Key: Codec.Id<Decoded>].CodingKeyed>.self)
    XCTAssertEqual(automatic.wrappedValue[.item]?.value, 1)
    XCTAssertEqual(explicit.wrappedValue[.item]?.value, 1)
    let values: [Key: Encoded] = [.item: Encoded(value: 1)]
    XCTAssertEqual(try Enigma(encode: Codec.Box<[Key: Codec.Id<Encoded>]>(wrappedValue: values)), tree)
    XCTAssertEqual(try Enigma(encode: Codec.Box<[Key: Codec.Id<Encoded>].CodingKeyed>(wrappedValue: values)), tree)
  }

  @available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
  func testCodingKeyedDictionariesRejectInvalidKeysAndAliasesIncludingNullValues() throws {
    enum Key: String, Codable, CodingKeyRepresentable { case known }
    struct Payload: Decodable {
      @Codec.Box<[Key: Codec.Id<Int>]> var values: [Key: Int]
    }
    struct Aliases: Decodable {
      @Codec.Box<[Int: Codec.Id<Int>?]> var values: [Int: Int?]
    }
    let invalid: Enigma = ["values": ["unknown": 1]]
    let aliases: Enigma = ["values": ["1": nil, "01": nil]]
    for json in [false, true] {
      assertDecodingError("dataCorrupted", path: ["values", "unknown"]) {
        if json { _ = try JSONDecoder().decode(Payload.self, from: JSONEncoder().encode(invalid)) }
        else { _ = try invalid.decode(Payload.self) }
      }
      assertDecodingError("dataCorrupted", path: ["values", 1]) {
        if json { _ = try JSONDecoder().decode(Aliases.self, from: JSONEncoder().encode(aliases)) }
        else { _ = try aliases.decode(Aliases.self) }
      }
    }
  }

  @available(macOS 12.3, iOS 15.4, watchOS 8.5, tvOS 15.4, *)
  func testCodingKeyedDictionaryReportsCollidingEncodedKeys() {
    enum Key: String, CodingKeyRepresentable {
      case first, second
      var codingKey: any CodingKey { Enigma.Pin.str("shared") }
    }
    struct Payload: Encodable {
      @Codec.Box<[Key: Codec.Id<Int>].CodingKeyed> var values: [Key: Int]
    }
    assertEncodingError(path: ["values", "shared"]) {
      _ = try Enigma(encode: Payload(values: [.first: 1, .second: 2]))
    }
  }

  func testPathURLPreservesLiteralCharactersThroughSynthesizedCodable() throws {
    struct Payload: Codable {
      @Codec.Box<Codec.PathURL> var file: URL
    }
    let path = "/tmp/enigmatic/café with spaces%20#.txt"
    let payload = Payload(file: URL(fileURLWithPath: path, isDirectory: false))
    let tree = try Enigma(encode: payload)
    XCTAssertEqual(tree, ["file": .string(path)])
    let restored = try tree.decode(Payload.self)
    XCTAssertEqual(restored.file, payload.file)
    XCTAssertNil(restored.file.query)
    XCTAssertNil(restored.file.fragment)

    let json = try JSONEncoder().encode(payload)
    XCTAssertEqual(try JSONDecoder().decode([String: String].self, from: json), ["file": path])
    XCTAssertEqual(try JSONDecoder().decode(Payload.self, from: json).file, payload.file)
    assertDecodingError("typeMismatch", path: ["file"]) {
      _ = try Enigma.dictionary(["file": 42]).decode(Payload.self)
    }
  }

  func testPathURLResolvesRelativePathsAgainstTheWorkingDirectory() throws {
    let path = "enigmatic relative/file.txt"
    let expected = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
      .appendingPathComponent("enigmatic relative", isDirectory: true)
      .appendingPathComponent("file.txt", isDirectory: false)
    let box = try Enigma.string(path).decode(Codec.Box<Codec.PathURL>.self)
    XCTAssertEqual(box.wrappedValue.absoluteURL, expected)
    let tree = try Enigma(encode: box)
    XCTAssertEqual(tree, .string(expected.path))
    XCTAssertEqual(try tree.decode(Codec.Box<Codec.PathURL>.self).wrappedValue.absoluteURL, expected)
  }

  func testPathURLEncodesOnlyTheUnescapedPathOfANonFileURL() throws {
    let url = URL(string: "https://example.com/path%20with%20spaces/%2520%23?query=value#fragment")!
    let tree = try Enigma(encode: Codec.Box<Codec.PathURL>(wrappedValue: url))
    XCTAssertEqual(tree, "/path with spaces/%20#")
    let restored = try tree.decode(Codec.Box<Codec.PathURL>.self).wrappedValue
    XCTAssertTrue(restored.isFileURL)
    XCTAssertNil(restored.query)
    XCTAssertNil(restored.fragment)
  }

#if os(Windows)
  func testPathURLHandlesWindowsDriveAndNetworkPaths() throws {
    for (input, path, isDirectory) in [
      (#"C:\Enigmatic\café with spaces%20#.txt"#, "C:/Enigmatic/café with spaces%20#.txt", false),
      ("C:/Enigmatic/file.txt", "C:/Enigmatic/file.txt", false),
      (#"C:\Enigmatic\folder\"#, "C:/Enigmatic/folder/", true),
      ("C:/Enigmatic/folder/", "C:/Enigmatic/folder/", true),
      (#"C:\"#, "C:/", true),
      ("C:/", "C:/", true),
      (#"\\server\share\café with spaces%20#.txt"#, "//server/share/café with spaces%20#.txt", false),
      (#"\\server\share\folder\"#, "//server/share/folder/", true),
    ] {
      let tree = Enigma.string(input)
      let box = try tree.decode(Codec.Box<Codec.PathURL>.self)
      XCTAssertTrue(box.wrappedValue.isFileURL, input)
      XCTAssertEqual(box.wrappedValue.hasDirectoryPath, isDirectory, input)
      XCTAssertEqual(try Enigma(encode: box), .string(path), input)
      XCTAssertEqual(try JSONDecoder().decode(Codec.Box<Codec.PathURL>.self, from: JSONEncoder().encode(box)), box, input)
    }
  }
#endif

#if os(anyAppleOS) || os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  @available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
  func testPathURLKeepsFilePathNormalization() throws {
    for (input, path) in [
      ("/tmp//enigmatic///file/", "/tmp/enigmatic/file"),
      ("/tmp/enigmatic/file\0ignored", "/tmp/enigmatic/file"),
      ("/tmp/enigmatic/path with spaces", "/tmp/enigmatic/path with spaces"),
      ("/tmp/enigmatic/café", "/tmp/enigmatic/café"),
    ] {
      let decoded = try Enigma.string(input).decode(Codec.Box<Codec.PathURL>.self).wrappedValue
      XCTAssertTrue(decoded.isFileURL)
      XCTAssertEqual(decoded.path, path)
      XCTAssertFalse(decoded.hasDirectoryPath)
    }
  }
#endif

  func testOptionalBox() throws {
    typealias OptionalStrategy = Codec.Id<Int>?
    let box = Codec.OptionalBox<OptionalStrategy>(wrappedValue: 42)

    let json = try JSONEncoder().encode(box)
    XCTAssertEqual(String(decoding: json, as: UTF8.self), "42")
    XCTAssertEqual(try JSONDecoder().decode(Codec.OptionalBox<OptionalStrategy>.self, from: json), box)

    let tree = try Enigma(encode: box)
    XCTAssertEqual(tree, 42)
    XCTAssertEqual(try tree.decode(Codec.OptionalBox<OptionalStrategy>.self), box)
    XCTAssertEqual(box.description, "42")
    XCTAssertEqual(box.debugDescription, "42")
    XCTAssertEqual(Set([box, box]).count, 1)

    typealias NestedOptionalStrategy = Codec.Id<Int>??
    let nestedNil = Codec.OptionalBox<NestedOptionalStrategy>(wrappedValue: nil)
    let nestedNilJSON = try JSONEncoder().encode(nestedNil)
    XCTAssertEqual(String(decoding: nestedNilJSON, as: UTF8.self), "null")
    XCTAssertNil(try JSONDecoder().decode(Codec.OptionalBox<NestedOptionalStrategy>.self, from: nestedNilJSON).wrappedValue)

    let nestedNilTree = try Enigma(encode: nestedNil)
    XCTAssertEqual(nestedNilTree, .null)
    XCTAssertNil(try nestedNilTree.decode(Codec.OptionalBox<NestedOptionalStrategy>.self).wrappedValue)
  }

  func testOptionalBoxKeyedContainerSemantics() throws {
    struct OptionalField: Codable, Equatable {
      @Codec.Box<Codec.Id<Int>?> var value: Int?

      init(value: Int?) {
        self._value = Codec.Box(wrappedValue: value)
      }
    }

    let absent = OptionalField(value: nil)
    let json = try JSONEncoder().encode(absent)
    XCTAssertEqual(try JSONDecoder().decode(Enigma.self, from: json), [:])
    XCTAssertEqual(try Enigma(encode: absent), [:])

    let decodedMissingJSON = try JSONDecoder().decode(OptionalField.self, from: Data("{}".utf8))
    XCTAssertNil(decodedMissingJSON.value)
    XCTAssertNil(try Enigma.dictionary([:]).decode(OptionalField.self).value)

    let decodedNullJSON = try JSONDecoder().decode(OptionalField.self, from: Data("{\"value\":null}".utf8))
    XCTAssertNil(decodedNullJSON.value)
    XCTAssertNil(try Enigma.dictionary(["value": .null]).decode(OptionalField.self).value)

    let present = OptionalField(value: 42)
    let presentJSON = try JSONEncoder().encode(present)
    XCTAssertEqual(try JSONDecoder().decode(OptionalField.self, from: presentJSON), present)
    XCTAssertEqual(try Enigma(encode: present), ["value": 42])
    XCTAssertEqual(try Enigma.dictionary(["value": 42]).decode(OptionalField.self), present)

    assertDecodingError("typeMismatch", path: ["value"]) {
      _ = try Enigma.dictionary(["value": "not an integer"]).decode(OptionalField.self)
    }
  }

  func testDelayedFailureEncodingReportsCodingPath() throws {
    struct FailingEncode: Encodable {
      @Codec.Box<Result<Codec.Id<Never>, Enigma.CompositeError>>
      var fail = .failure(Enigma.CompositeError())
    }

    func assertFailure(_ error: Error, file: StaticString = #filePath, line: UInt = #line) {
      guard case EncodingError.invalidValue(_, let context) = error else {
        return XCTFail("Expected EncodingError.invalidValue, got \(error)", file: file, line: line)
      }
      XCTAssertEqual(context.codingPath.map(Enigma.Pin.init), ["fail"], file: file, line: line)
      let composite = context.underlyingError as? Enigma.CompositeError
      XCTAssertNotNil(composite, file: file, line: line)
      XCTAssertEqual(composite?.errors.count, 0, file: file, line: line)
    }

    XCTAssertThrowsError(try JSONEncoder().encode(FailingEncode())) { assertFailure($0) }
    XCTAssertThrowsError(try Enigma(encode: FailingEncode())) { assertFailure($0) }
  }

  func testDeepMixedCodingPaths() throws {
    struct FailingLeaf: Encodable {
      @Codec.Box<Result<Codec.Id<Never>, Enigma.CompositeError>>
      var fail = .failure(Enigma.CompositeError())
    }
    struct EncodeThree: Encodable { let outer: [FailingLeaf] }
    struct EncodeFour: Encodable {
      struct Group: Encodable { let items: FailingLeaf }
      let outer: [Group]
    }
    struct EncodeFive: Encodable {
      struct Group: Encodable { let items: [FailingLeaf] }
      let outer: [Group]
    }

    assertEncodingErrorPath(["outer", 0, "fail"]) {
      _ = try JSONEncoder().encode(EncodeThree(outer: [FailingLeaf()]))
    }
    assertEncodingErrorPath(["outer", 0, "fail"]) {
      _ = try Enigma(encode: EncodeThree(outer: [FailingLeaf()]))
    }
    assertEncodingErrorPath(["outer", 0, "items", "fail"]) {
      _ = try JSONEncoder().encode(EncodeFour(outer: [.init(items: FailingLeaf())]))
    }
    assertEncodingErrorPath(["outer", 0, "items", "fail"]) {
      _ = try Enigma(encode: EncodeFour(outer: [.init(items: FailingLeaf())]))
    }
    assertEncodingErrorPath(["outer", 0, "items", 0, "fail"]) {
      _ = try JSONEncoder().encode(EncodeFive(outer: [.init(items: [FailingLeaf()])]))
    }
    assertEncodingErrorPath(["outer", 0, "items", 0, "fail"]) {
      _ = try Enigma(encode: EncodeFive(outer: [.init(items: [FailingLeaf()])]))
    }

    struct DecodedLeaf: Decodable { let fail: Codec.Box<Codec.Base64Data> }
    struct DecodeThree: Decodable {
      struct Group: Decodable { let fail: Codec.Box<Codec.Base64Data> }
      let outer: [Group]
    }
    struct DecodeFour: Decodable {
      struct Group: Decodable { let items: DecodedLeaf }
      let outer: [Group]
    }
    struct DecodeFive: Decodable {
      struct Group: Decodable { let items: [DecodedLeaf] }
      let outer: [Group]
    }

    let cases: [(any Decodable.Type, String, Enigma, [Enigma.Pin])] = [
      (DecodeThree.self, #"{"outer":[{"fail":"!"}]}"#, ["outer": [["fail": "!"]]], ["outer", 0, "fail"]),
      (DecodeFour.self, #"{"outer":[{"items":{"fail":"!"}}]}"#, ["outer": [["items": ["fail": "!"]]]], ["outer", 0, "items", "fail"]),
      (DecodeFive.self, #"{"outer":[{"items":[{"fail":"!"}]}]}"#, ["outer": [["items": [["fail": "!"]]]]], ["outer", 0, "items", 0, "fail"]),
    ]
    for (type, json, tree, path) in cases {
      let data = Data(json.utf8)
      assertJSONDecodingError(path) {
        _ = try JSONDecoder().decode(type, from: data)
      }
      assertDecodingError("dataCorrupted", path: path) {
        _ = try tree.decode(type)
      }
    }
  }

  private func assertEncodingErrorPath(
    _ path: [Enigma.Pin], file: StaticString = #filePath, line: UInt = #line,
    _ body: () throws -> Void
  ) {
    XCTAssertThrowsError(try body(), file: file, line: line) { error in
      guard case EncodingError.invalidValue(_, let context) = error else {
        return XCTFail("Expected EncodingError.invalidValue, got \(error)", file: file, line: line)
      }
      XCTAssertEqual(context.codingPath.map(Enigma.Pin.init), path, file: file, line: line)
      XCTAssertTrue(context.underlyingError is Enigma.CompositeError, file: file, line: line)
    }
  }

  private func assertJSONDecodingError(
    _ path: [Enigma.Pin], file: StaticString = #filePath, line: UInt = #line,
    _ body: () throws -> Void
  ) {
    XCTAssertThrowsError(try body(), file: file, line: line) { error in
      guard case DecodingError.dataCorrupted(let context) = error else {
        return XCTFail("Expected DecodingError.dataCorrupted, got \(error)", file: file, line: line)
      }
      XCTAssertEqual(context.codingPath.map(Enigma.Pin.init), path, file: file, line: line)
    }
  }

  func testResultDefersFailureAndPreservesCause() throws {
    typealias Wrapped = Codec.Box<Result<Codec.Id<Int>, any Error>>
    let success = try Enigma.int(7).decode(Wrapped.self)
    XCTAssertEqual(try success.wrappedValue.get(), 7)
    XCTAssertEqual(try Enigma(encode: success), 7)
    let failed = try Enigma.string("bad").decode(Wrapped.self)
    guard case .failure(let original) = failed.wrappedValue else { return XCTFail("Expected failure") }
    XCTAssertTrue(original is DecodingError)
    XCTAssertThrowsError(try Enigma(encode: ["result": failed])) { error in
      guard case EncodingError.invalidValue(_, let context) = error else { return XCTFail("\(error)") }
      XCTAssertEqual(context.codingPath.map(Enigma.Pin.init), ["result"])
      XCTAssertTrue(context.underlyingError is DecodingError)
    }
  }

  func testEitherPriorityFallbackAndAggregatedErrors() throws {
    typealias Either = Codec.Either<Int, String>
    XCTAssertEqual(try Enigma.int(1).decode(Either.self).right, 1)
    XCTAssertEqual(try Enigma.string("s").decode(Either.self).left, "s")
    XCTAssertNil(Either.left("s").right)
    XCTAssertNil(Either.right(1).left)
    XCTAssertNotEqual(Either.left("1"), .right(1))
    XCTAssertEqual(Set([Either.left("s"), .right(1), .left("s")]).count, 2)
    XCTAssertEqual(try Enigma.int(1).decode(Codec.Either<Int, Double>.self), .right(1))
    XCTAssertEqual(try Enigma(encode: Either.left("s")), "s")
    typealias Strategy = Codec.Either<Codec.Id<Int>, Codec.Id<String>>
    try roundTrip(Strategy.self, .right(2), expected: 2)
    try roundTrip(Strategy.self, .left("s"), expected: "s")
    for decode in [
      { _ = try Enigma.array([true]).decode([Either].self) },
      { _ = try Enigma.array([true]).decode([Codec.Box<Strategy>].self) }
    ] {
      XCTAssertThrowsError(try decode()) { error in
        guard case DecodingError.dataCorrupted(let context) = error else { return XCTFail("\(error)") }
        XCTAssertEqual(context.codingPath.map(Enigma.Pin.init), [0])
        let composite = context.underlyingError as? Enigma.CompositeError
        XCTAssertEqual(composite?.errors.count, 2)
        XCTAssertTrue(composite?.errors.allSatisfy { $0 is DecodingError } == true)
      }
    }
  }

  func testEitherFallbackStartsAtTheBeginningAfterAPartialRead() throws {
    typealias Either = Codec.Either<[Int], [Enigma]>
    typealias Strategy = Codec.Either<[Codec.Id<Int>], [Codec.Id<Enigma>]>
    let tree: Enigma = [[1, "fallback"], [2, 3]]
    let expected: [Either] = [.left([1, "fallback"]), .right([2, 3])]
    XCTAssertEqual(try tree.decode([Either].self), expected)
    let boxes = try tree.decode([Codec.Box<Strategy>].self)
    XCTAssertEqual(boxes.map(\.wrappedValue), expected)
    XCTAssertEqual(try Enigma(encode: boxes), tree)
    let json = try JSONEncoder().encode(tree)
    XCTAssertEqual(try JSONDecoder().decode([Either].self, from: json), expected)
    XCTAssertEqual(try JSONDecoder().decode([Codec.Box<Strategy>].self, from: json).map(\.wrappedValue), expected)
  }

  func testBoxValueSemanticsAndCompositeError() throws {
    var box = Codec.Box<Codec.Id<Int>>(wrappedValue: 1)
    box.wrappedValue = 2
    XCTAssertEqual(box, .init(wrappedValue: 2))
    XCTAssertEqual(Set([box, box]).count, 1)
    XCTAssertEqual(box.description, "2")
    XCTAssertEqual(box.debugDescription, "2")
    var errors = Enigma.CompositeError()
    XCTAssertEqual(errors.get(3), 3)
    enum Failure: Error { case expected }
    func fail() throws -> Int { throw Failure.expected }
    XCTAssertNil(errors.get(try fail()))
    XCTAssertEqual(errors.errors.count, 1)
  }

  func testCompositeErrorRunPreservesCauseAndFailureOrder() {
    enum Failure: Error, Equatable { case first, second }
    func fail(_ failure: Failure) throws { throw failure }
    var errors = Enigma.CompositeError()
    guard case .dataCorrupted(let empty) = errors.dataCorrupted([]) else { return XCTFail("Wrong error") }
    XCTAssertNil(empty.underlyingError)
    var calls = 0
    func succeed() { calls += 1 }
    XCTAssertTrue(errors.run(succeed()))
    XCTAssertEqual(calls, 1)
    XCTAssertTrue(errors.errors.isEmpty)
    XCTAssertFalse(errors.run(try fail(.first)))
    guard case .dataCorrupted(let single) = errors.dataCorrupted([Enigma.Pin.str("value")]) else {
      return XCTFail("Wrong error")
    }
    XCTAssertEqual(single.underlyingError as? Failure, .first)
    XCTAssertEqual(single.codingPath.map(Enigma.Pin.init), ["value"])
    XCTAssertFalse(errors.run(try fail(.second)))
    guard case .dataCorrupted(let multiple) = errors.dataCorrupted([]) else { return XCTFail("Wrong error") }
    let causes = multiple.underlyingError as? Enigma.CompositeError
    XCTAssertEqual(causes?.errors.compactMap { $0 as? Failure }, [.first, .second])
  }

  @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
  func testEachHashingDeduplicatesEqualComponents() {
    let value = Codec.Each(1, "first", true)
    let equal = Codec.Each(1, "first", true)
    let differentFirst = Codec.Each(2, "first", true)
    let differentSecond = Codec.Each(1, "second", true)
    let differentThird = Codec.Each(1, "first", false)
    let values = Set([value, equal, differentFirst, differentSecond, differentThird])
    XCTAssertEqual(values.count, 4)
    for expected in [value, differentFirst, differentSecond, differentThird] {
      XCTAssertTrue(values.contains(expected))
    }
    var hasher = Hasher()
    var expected = hasher
    value.hash(into: &hasher)
    expected.combine(1)
    expected.combine("first")
    expected.combine(true)
    XCTAssertEqual(hasher.finalize(), expected.finalize())
  }

  @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
  func testEachWritableMembersKeepCopiesIndependent() throws {
    struct A: Codable, Equatable { var a: Int }
    struct B: Codable, Equatable { var b: String }
    let original = Codec.Each(A(a: 1), B(b: "first"))
    var changed = original
    changed.0.a = 2
    changed.1 = B(b: "second")
    XCTAssertEqual(original.0, A(a: 1))
    XCTAssertEqual(original.1, B(b: "first"))
    XCTAssertNotEqual(changed, original)
    XCTAssertEqual(try Enigma(encode: changed), ["a": 2, "b": "second"])
  }

  @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
  func testEachRejectsMultipleUnkeyedComponents() throws {
    struct TwoUnkeyedValues: Encodable {
      @Codec.Box<Codec.Each<[Codec.Id<Int>], [Codec.Id<Int>]>>
      var values: ([Int], [Int])

      init() {
        self._values = Codec.Box(wrappedValue: ([1], [2]))
      }
    }

    func assertUnkeyedConflict(
      _ error: Error,
      file: StaticString = #filePath,
      line: UInt = #line
    ) {
      guard case EncodingError.invalidValue(_, let context) = error else {
        return XCTFail("Expected EncodingError.invalidValue, got \(error)", file: file, line: line)
      }
      XCTAssertEqual(context.codingPath.map(Enigma.Pin.init), ["values"], file: file, line: line)
    }

    XCTAssertThrowsError(try Enigma(encode: TwoUnkeyedValues())) {
      assertUnkeyedConflict($0)
    }
  }

  @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
  func testEachCompositionAndConflicts() throws {
    struct A: Codable, Hashable { let a: Int }
    struct B: Codable, Hashable { let b: String }
    struct C: Codable, Hashable { let c: Bool }
    struct D: Codable, Hashable { let d: Double }
    let value = Codec.Each(A(a: 1), B(b: "s"))
    let tree = try Enigma(encode: value)
    XCTAssertEqual(tree, ["a": 1, "b": "s"])
    XCTAssertEqual(try tree.decode(type(of: value)), value)
    XCTAssertEqual(Set([value, value]).count, 1)
    XCTAssertNotEqual(value, Codec.Each(A(a: 2), B(b: "s")))
    let boxed = Codec.Box<Codec.Each<Codec.Id<A>, Codec.Id<B>>>(wrappedValue: (A(a: 1), B(b: "s")))
    XCTAssertEqual(try Enigma(encode: boxed), tree)
    let restored = try tree.decode(type(of: boxed))
    XCTAssertEqual(restored.wrappedValue.0, A(a: 1))
    XCTAssertEqual(restored.wrappedValue.1, B(b: "s"))

    let pair = Codec.Each2(A(a: 1), B(b: "s"))
    XCTAssertEqual(try Enigma(encode: pair), tree)
    XCTAssertEqual(try tree.decode(type(of: pair)), pair)
    XCTAssertEqual(Set([pair, pair]).count, 1)
    typealias PairStrategy = Codec.Each2<Codec.Id<A>, Codec.Id<B>>
    let pairBox = Codec.Box<PairStrategy>(wrappedValue: (A(a: 1), B(b: "s")))
    XCTAssertEqual(try Enigma(encode: pairBox), tree)
    let decodedPair = try tree.decode(Codec.Box<PairStrategy>.self).wrappedValue
    XCTAssertEqual(decodedPair.0, A(a: 1))
    XCTAssertEqual(decodedPair.1, B(b: "s"))

    let triple = Codec.Each3(A(a: 1), B(b: "s"), C(c: true))
    let tripleTree = try Enigma(encode: triple)
    XCTAssertEqual(tripleTree, ["a": 1, "b": "s", "c": true])
    XCTAssertEqual(try tripleTree.decode(type(of: triple)), triple)
    XCTAssertEqual(Set([triple, triple]).count, 1)

    let quadruple = Codec.Each4(A(a: 1), B(b: "s"), C(c: true), D(d: 2.5))
    let quadrupleTree = try Enigma(encode: quadruple)
    XCTAssertEqual(quadrupleTree, ["a": 1, "b": "s", "c": true, "d": 2.5])
    XCTAssertEqual(try quadrupleTree.decode(type(of: quadruple)), quadruple)
    XCTAssertEqual(Set([quadruple, quadruple]).count, 1)

    typealias TripleStrategy = Codec.Each3<Codec.Id<A>, Codec.Id<B>, Codec.Id<C>>
    let tripleBox = Codec.Box<TripleStrategy>(wrappedValue: (A(a: 1), B(b: "s"), C(c: true)))
    XCTAssertEqual(try Enigma(encode: tripleBox), tripleTree)
    let decodedTriple = try tripleTree.decode(Codec.Box<TripleStrategy>.self).wrappedValue
    XCTAssertEqual(decodedTriple.0, A(a: 1))
    XCTAssertEqual(decodedTriple.1, B(b: "s"))
    XCTAssertEqual(decodedTriple.2, C(c: true))

    typealias QuadrupleStrategy = Codec.Each4<Codec.Id<A>, Codec.Id<B>, Codec.Id<C>, Codec.Id<D>>
    let quadrupleBox = Codec.Box<QuadrupleStrategy>(wrappedValue: (A(a: 1), B(b: "s"), C(c: true), D(d: 2.5)))
    XCTAssertEqual(try Enigma(encode: quadrupleBox), quadrupleTree)
    let decodedQuadruple = try quadrupleTree.decode(Codec.Box<QuadrupleStrategy>.self).wrappedValue
    XCTAssertEqual(decodedQuadruple.0, A(a: 1))
    XCTAssertEqual(decodedQuadruple.1, B(b: "s"))
    XCTAssertEqual(decodedQuadruple.2, C(c: true))
    XCTAssertEqual(decodedQuadruple.3, D(d: 2.5))
    XCTAssertThrowsError(try Enigma(encode: Codec.Each(A(a: 1), A(a: 2))))
    XCTAssertThrowsError(try Enigma(encode: Codec.Each(1, 2)))
    assertDecodingError("keyNotFound", path: []) { _ = try Enigma.dictionary(["a": 1]).decode(type(of: value)) }
  }

  func testPlistDateAndLegacyUnixStrategies() throws {
    let epoch = Date(timeIntervalSinceReferenceDate: 0)
    try roundTrip(Codec.PlistDate.self, epoch, expected: 0)
    let date = Date(timeIntervalSince1970: -123)
    try roundTrip(Codec.UnixSecondsDate.self, date, expected: -123)
    try roundTrip(Codec.UnixMillisecondsDate.self, date, expected: -123000)
    try roundTrip(Codec.UnixIntSecondsDate.self, date, expected: -123)
    try roundTrip(Codec.UnixIntMillisecondsDate.self, date, expected: -123000)
    try checkInvalidDates(Codec.PlistDate.self)
    try checkInvalidDates(Codec.UnixSecondsDate.self)
    try checkInvalidDates(Codec.UnixMillisecondsDate.self)
    try checkInvalidDates(Codec.UnixIntSecondsDate.self)
    try checkInvalidDates(Codec.UnixIntMillisecondsDate.self)
    XCTAssertThrowsError(try Enigma(encode: Codec.Box<Codec.UnixMillisecondsDate>(wrappedValue: Date(timeIntervalSince1970: .greatestFiniteMagnitude))))
    XCTAssertThrowsError(try Enigma(encode: Codec.Box<Codec.UnixIntSecondsDate>(wrappedValue: Date(timeIntervalSince1970: Double(Int.max)))))
    XCTAssertThrowsError(try Enigma(encode: Codec.Box<Codec.UnixIntMillisecondsDate>(wrappedValue: Date(timeIntervalSince1970: Double(Int.max)))))
  }

  private func checkInvalidDates<S: Codec.EncodeStrategy & Codec.DecodeStrategy>(_ strategy: S.Type) throws where S.BoxedValue == Date {
    for number in [Double.nan, .infinity, -.infinity] {
      XCTAssertThrowsError(try Enigma(encode: Codec.Box<S>(wrappedValue: Date(timeIntervalSince1970: number)))) { error in
        XCTAssertTrue(error is EncodingError)
      }
      XCTAssertThrowsError(try Enigma.double(number).decode(Codec.Box<S>.self)) { error in
        XCTAssertTrue(error is DecodingError)
      }
    }
  }

  @available(anyAppleOS 26, *)
  func testScaledDatesAndTruncation() throws {
    let date = Date(timeIntervalSince1970: -123.25)
    try roundTrip(Codec.UnixDate<0>.self, date, expected: .double(-123.25))
    try roundTrip(Codec.UnixDate<3>.self, date, expected: -123250)
    try roundTrip(Codec.UnixDate<6>.self, date, expected: -123250000)
    try roundTrip(Codec.UnixIntDate<3>.self, date, expected: -123250)
    try roundTrip(Codec.UnixIntDate<6>.self, date, expected: -123250000)
    let truncated = try Enigma(encode: Codec.Box<Codec.UnixIntDate<0>>(wrappedValue: date))
    XCTAssertEqual(truncated, -123)
    XCTAssertEqual(try truncated.decode(Codec.Box<Codec.UnixIntDate<0>>.self).wrappedValue, Date(timeIntervalSince1970: -123))
    try checkInvalidDates(Codec.UnixDate<0>.self)
    try checkInvalidDates(Codec.UnixIntDate<0>.self)
    XCTAssertThrowsError(try Enigma(encode: Codec.Box<Codec.UnixDate<3>>(wrappedValue: Date(timeIntervalSince1970: .greatestFiniteMagnitude))))
    XCTAssertThrowsError(try Enigma(encode: Codec.Box<Codec.UnixIntDate<3>>(wrappedValue: Date(timeIntervalSince1970: .greatestFiniteMagnitude))))
    XCTAssertThrowsError(try Enigma(encode: Codec.Box<Codec.UnixIntDate<0>>(wrappedValue: Date(timeIntervalSince1970: Double(Int.max)))))
    // The lower bound is representable and must not be excluded by a strict comparison.
    XCTAssertEqual(try Enigma(encode: Codec.Box<Codec.UnixIntDate<0>>(wrappedValue: Date(timeIntervalSince1970: Double(Int.min)))), .int(Int.min))
    try checkInvalidScale(Codec.UnixDate<400>.self)
    try checkInvalidScale(Codec.UnixDate< -400 >.self)
    try checkInvalidScale(Codec.UnixIntDate<400>.self)
    try checkInvalidScale(Codec.UnixIntDate< -400 >.self)
    XCTAssertThrowsError(try Enigma.double(.greatestFiniteMagnitude).decode(Codec.Box<Codec.UnixDate< -3 >>.self))
    XCTAssertThrowsError(try Enigma.int(Int.max).decode(Codec.Box<Codec.UnixIntDate< -300 >>.self))
  }

  private func checkInvalidScale<S: Codec.EncodeStrategy & Codec.DecodeStrategy>(_ strategy: S.Type) throws where S.BoxedValue == Date {
    assertDecodingError("dataCorrupted", path: []) { _ = try Enigma.int(1).decode(Codec.Box<S>.self) }
    XCTAssertThrowsError(try Enigma(encode: Codec.Box<S>(wrappedValue: Date(timeIntervalSince1970: 1)))) { error in
      guard case EncodingError.invalidValue(_, let context) = error else { return XCTFail("\(error)") }
      XCTAssertTrue(context.codingPath.isEmpty)
    }
  }
}
