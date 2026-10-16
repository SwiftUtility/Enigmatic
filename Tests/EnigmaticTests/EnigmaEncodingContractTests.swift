import Foundation
import XCTest
@testable import Enigmatic

final class EnigmaEncodingContractTests: XCTestCase {
  private typealias Key = Enigma.Pin

  // Exercise both Encodable delegation and the generic single-value fast path.
  private struct SingleEncoded: Encodable {
    let value: Enigma
    func encode(to encoder: any Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(value)
    }
  }

  private enum SingleStrategy: Codec.EncodeStrategy {
    typealias BoxedValue = Enigma
    static func encode(value: Enigma, encoder: some Encoder) throws {
      try SingleEncoded(value: value).encode(to: encoder)
    }
  }

  private func write(_ value: Enigma, to encoder: any Encoder, generic: Bool) throws {
    if generic {
      try SingleEncoded(value: value).encode(to: encoder)
    } else {
      try value.encode(to: encoder)
    }
  }

  private func assertConflict(
    path: [Key], file: StaticString = #filePath, line: UInt = #line,
    _ operation: () throws -> Void
  ) {
    XCTAssertThrowsError(try operation(), file: file, line: line) { error in
      guard case EncodingError.invalidValue(_, let context) = error else {
        return XCTFail("Unexpected error: \(error)", file: file, line: line)
      }
      XCTAssertEqual(context.codingPath.map(\.stringValue), path.map(\.stringValue), file: file, line: line)
      XCTAssertEqual(context.codingPath.map(\.intValue), path.map(\.intValue), file: file, line: line)
    }
  }

  func testCaughtDuplicateNativeDataAllowsCompletion() throws {
    for data in [Data(), Data([1])] {
      let tree = try Enigma(encode: EncodingProbe { encoder in
        var root = encoder.container(keyedBy: Key.self)
        var child = root.nestedContainer(keyedBy: Key.self, forKey: "outer")
        try child.encode(1, forKey: "data")
        self.assertConflict(path: ["outer", "data"]) {
          try child.encode(data, forKey: "data")
        }
        try child.encode(2, forKey: "after")
      })
      XCTAssertEqual(tree, ["outer": ["data": 1, "after": 2]])
    }
  }

  func testCaughtEnigmaConflictsAllowFurtherWrites() throws {
    let pairs: [(Enigma, Enigma, [Key])] = [
      (.int(1), .int(2), []),
      (.null, .null, []),
      (.data(Data()), .data(Data([1])), []),
      (.date(Date(timeIntervalSince1970: 0)), .date(Date(timeIntervalSince1970: 1)), []),
      (.array([]), .array([]), []),
      (.array([1]), .array([2]), []),
      (.int(1), ["x": 2], []),
      (.array([1]), ["x": 2], []),
      (["x": 1], .int(2), []),
      (["x": 1], .array([]), []),
      (["a": ["x": 1]], ["a": ["y": 2]], ["a"]),
      (["a": [:]], ["a": [:]], ["a"]),
    ]
    for (first, second, path) in pairs {
      let tree = try Enigma(encode: EncodingProbe { encoder in
        var root = encoder.container(keyedBy: Key.self)
        let child = root.superEncoder(forKey: "outer")
        try self.write(first, to: child, generic: true)
        self.assertConflict(path: ["outer"] + path) {
          try self.write(second, to: child, generic: true)
        }
        try root.encode(Enigma.int(3), forKey: "after")
      })
      XCTAssertEqual(tree, .dictionary(["outer": first, "after": 3]))
    }
  }

  func testCaughtKeyedEnigmaOverwriteAllowsFurtherWrites() throws {
    let values: [Enigma] = [.int(2), .null, .array([]), .dictionary([:]), .data(Data()), .date(Date(timeIntervalSince1970: 0))]
    for value in values {
      let tree = try Enigma(encode: EncodingProbe { encoder in
        var root = encoder.container(keyedBy: Key.self)
        try root.encode(Enigma.int(1), forKey: "value")
        self.assertConflict(path: ["value"]) { try root.encode(value, forKey: "value") }
        try root.encode(Enigma.int(3), forKey: "after")
      })
      XCTAssertEqual(tree, ["value": 1, "after": 3])
    }
  }

  func testDelegatedEnigmaContainerConflictsStillFailCompletion() {
    let pairs: [(Enigma, Enigma, [Key], Bool)] = [
      (.array([]), .array([]), [], false),
      (.array([1]), ["x": 2], [], true),
      (.int(1), ["x": 2], [], true),
      (["a": [:]], ["a": [:]], ["a"], false),
    ]
    for (first, second, path, writes) in pairs {
      assertConflict(path: path) {
        _ = try Enigma(encode: EncodingProbe { encoder in
          try self.write(first, to: encoder, generic: false)
          // Acquiring a conflicting container is fatal even without a write.
          if writes {
            self.assertConflict(path: path) { try self.write(second, to: encoder, generic: false) }
          } else {
            try self.write(second, to: encoder, generic: false)
          }
        })
      }
    }
  }

  @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
  private func product(_ first: Enigma, _ second: Enigma, generic: Bool) -> any Encodable {
    if generic {
      Codec.Each(SingleEncoded(value: first), SingleEncoded(value: second))
    } else {
      Codec.Each(first, second)
    }
  }

  @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
  func testEachCombinesDisjointEnigmaKeysAndRetainsNativeCases() throws {
    let date = Enigma.date(Date(timeIntervalSinceReferenceDate: 1.25))
    let data = Enigma.data(Data([0, 255]))
    let first: Enigma = ["a": [date, data]]
    let second: Enigma = ["b": ["date": date, "data": data]]
    let expected: Enigma = ["a": [date, data], "b": ["date": date, "data": data]]
    for generic in [false, true] {
      XCTAssertEqual(try Enigma(encode: product(first, second, generic: generic)), expected)
      XCTAssertEqual(try Enigma(encode: product(second, first, generic: generic)), expected)
    }
  }

