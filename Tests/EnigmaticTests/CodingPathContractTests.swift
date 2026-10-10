import Foundation
import XCTest
@testable import Enigmatic

final class CodingPathContractTests: XCTestCase {
  private enum FirstKey: String, CodingKey { case item }
  private enum CurrentKey: Int, CodingKey { case item = 7 }

  private func checkPath(
    _ actual: [any CodingKey], _ expected: [any CodingKey],
    file: StaticString = #filePath, line: UInt = #line
  ) {
    XCTAssertEqual(actual.map(\.stringValue), expected.map(\.stringValue), file: file, line: line)
    XCTAssertEqual(actual.map(\.intValue), expected.map(\.intValue), file: file, line: line)
  }

  func testDuplicateKeyPathsUseCurrentKeyThroughInvalidHandles() throws {
    let prefix: [any CodingKey] = [Enigma.Pin.str("outer"), Enigma.Pin.int(1), CurrentKey.item]
    let tree = try Enigma(encode: EncodingProbe { encoder in
      var root = encoder.container(keyedBy: Enigma.Pin.self)
      var array = root.nestedUnkeyedContainer(forKey: "outer")
      try array.encode(0)
      let child = array.superEncoder()
      var first = child.container(keyedBy: FirstKey.self)
      try first.encode(1, forKey: .item)
      var current = child.container(keyedBy: CurrentKey.self)
      var keyed = current.nestedContainer(keyedBy: CurrentKey.self, forKey: .item)
      var unkeyed = keyed.nestedUnkeyedContainer(forKey: .item)
      let invalid = unkeyed.superEncoder()
      let deepPath = prefix + [CurrentKey.item, Enigma.Pin.int(0)]
      self.checkPath(keyed.codingPath, prefix)
      self.checkPath(unkeyed.codingPath, prefix + [CurrentKey.item])
      self.checkPath(invalid.codingPath, deepPath)
      let writes: [([any CodingKey], () throws -> Void)] = [
        (prefix, { try current.encode(2, forKey: .item) }),
        (prefix, { try current.encodeNil(forKey: .item) }),
        (prefix, { try current.encode(Data([1]), forKey: .item) }),
        (prefix, { try current.encode(Date(timeIntervalSince1970: 0), forKey: .item) }),
        (prefix, { try Enigma.null.encode(to: current.superEncoder(forKey: .item)) }),
        (deepPath, { try Enigma.data(Data([1])).encode(to: invalid) }),
        (deepPath, { try Enigma.date(Date(timeIntervalSince1970: 0)).encode(to: invalid) }),
      ]
      for (path, write) in writes {
        XCTAssertThrowsError(try write()) { error in
          guard case EncodingError.invalidValue(_, let context) = error else {
            return XCTFail("Unexpected \(error)")
          }
          self.checkPath(context.codingPath, path)
        }
      }
    })
    XCTAssertEqual(tree, ["outer": [0, ["item": 1]]])
  }

  func testSavedSuperEncodersKeepTheirOwnPaths() throws {
    let tree = try Enigma(encode: EncodingProbe { encoder in
      var root = encoder.container(keyedBy: Enigma.Pin.self)
      let parent = root.superEncoder()
      var array = parent.unkeyedContainer()
      let first = array.superEncoder()
      let second = array.superEncoder()
      try Enigma.int(2).encode(to: second)
      try Enigma.int(1).encode(to: first)
      for (index, child) in [first, second].enumerated() {
        let path: [any CodingKey] = [Enigma.Pin.super, Enigma.Pin.int(index)]
        self.checkPath(child.codingPath, path)
        XCTAssertThrowsError(try Enigma.int(3).encode(to: child)) { error in
          guard case EncodingError.invalidValue(_, let context) = error else {
            return XCTFail("Unexpected \(error)")
          }
          self.checkPath(context.codingPath, path)
        }
        var incompatible = child.container(keyedBy: CurrentKey.self)
        XCTAssertThrowsError(try incompatible.encode(3, forKey: .item)) { error in
          guard case EncodingError.invalidValue(_, let context) = error else {
            return XCTFail("Unexpected \(error)")
          }
          self.checkPath(context.codingPath, path + [CurrentKey.item])
        }
      }
    })
    XCTAssertEqual(tree, ["super": [1, 2]])
  }

  func testNestedDecoderErrorsAndRecoveryPreservePaths() throws {
    let root = EnigmaDecoder.decoder(enigma: ["item": [0, ["item": nil]]], userInfo: [:])
    let keyed = try root.container(keyedBy: CurrentKey.self)
    var array = try keyed.superDecoder(forKey: .item).unkeyedContainer()
    XCTAssertThrowsError(try array.decode(String.self)) { error in
      guard case DecodingError.typeMismatch(_, let context) = error else {
        return XCTFail("Unexpected \(error)")
      }
      self.checkPath(context.codingPath, [CurrentKey.item, Enigma.Pin.int(0)])
    }
    XCTAssertEqual(array.currentIndex, 0)
    _ = try array.decode(Int.self)
    let child = try array.superDecoder()
    let prefix: [any CodingKey] = [CurrentKey.item, Enigma.Pin.int(1)]
    let fields = try child.container(keyedBy: CurrentKey.self)
    for decode in [
      { _ = try fields.decode(Int.self, forKey: .item) },
      { _ = try fields.nestedUnkeyedContainer(forKey: .item) },
      { _ = try fields.superDecoder(forKey: .item).singleValueContainer().decode(Int.self) },
    ] {
      XCTAssertThrowsError(try decode()) { error in
        guard case DecodingError.valueNotFound(_, let context) = error else {
          return XCTFail("Unexpected \(error)")
        }
        self.checkPath(context.codingPath, prefix + [CurrentKey.item])
      }
    }
    XCTAssertThrowsError(try fields.superDecoder()) { error in
      guard case DecodingError.keyNotFound(let key, let context) = error else {
        return XCTFail("Unexpected \(error)")
      }
      self.checkPath([key], [Enigma.Pin.super])
      self.checkPath(context.codingPath, prefix)
    }
    XCTAssertThrowsError(try array.decode(Int.self)) { error in
      guard case DecodingError.valueNotFound(_, let context) = error else {
        return XCTFail("Unexpected \(error)")
      }
      // Exhaustion identifies the container, as documented, not a nonexistent element.
      self.checkPath(context.codingPath, [CurrentKey.item])
    }
    XCTAssertEqual(array.currentIndex, 2)
  }

  func testUnrepresentableJSONNumbersIdentifyTheFailingValue() {
    let cases: [(String, [Enigma.Pin])] = [
      ("1e400", []),
      (#"{"outer":{"bad":1e400}}"#, ["outer", "bad"]),
      (#"{"outer":[1,1e400]}"#, ["outer", 1]),
      (#"{"outer":[{"bad":[0,1e400]}]}"#, ["outer", 0, "bad", 1]),
    ]
    for (json, path) in cases {
      XCTAssertThrowsError(try JSONDecoder().decode(Enigma.self, from: Data(json.utf8))) { error in
        guard case DecodingError.dataCorrupted(let context) = error else {
          return XCTFail("Unexpected \(error)")
        }
        // External decoders choose their own string representation for array indices.
        XCTAssertEqual(context.codingPath.map(Enigma.Pin.init), path)
        XCTAssertNotNil(context.underlyingError)
      }
    }
  }
}
