import Foundation
import XCTest
@testable import Enigmatic

struct EncodingProbe: Encodable {
  let body: (any Encoder) throws -> Void
  func encode(to encoder: any Encoder) throws { try body(encoder) }
}

func assertDecodingError(
  _ expected: String, path: [Enigma.Pin],
  file: StaticString = #filePath, line: UInt = #line,
  _ body: () throws -> Void
) {
  XCTAssertThrowsError(try body(), file: file, line: line) { error in
    let context: DecodingError.Context
    let kind: String
    switch error {
    case DecodingError.typeMismatch(_, let value): context = value; kind = "typeMismatch"
    case DecodingError.valueNotFound(_, let value): context = value; kind = "valueNotFound"
    case DecodingError.keyNotFound(_, let value): context = value; kind = "keyNotFound"
    case DecodingError.dataCorrupted(let value): context = value; kind = "dataCorrupted"
    default: return XCTFail("Unexpected error: \(error)", file: file, line: line)
    }
    XCTAssertEqual(kind, expected, file: file, line: line)
    XCTAssertEqual(context.codingPath.map(Enigma.Pin.init), path, file: file, line: line)
    XCTAssertFalse(context.debugDescription.isEmpty, file: file, line: line)
  }
}

final class ContainerContractTests: XCTestCase {
  typealias Key = Enigma.Pin

  func testUnkeyedContainerCannotBeReopened() throws {
    let result = try Enigma(encode: EncodingProbe { encoder in
      var first = encoder.unkeyedContainer()
      XCTAssertTrue(first.codingPath.isEmpty)
      XCTAssertEqual(first.count, 0)
      try first.encode(1)
      XCTAssertEqual(first.count, 1)
      var second = encoder.unkeyedContainer()
      XCTAssertEqual(second.count, 0)
      XCTAssertThrowsError(try second.encodeNil()) { error in
        guard case EncodingError.invalidValue(_, let context) = error else {
          return XCTFail("Unexpected \(error)")
        }
        XCTAssertEqual(context.codingPath.map(Key.init), [0])
      }
      XCTAssertEqual(first.count, 1)
      var nested = first.nestedContainer(keyedBy: Key.self)
      XCTAssertEqual(nested.codingPath.map(Key.init), [1])
      try nested.encode(true, forKey: "flag")
      XCTAssertEqual(first.count, 2)
      var array = first.nestedUnkeyedContainer()
      try array.encode("a")
      XCTAssertEqual(first.count, 3)
      var inherited = first.superEncoder().singleValueContainer()
      try inherited.encode(5)
      XCTAssertEqual(first.count, 4)
    })
    XCTAssertEqual(result, [1, ["flag": true], ["a"], 5])
  }

  func testKeyedContainerCanBeReopenedButUnkeyedChildCannot() throws {
    let result = try Enigma(encode: EncodingProbe { encoder in
      var first = encoder.container(keyedBy: Key.self)
      var second = encoder.container(keyedBy: Key.self)
      try first.encode(1, forKey: "a")
      try second.encode(2, forKey: "b")
      var child = first.nestedUnkeyedContainer(forKey: "array")
      try child.encode(3)
      var reopened = second.nestedUnkeyedContainer(forKey: "array")
      XCTAssertEqual(reopened.count, 0)
      XCTAssertThrowsError(try reopened.encode(4)) { error in
        guard case EncodingError.invalidValue(_, let context) = error else {
          return XCTFail("Unexpected \(error)")
        }
        XCTAssertEqual(context.codingPath.map(Key.init), ["array", 0])
      }
    })
    XCTAssertEqual(result, ["a": 1, "b": 2, "array": [3]])
  }

