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

  func testDuplicateKeyPathsUseCurrentKeyThroughInvalidHandles() {
    let prefix: [any CodingKey] = [Enigma.Pin.str("outer"), Enigma.Pin.int(1), CurrentKey.item]
    assertEncodingError(keys: prefix) {
      _ = try Enigma(encode: EncodingProbe { encoder in
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
        let writes: [() throws -> Void] = [
          { try current.encode(2, forKey: .item) },
          { try current.encodeNil(forKey: .item) },
          { try current.encode(Data([1]), forKey: .item) },
          { try current.encode(Date(timeIntervalSince1970: 0), forKey: .item) },
          { try Enigma.null.encode(to: current.superEncoder(forKey: .item)) },
          { try Enigma.data(Data([1])).encode(to: invalid) },
          { try Enigma.date(Date(timeIntervalSince1970: 0)).encode(to: invalid) },
        ]
        // Handles keep their own paths; every write reports the first inconsistency.
        for write in writes {
          assertEncodingError(keys: prefix, write)
        }
      })
    }
  }

  func testSavedSuperEncodersKeepTheirOwnPathsAfterCaughtEnigmaWrites() throws {
    let tree = try Enigma(encode: EncodingProbe { encoder in
      var root = encoder.container(keyedBy: Enigma.Pin.self)
      let parent = root.superEncoder()
      var array = parent.unkeyedContainer()
      let first = array.superEncoder()
      let second = array.superEncoder()
      var firstSingle = first.singleValueContainer()
      var secondSingle = second.singleValueContainer()
      try secondSingle.encode(Enigma.int(2))
      try firstSingle.encode(Enigma.int(1))
      for (index, child) in [first, second].enumerated() {
        let path: [any CodingKey] = [Enigma.Pin.super, Enigma.Pin.int(index)]
        self.checkPath(child.codingPath, path)
        var single = child.singleValueContainer()
        assertEncodingError(keys: path) { try single.encode(Enigma.int(3)) }
      }
      try array.encode(Enigma.int(4))
    })
    XCTAssertEqual(tree, ["super": [1, 2, 4]])
  }

  func testSavedSuperEncoderContainerConflictFailsCompletionAtItsOwnPath() {
    for index in 0..<2 {
      let path: [Enigma.Pin] = [.super, .int(index)]
      assertEncodingError(path: path) {
        _ = try Enigma(encode: EncodingProbe { encoder in
          var root = encoder.container(keyedBy: Enigma.Pin.self)
          let parent = root.superEncoder()
          var array = parent.unkeyedContainer()
          let children = [array.superEncoder(), array.superEncoder()]
          for (offset, child) in children.enumerated() {
            var single = child.singleValueContainer()
            try single.encode(Enigma.int(offset + 1))
          }
          var incompatible = children[index].container(keyedBy: CurrentKey.self)
          assertEncodingError(path: path) { try incompatible.encode(3, forKey: .item) }
        })
      }
    }
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
