import Foundation
import XCTest
@testable import Enigmatic

final class TreeContractTests: XCTestCase {
  func testPathsAreDeterministicAndIncludeEmptyContainers() {
    let tree: Enigma = ["z": [], "a": [1, ["b": nil, "a": [:]]]]
    XCTAssertEqual(tree.allPaths, [["a"], ["a", 0], ["a", 1], ["a", 1, "a"], ["a", 1, "b"], ["z"]])
    XCTAssertTrue(Enigma.null.allPaths.isEmpty)
    XCTAssertTrue(Enigma.array([]).allPaths.isEmpty)
    XCTAssertTrue(Enigma.dictionary([:]).allPaths.isEmpty)
    for path in tree.allPaths { XCTAssertNotNil(tree[path]) }
  }

  func testRootMutationInvalidIndicesAndFallbackLaziness() {
    var tree: Enigma = ["items": [1, 2], "null": nil]
    var calls = 0
    func fallback() -> Enigma { calls += 1; return 9 }
    XCTAssertEqual(tree["items", 0, or: fallback()], 1)
    XCTAssertEqual(tree["null", or: fallback()], .null)
    XCTAssertEqual(calls, 0)
    XCTAssertEqual(tree["missing", or: fallback()], 9)
    XCTAssertEqual(calls, 1)
    tree["missing", or: fallback()] = 3
    XCTAssertEqual(calls, 1)
    let snapshot = tree
    tree["items", -1] = 4
    tree["items", 4] = 4
    tree["missing", 0] = nil
    tree["items", 99] = nil
    XCTAssertEqual(tree, snapshot)
    XCTAssertNil(tree["items", -1])
    XCTAssertNil(tree["items", "wrong"])
    XCTAssertNil(tree["absent"])
    tree["items", 0] = nil
    XCTAssertEqual(tree["items"], [2])
    tree["null"] = nil
    XCTAssertNil(tree["null"])
    tree[[]] = nil
    XCTAssertNotNil(tree[[]])
    tree[[]] = ["new": []]
    tree["new", 0, "value"] = true
    XCTAssertEqual(tree, ["new": [["value": true]]])
    tree["new", 0, "value"] = nil
    XCTAssertEqual(tree, ["new": [[:]]])
  }

  func testPathWritesReplaceIncompatibleContainers() {
    var tree: Enigma = 7
    tree["value"] = 1
    XCTAssertEqual(tree, ["value": 1])

    tree["value", 0] = 2
    XCTAssertEqual(tree, ["value": [2]])

    tree["value", 0, "child"] = 3
    XCTAssertEqual(tree, ["value": [["child": 3]]])

    tree["value", "named"] = 4
    XCTAssertEqual(tree, ["value": ["named": 4]])

    tree["value", "named", 0] = 5
    XCTAssertEqual(tree, ["value": ["named": [5]]])

    tree["value", "named", 0, "leaf"] = true
    XCTAssertEqual(tree, ["value": ["named": [["leaf": true]]]])
  }

  func testInvalidIndexMakesNestedWriteAnAtomicNoOp() {
    var tree: Enigma = ["outer": ["items": [1]], "keep": true]
    let snapshot = tree

    tree["outer", "items", -1] = 2
    XCTAssertEqual(tree, snapshot)

    tree["outer", "items", 2] = 2
    XCTAssertEqual(tree, snapshot)

    // The path would replace `items` with a dictionary and then an array, but
    // the final out-of-range index must leave the original tree unchanged.
    tree["outer", "items", "replace", 3] = 2
    XCTAssertEqual(tree, snapshot)

    let cases: [(Enigma, [Enigma.Pin])] = [
      ([1], [0, "new", 2]),                 // Replace an existing array element.
      ([1], [1, 0, 1]),                     // Append through two new arrays.
      (["keep": true], ["missing", "child", 1]),
      (7, ["missing", "child", 1]),         // Replace the root before failing.
    ]
    for (original, path) in cases {
      var candidate = original
      candidate[path] = true
      XCTAssertEqual(candidate, original, "Invalid write at \(path)")
      candidate[path] = nil
      XCTAssertEqual(candidate, original, "Missing deletion at \(path)")
    }

    tree["outer", "items", 1] = 2
    XCTAssertEqual(tree, ["outer": ["items": [1, 2]], "keep": true])
  }