  func testConflictingContainersAndDuplicateWritesPreserveErrorPath() throws {
    for keyedFirst in [false, true] {
      XCTAssertThrowsError(try Enigma(encode: EncodingProbe { encoder in
        var root = encoder.container(keyedBy: Key.self)
        let child = root.superEncoder(forKey: "child")
        if keyedFirst {
          var keyed = child.container(keyedBy: Key.self)
          try keyed.encode(1, forKey: "a")
          var conflicting = child.unkeyedContainer()
          XCTAssertEqual(conflicting.count, 0)
          var nested = conflicting.nestedContainer(keyedBy: Key.self)
          try nested.encode(2, forKey: "bad")
        } else {
          var array = child.unkeyedContainer()
          try array.encode(1)
          var conflicting = child.container(keyedBy: Key.self)
          var nested = conflicting.nestedUnkeyedContainer(forKey: "bad")
          try nested.encode(2)
        }
      })) { error in
        guard case EncodingError.invalidValue(_, let context) = error else {
          return XCTFail("Unexpected \(error)")
        }
        XCTAssertEqual(context.codingPath.map(Key.init), keyedFirst ? ["child", 0, "bad"] : ["child", "bad", 0])
      }
    }
    XCTAssertThrowsError(try Enigma(encode: EncodingProbe { encoder in
      var c = encoder.container(keyedBy: Key.self)
      try c.encode(1, forKey: "value")
      try c.encode(2, forKey: "value")
    })) { error in
      guard case EncodingError.invalidValue(_, let context) = error else { return XCTFail("\(error)") }
      XCTAssertEqual(context.codingPath.map(Key.init), ["value"])
    }
  }

  func testUnkeyedDecodingPositionAndEnd() throws {
    var c = try EnigmaDecoder.decoder(enigma: [1, nil, "bad", [true], ["v": 2]], userInfo: [:]).unkeyedContainer()
    XCTAssertEqual(c.count, 5)
    XCTAssertFalse(try c.decodeNil())
    XCTAssertEqual(c.currentIndex, 0)
    XCTAssertEqual(try c.decode(Int.self), 1)
    XCTAssertTrue(try c.decodeNil())
    XCTAssertEqual(c.currentIndex, 2)
    assertDecodingError("typeMismatch", path: [2]) { _ = try c.decode(Int.self) }
    XCTAssertEqual(c.currentIndex, 2)
    XCTAssertEqual(try c.decode(String.self), "bad")
    var nested = try c.nestedUnkeyedContainer()
    XCTAssertEqual(nested.codingPath.map(Key.init), [3])
    XCTAssertTrue(try nested.decode(Bool.self))
    let keyed = try c.nestedContainer(keyedBy: Key.self)
    XCTAssertEqual(try keyed.decode(Int.self, forKey: "v"), 2)
    XCTAssertTrue(c.isAtEnd)
    assertDecodingError("valueNotFound", path: []) { _ = try c.decodeNil() }
    assertDecodingError("valueNotFound", path: []) { _ = try c.decode(Int.self) }
    assertDecodingError("valueNotFound", path: []) { _ = try c.nestedUnkeyedContainer() }
    assertDecodingError("valueNotFound", path: []) { _ = try c.nestedContainer(keyedBy: Key.self) }
    assertDecodingError("valueNotFound", path: []) { _ = try c.superDecoder() }
    XCTAssertEqual(c.currentIndex, 5)
  }

  func testMissingNullAndWrongTypes() throws {
    let decoder = EnigmaDecoder.decoder(enigma: ["nil": nil, "wrong": "s", "nested": [false]], userInfo: [:])
    let c = try decoder.container(keyedBy: Key.self)
    XCTAssertEqual(Set(c.allKeys), Set(["nil", "wrong", "nested"] as [Key]))
    XCTAssertFalse(c.contains("missing"))
    XCTAssertNil(try c.decodeIfPresent(Int.self, forKey: "missing"))
    XCTAssertNil(try c.decodeIfPresent(Int.self, forKey: "nil"))
    assertDecodingError("keyNotFound", path: []) { _ = try c.decode(Int.self, forKey: "missing") }
    assertDecodingError("typeMismatch", path: ["wrong"]) { _ = try c.decode(Int.self, forKey: "wrong") }
    assertDecodingError("typeMismatch", path: ["nested", 0]) { _ = try c.decode([Int].self, forKey: "nested") }
    assertDecodingError("typeMismatch", path: ["wrong"]) { _ = try c.nestedUnkeyedContainer(forKey: "wrong") }
    assertDecodingError("typeMismatch", path: ["wrong"]) { _ = try c.nestedContainer(keyedBy: Key.self, forKey: "wrong") }
    assertDecodingError("typeMismatch", path: []) { _ = try Enigma.int(1).decode([String: Int].self) }
    assertDecodingError("typeMismatch", path: []) { _ = try Enigma.int(1).decode([Int].self) }
  }