  @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
  func testEachAllowsRepeatedKeyedConversionAtNestedArrayPosition() throws {
    for generic in [false, true] {
      let tree = try Enigma(encode: EncodingProbe { encoder in
        var root = encoder.container(keyedBy: Key.self)
        var array = root.nestedUnkeyedContainer(forKey: "outer")
        try array.encode(self.product(["a": 1], ["b": 2], generic: generic))
      })
      XCTAssertEqual(tree, ["outer": [["a": 1, "b": 2]]])
    }
  }

  @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
  func testEachRejectsEqualAndUnequalScalarWrites() {
    let pairs: [(Enigma, Enigma)] = [
      (.int(1), .int(1)), (.int(1), .int(2)), (.null, .null),
      (.data(Data()), .data(Data())),
      (.date(Date(timeIntervalSinceReferenceDate: 0)), .date(Date(timeIntervalSinceReferenceDate: 0))),
    ]
    for generic in [false, true] {
      for (first, second) in pairs {
        assertConflict(path: []) { _ = try Enigma(encode: product(first, second, generic: generic)) }
      }
    }
  }

  @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
  func testEachRejectsOverlappingKeysWithoutRecursivelyMergingThem() throws {
    let pairs: [(Enigma, Enigma, [Key])] = [
      (["a": 1], ["a": 1], ["a"]),
      (["a": 1], ["a": 2], ["a"]),
      (["a": ["x": 1]], ["a": ["y": 2]], ["a"]),
      (["a": [1]], ["a": [2]], ["a"]),
    ]
    for generic in [false, true] {
      for (first, second, path) in pairs {
        // Delegated nested collections acquire an occupied container and are fatal.
        // Delegated scalar writes throw directly and can be caught.
        let recoverable = generic || (first["a"]?.asArray == nil && first["a"]?.asDictionary == nil)
        let operation = {
          try Enigma(encode: EncodingProbe { encoder in
            var root = encoder.container(keyedBy: Key.self)
            let child = root.superEncoder(forKey: "outer")
            self.assertConflict(path: ["outer"] + path) {
              try self.product(first, second, generic: generic).encode(to: child)
            }
            if recoverable {
              try root.encode(Enigma.int(3), forKey: "after")
            }
          })
        }
        if recoverable {
          XCTAssertEqual(try operation(), .dictionary(["outer": first, "after": 3]))
        } else {
          self.assertConflict(path: ["outer"] + path) { _ = try operation() }
        }
      }
    }
  }

  @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
  func testEachRejectsRepeatedArraysAndOverlappingEmptyChildren() throws {
    for generic in [false, true] {
      for first in [Enigma.array([]), .array([1])] {
        for second in [Enigma.array([]), .array([2])] {
          assertConflict(path: []) { _ = try Enigma(encode: product(first, second, generic: generic)) }
        }
      }
      // Reusing keyed storage is valid when no key is overwritten.
      XCTAssertEqual(try Enigma(encode: product(["a": 1], [:], generic: generic)), ["a": 1])
      XCTAssertEqual(try Enigma(encode: product([:], ["a": 1], generic: generic)), ["a": 1])
      assertConflict(path: ["a"]) {
        _ = try Enigma(encode: product(["a": [:]], ["a": [:]], generic: generic))
      }
    }
  }

  @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
  func testEachRejectsIncompatibleContainerKindsAtTheContainerPath() {
    let pairs: [(Enigma, Enigma, [Key])] = [
      (.int(1), ["x": 2], []),
      (["x": 1], .int(2), []),
      (.array([1]), ["x": 2], []),
      (["x": 1], .array([2]), []),
      (.int(1), .array([2]), []),
      (.array([1]), .int(2), []),
    ]
    for generic in [false, true] {
      for (first, second, path) in pairs {
        assertConflict(path: path) {
          _ = try Enigma(encode: product(first, second, generic: generic))
        }
      }
    }
  }

  @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
  func testEachWithModelAndEnigmaKeepsDisjointKeysInEitherOrder() throws {
    struct Model: Encodable { let model: Int }
    let value: Enigma = ["tree": ["nested": 2]]
    let expected: Enigma = ["model": 1, "tree": ["nested": 2]]
    XCTAssertEqual(try Enigma(encode: Codec.Each(Model(model: 1), value)), expected)
    XCTAssertEqual(try Enigma(encode: Codec.Each(value, Model(model: 1))), expected)
    XCTAssertEqual(try Enigma(encode: Codec.Each(Model(model: 1), SingleEncoded(value: value))), expected)
    XCTAssertEqual(try Enigma(encode: Codec.Each(SingleEncoded(value: value), Model(model: 1))), expected)
  }

  @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
  func testEachStrategyEnigmaWritesUseTheSameConflictContract() throws {
    typealias Strategy = Codec.Each<SingleStrategy, SingleStrategy>
    let value = Codec.Box<Strategy>(wrappedValue: (["a": 1], ["b": 2]))
    XCTAssertEqual(try Enigma(encode: value), ["a": 1, "b": 2])
    let conflict = Codec.Box<Strategy>(wrappedValue: (["a": ["x": 1]], ["a": ["y": 2]]))
    assertConflict(path: ["a"]) { _ = try Enigma(encode: conflict) }
    let empty = Codec.Box<Strategy>(wrappedValue: (["a": [:]], ["a": [:]]))
    assertConflict(path: ["a"]) { _ = try Enigma(encode: empty) }
  }
}
