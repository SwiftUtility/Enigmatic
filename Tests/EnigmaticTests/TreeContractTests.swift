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
    tree["items", "wrong"] = 4
    tree["items", 0, "wrong"] = 4
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

  func testNoncopyableMergeStrategyPreservesDecimalEqualityAndAtomicity() throws {
    struct EqualStrategy: ~Copyable, Enigma.MergeStrategy {
      var paths: [[Enigma.Pin]] = []

      mutating func resolve(
        ctx: inout Enigma.MergeContext, old: Enigma, new: Enigma
      ) -> Result<Enigma, EncodingError> {
        paths.append(ctx.pins)
        return old == new ? .success(old) : .failure(ctx.error(new))
      }
    }

    var tree: Enigma = ["parent": ["value": .double(0.1)]]
    var strategy = EqualStrategy()
    try tree.merge(["parent": ["value": .float(0.1)]], strategy: &strategy)
    XCTAssertEqual(strategy.paths, [["parent", "value"]])
    guard case .double(let value) = tree["parent", "value"] else {
      return XCTFail("Equal merge must retain the original numeric representation")
    }
    XCTAssertEqual(value.bitPattern, Double(0.1).bitPattern)

    let initial = tree
    XCTAssertThrowsError(try tree.merge([
      "parent": ["value": .double(Double(Float(0.1)))], "new": true,
    ], strategy: &strategy)) { error in
      guard case EncodingError.invalidValue(_, let context) = error else { return XCTFail("\(error)") }
      XCTAssertEqual(context.codingPath.map(Enigma.Pin.init), ["parent", "value"])
    }
    XCTAssertEqual(tree, initial)
    XCTAssertEqual(strategy.paths, [["parent", "value"], ["parent", "value"]])
    XCTAssertEqual(try initial.merging(initial, strategy: EqualStrategy()), initial)
  }

  func testMergeSelectionKeepsWholeArraysAndAddsDisjointDictionaryKeys() {
    let original: Enigma = ["parent": ["value": .double(0.1)], "items": [1]]
    let patch: Enigma = ["parent": ["value": .float(0.1), "added": true], "items": [2, 3]]
    let kept = original.merging(patch, replace: false)
    let replaced = original.merging(patch, replace: true)
    XCTAssertEqual(kept["items"], [1])
    XCTAssertEqual(replaced["items"], [2, 3])
    XCTAssertEqual(kept["parent", "added"], true)
    XCTAssertEqual(replaced["parent", "added"], true)
    guard case .double = kept["parent", "value"], case .float = replaced["parent", "value"] else {
      return XCTFail("Selection must preserve the chosen numeric representation")
    }
    var mutated = original
    mutated.merge(patch, replace: false)
    XCTAssertEqual(mutated, kept)
    mutated.merge(patch, replace: true)
    XCTAssertEqual(mutated, replaced)
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