  func testUserInfoPropagatesThroughNestedAndSuperContainers() throws {
    let key = CodingUserInfoKey(rawValue: "marker")!
    let tree = try Enigma(encode: EncodingProbe { encoder in
      XCTAssertEqual(encoder.userInfo[key] as? String, "present")
      var c = encoder.container(keyedBy: Key.self)
      let child = c.superEncoder(forKey: "child")
      XCTAssertEqual(child.userInfo[key] as? String, "present")
      XCTAssertEqual(child.codingPath.map(Key.init), ["child"])
      var array = child.unkeyedContainer()
      let nested = array.superEncoder()
      XCTAssertEqual(nested.userInfo[key] as? String, "present")
      XCTAssertEqual(nested.codingPath.map(Key.init), ["child", 0])
      var single = nested.singleValueContainer()
      try single.encode(7)
    }, userInfo: [key: "present"])
    let decoder = EnigmaDecoder.decoder(enigma: tree, userInfo: [key: "present"])
    let c = try decoder.container(keyedBy: Key.self)
    let child = try c.superDecoder(forKey: "child")
    var array = try child.unkeyedContainer()
    let nested = try array.superDecoder()
    XCTAssertEqual(nested.userInfo[key] as? String, "present")
    XCTAssertEqual(nested.codingPath.map(Key.init), ["child", 0])
    XCTAssertEqual(try nested.singleValueContainer().decode(Int.self), 7)
  }

  func testRootDateAndDataMatchNestedRepresentation() throws {
    let date = Date(timeIntervalSince1970: 123.25)
    let data = Data([0, 1, 255])
    let dateTree = try Enigma(encode: date)
    let dataTree = try Enigma(encode: data)
    guard case .date = dateTree, case .data = dataTree else { return XCTFail("Native cases lost") }
    XCTAssertEqual(try dateTree.decode(Date.self), date)
    XCTAssertEqual(try dataTree.decode(Data.self), data)
    XCTAssertEqual(try Enigma(encode: [date])[0], dateTree)
    XCTAssertEqual(try Enigma(encode: ["data": data])["data"], dataTree)
    XCTAssertEqual(try JSONEncoder().encode(dateTree), try JSONEncoder().encode(date))
    let dataEncoder = JSONEncoder()
    dataEncoder.dataEncodingStrategy = .deferredToData
    XCTAssertEqual(try dataEncoder.encode(dataTree), try dataEncoder.encode(data))
    // Legacy Foundation representations still decode.
    XCTAssertEqual(try Enigma.double(date.timeIntervalSinceReferenceDate).decode(Date.self), date)
    XCTAssertEqual(try Enigma.array([0, 1, 255]).decode(Data.self), data)
  }