  func testNestedEditsAndMergesDoNotMutateCopies() {
    let original: Enigma = ["items": [["values": [1, 2]]], "settings": ["enabled": true]]
    var edited = original
    edited["items", 0, "values", or: []].array.append(3)
    edited["items", 0, "values", 0] = nil
    edited["settings", "enabled"] = false
    XCTAssertEqual(edited, ["items": [["values": [2, 3]]], "settings": ["enabled": false]])

    let patch: Enigma = ["items": [], "settings": ["enabled": false, "new": true]]
    XCTAssertEqual(original.merging(patch, replace: false),
                   ["items": [["values": [1, 2]]], "settings": ["enabled": true, "new": true]])
    var merged = original
    merged.merge(patch, replace: true)
    XCTAssertEqual(merged, patch)
    XCTAssertEqual(original, ["items": [["values": [1, 2]]], "settings": ["enabled": true]])
  }

  func testFallbackWritebackEvaluatesOnlyMissingValues() {
    var tree: Enigma = ["items": [1], "null": nil]
    var calls = 0
    func fallback() -> Enigma { calls += 1; return [9] }
    tree["items", or: fallback()].array.append(2)
    tree["null", or: fallback()].dictionary["created"] = true
    XCTAssertEqual(calls, 0)
    let path: [Enigma.Pin] = ["missing"]
    tree[path, or: fallback()].array.append(10)
    XCTAssertEqual(calls, 1)
    XCTAssertEqual(tree, ["items": [1, 2], "null": ["created": true], "missing": [9, 10]])
  }

  func testMergeRollsBackAfterResolvingAnEarlierConflict() {
    enum Failure: Error { case conflict }
    var tree: Enigma = ["a": 1, "nested": ["b": 2], "keep": true]
    var calls = 0
    XCTAssertThrowsError(try tree.merge(["a": 10, "nested": ["b": 20], "new": false], resolve: {
      _, _, rhs throws(Failure) in
      calls += 1
      if calls == 2 { throw Failure.conflict }
      return rhs
    })) { error in
      XCTAssertTrue(error is Failure)
    }
    // The resolver must have made progress before throwing, regardless of key order.
    XCTAssertEqual(calls, 2)
    XCTAssertEqual(tree, ["a": 1, "nested": ["b": 2], "keep": true])
  }

  func testMergeConflictPathsAndAtomicity() throws {
    enum Failure: Error { case conflict }
    var tree: Enigma = ["parent": ["value": 1], "array": [1]]
    let initial = tree
    XCTAssertThrowsError(try tree.merge(["parent": ["value": 2]], resolve: { path, lhs, rhs throws(Failure) in
      XCTAssertEqual(path, ["parent", "value"])
      XCTAssertEqual(lhs, 1)
      XCTAssertEqual(rhs, 2)
      throw Failure.conflict
    }))
    XCTAssertEqual(tree, initial)
    var paths: [[Enigma.Pin]] = []
    let merged = tree.merging(["array": [2, 3], "new": true], resolve: { path, _, rhs in
      paths.append(path)
      return rhs
    })
    XCTAssertEqual(paths, [["array"]])
    XCTAssertEqual(merged, ["parent": ["value": 1], "array": [2, 3], "new": true])
    XCTAssertEqual(tree, initial)
    XCTAssertThrowsError(try tree.merge(["parent": ["value": 2]], skipEqual: false)) { error in
      guard case EncodingError.invalidValue(_, let context) = error else { return XCTFail("\(error)") }
      XCTAssertEqual(context.codingPath.map(Enigma.Pin.init), ["parent", "value"])
    }
  }

  func testPinCodingKeyAndHashing() {
    let integer: Enigma.Pin = 2
    let string: Enigma.Pin = "2"
    XCTAssertTrue(integer.isInt)
    XCTAssertFalse(string.isInt)
    XCTAssertEqual(integer.intValue, 2)
    XCTAssertNil(string.intValue)
    XCTAssertEqual(integer.stringValue, "2")
    XCTAssertEqual(string.stringValue, "2")
    XCTAssertNotEqual(integer, string)
    XCTAssertEqual(Set([integer, string, integer]).count, 2)
    XCTAssertEqual(Enigma.Pin(intValue: 2), integer)
    XCTAssertEqual(Enigma.Pin(stringValue: "2"), string)
  }
}