  func testNullErrorsAndUnkeyedRecovery() throws {
    let single = try EnigmaDecoder.decoder(enigma: .null, userInfo: [:]).singleValueContainer()
    assertDecodingError("valueNotFound", path: []) { _ = try single.decode(Int.self) }
    XCTAssertNil(try single.decode(Int?.self))
    XCTAssertEqual(try single.decode(Enigma.self), .null)

    let keyed = try EnigmaDecoder.decoder(enigma: ["value": nil], userInfo: [:]).container(keyedBy: Key.self)
    assertDecodingError("keyNotFound", path: []) { _ = try keyed.decodeNil(forKey: "missing") }
    XCTAssertTrue(try keyed.decodeNil(forKey: "value"))
    assertDecodingError("valueNotFound", path: ["value"]) { _ = try keyed.decode(Int.self, forKey: "value") }
    assertDecodingError("valueNotFound", path: ["value"]) { _ = try keyed.nestedUnkeyedContainer(forKey: "value") }
    XCTAssertNil(try keyed.decodeIfPresent(Int.self, forKey: "missing"))

    let parent = try EnigmaDecoder.decoder(enigma: ["child": ["value": nil]], userInfo: [:]).container(keyedBy: Key.self)
    let child = try parent.nestedContainer(keyedBy: Key.self, forKey: "child")
    assertDecodingError("valueNotFound", path: ["child", "value"]) { _ = try child.decode(Int.self, forKey: "value") }

    var array = try EnigmaDecoder.decoder(enigma: [nil, "wrong", 2], userInfo: [:]).unkeyedContainer()
    assertDecodingError("valueNotFound", path: [0]) { _ = try array.decode(Int.self) }
    XCTAssertEqual(array.currentIndex, 0)
    XCTAssertTrue(try array.decodeNil())
    assertDecodingError("typeMismatch", path: [1]) { _ = try array.decode([Int].self) }
    XCTAssertEqual(array.currentIndex, 1)
    XCTAssertEqual(try array.decode(String.self), "wrong")
    XCTAssertEqual(try array.decode(Int.self), 2)
    XCTAssertEqual(array.currentIndex, 3)
    XCTAssertThrowsError(try array.nestedUnkeyedContainer()) { error in
      guard case DecodingError.valueNotFound(let type, let context) = error else { return XCTFail("\(error)") }
      XCTAssertTrue(type == [Enigma].self)
      XCTAssertTrue(context.codingPath.isEmpty)
    }
    XCTAssertEqual(array.currentIndex, 3)
  }

  func testCompositionAndCaughtEncodingFailures() throws {
    struct Failing: Encodable {
      func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: Key.self)
        try c.encode(1, forKey: "partial")
        throw EncodingError.invalidValue(1, .init(codingPath: encoder.codingPath, debugDescription: "probe"))
      }
    }
    let tree = try Enigma(encode: EncodingProbe { encoder in
      var c = encoder.container(keyedBy: Key.self)
      try c.encode([1], forKey: "array")
      XCTAssertThrowsError(try c.encode([2], forKey: "array")) { error in
        guard case EncodingError.invalidValue(_, let context) = error else {
          return XCTFail("Unexpected \(error)")
        }
        XCTAssertEqual(context.codingPath.map(Key.init), ["array", 0])
      }
      try c.encode(["a": 1], forKey: "object")
      try c.encode(["b": 2], forKey: "object")
      var array = c.nestedUnkeyedContainer(forKey: "failures")
      XCTAssertThrowsError(try array.encode(Failing()))
      XCTAssertEqual(array.count, 1)
      try array.encode(2)
    })
    XCTAssertEqual(tree, ["array": [1], "object": ["a": 1, "b": 2], "failures": [["partial": 1], 2]])
  }

  func testNullableSuperclassDecoders() throws {
    let keyed = try EnigmaDecoder.decoder(enigma: ["super": nil, "parent": nil], userInfo: [:]).container(keyedBy: Key.self)
    XCTAssertNil(try keyed.superDecoder().singleValueContainer().decode(Int?.self))
    XCTAssertNil(try keyed.superDecoder(forKey: "parent").singleValueContainer().decode(Int?.self))
    var array = try EnigmaDecoder.decoder(enigma: [nil, 2], userInfo: [:]).unkeyedContainer()
    XCTAssertNil(try array.superDecoder().singleValueContainer().decode(Int?.self))
    XCTAssertEqual(array.currentIndex, 1)
    XCTAssertEqual(try array.decode(Int.self), 2)
  }

  func testEmbeddedEnigmaDateAndDataUseCodableRepresentation() throws {
    let date = Enigma.date(Date(timeIntervalSinceReferenceDate: 1.25))
    let data = Enigma.data(Data([1, 255]))
    guard case .date = try Enigma(encode: date), case .data = try Enigma(encode: data) else {
      return XCTFail("Root Enigma values must retain their cases")
    }
    let tree = try Enigma(encode: [date, data])
    guard case .double(1.25) = tree[0], case .array = tree[1] else {
      return XCTFail("Embedded Enigma values must use their Codable representation")
    }
    XCTAssertEqual(try tree[0]!.decode(Date.self), date.asDate)
    XCTAssertEqual(try tree[1]!.decode(Data.self), data.asData)
  }
}
