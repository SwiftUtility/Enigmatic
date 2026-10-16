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
    XCTAssertEqual(original.merging(patch, policy: .skip),
                   ["items": [["values": [1, 2]]], "settings": ["enabled": true, "new": true]])
    var merged = original
    merged.merge(patch, policy: .replace)
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

  func testDefaultMergePoliciesRecurseOnlyThroughDictionaries() {
    let original: Enigma = [
      "nested": ["conflict": 1, "keep": true], "array": [1, ["keep": 1]],
      "scalar": 1, "empty": [:], "null": nil,
    ]
    let incoming: Enigma = [
      "nested": ["conflict": 2, "added": []], "array": [2],
      "scalar": ["child": 3], "empty": ["created": nil], "null": false, "new": [],
    ]
    for replace in [false, true] {
      let expected: Enigma = [
        "nested": ["conflict": replace ? 2 : 1, "keep": true, "added": []],
        "array": replace ? [2] : [1, ["keep": 1]],
        "scalar": replace ? ["child": 3] : 1,
        "empty": ["created": nil], "null": replace ? false : nil, "new": [],
      ]
      var merged = original
      merged.merge(incoming, policy: replace ? .replace : .skip)
      XCTAssertEqual(merged, expected)
      XCTAssertEqual(original.merging(incoming, policy: replace ? .replace : .skip), expected)
    }
    XCTAssertEqual(original["nested"], ["conflict": 1, "keep": true])
    XCTAssertEqual(incoming["nested"], ["conflict": 2, "added": []])
  }

  func testRepeatedNonthrowingMergesPreserveOriginalIncomingAndResultCopies() {
    let original: Enigma = ["nested": ["value": 1, "keep": [1]], "items": [1]]
    let incoming: Enigma = ["nested": ["value": 2], "items": [2], "added": ["items": [3]]]
    let nestedCopy = original["nested"]
    for replace in [false, true] {
      var merged = original
      merged.merge(incoming, policy: replace ? .replace : .skip)
      let mergedCopy = merged

      for value in 3...10 {
        merged.merge(["nested": ["value": .int(value)]], policy: replace ? .replace : .skip)
      }
      merged["nested", "keep", 0] = 9
      merged["items", 0] = 9
      merged["added", "items", 0] = 9

      XCTAssertEqual(merged, [
        "nested": ["value": replace ? 10 : 1, "keep": [9]], "items": [9], "added": ["items": [9]],
      ])
      XCTAssertEqual(mergedCopy, [
        "nested": ["value": replace ? 2 : 1, "keep": [1]],
        "items": replace ? [2] : [1], "added": ["items": [3]],
      ])
      XCTAssertEqual(original, ["nested": ["value": 1, "keep": [1]], "items": [1]])
      XCTAssertEqual(nestedCopy, ["value": 1, "keep": [1]])
      XCTAssertEqual(incoming, ["nested": ["value": 2], "items": [2], "added": ["items": [3]]])
    }
  }

  func testNonthrowingMergeRootValuesAndSelfMerge() {
    let values: [Enigma] = [.null, false, 1, "text", [], [1, ["value": 2]], [:], ["nested": ["value": 1]]]
    for replace in [false, true] {
      for original in values {
        for incoming in values where !original.isDictionary || !incoming.isDictionary {
          let expected = replace ? incoming : original
          var merged = original
          merged.merge(incoming, policy: replace ? .replace : .skip)
          XCTAssertEqual(merged, expected)
          XCTAssertEqual(original.merging(incoming, policy: replace ? .replace : .skip), expected)
        }
        var merged = original
        merged.merge(merged, policy: replace ? .replace : .skip)
        XCTAssertEqual(merged, original)
      }
    }
  }

  func testArrayMergeActionsAndScalarSelectionAreIndependent() {
    let original: Enigma = ["items": [1, ["old": true]], "value": 1]
    let incoming: Enigma = ["items": [2, ["new": true], 3], "value": 2]
    for replace in [false, true] {
      let actions: [(Enigma.MergePolicy.ArrayAction, Enigma)] = [
        (.selectOriginal, [1, ["old": true]]),
        (.selectOther, [2, ["new": true], 3]),
        (.append, [1, ["old": true], 2, ["new": true], 3]),
        (.prepend, [2, ["new": true], 3, 1, ["old": true]]),
        (.zip, [replace ? 2 : 1, ["old": true, "new": true], 3]),
      ]
      for (action, items) in actions {
        var policy: Enigma.MergePolicy = .skip
        policy.replaceValue = replace
        policy.arrayAction = action
        let expected: Enigma = ["items": items, "value": replace ? 2 : 1]
        var merged = original
        merged.merge(incoming, policy: policy)
        XCTAssertEqual(merged, expected)
        XCTAssertEqual(original.merging(incoming, policy: policy), expected)
        merged["items", 0] = 99
        XCTAssertEqual(original, ["items": [1, ["old": true]], "value": 1])
        XCTAssertEqual(incoming, ["items": [2, ["new": true], 3], "value": 2])
      }
    }
  }

  func testZipMergesNestedArraysAndKeepsUnmatchedElements() {
    for replace in [false, true] {
      var policy: Enigma.MergePolicy = replace ? .replace : .skip
      policy.arrayAction = .zip
      let cases: [(Enigma, Enigma, Enigma)] = [
        ([], [], []), ([], [1], [1]), ([1], [], [1]),
        ([1], [2], replace ? [2] : [1]),
        ([[1, 2], ["old": 1]], [[3], ["new": 2], 4],
         [[replace ? 3 : 1, 2], ["old": 1, "new": 2], 4]),
        ([[1], ["old": 1], 4], [[2, 3], ["new": 2]],
         [[replace ? 2 : 1, 3], ["old": 1, "new": 2], 4]),
        ([1], ["key": 2], replace ? ["key": 2] : [1]),
      ]
      for (original, incoming, expected) in cases {
        var merged = original
        merged.merge(incoming, policy: policy)
        XCTAssertEqual(merged, expected)
        XCTAssertEqual(original.merging(incoming, policy: policy), expected)
      }
    }
  }

  func testThrowingMergesKeepArraysWholeAndPreserveInputsOnFailure() throws {
    enum Failure: Error { case conflict }
    let original: Enigma = ["items": [1, 2]]
    let incoming: Enigma = ["items": [3], "new": true]
    var merged = original
    assertEncodingError(path: ["items"]) { try merged.merge(incoming, skipEqual: true) }
    XCTAssertEqual(merged, original)
    assertEncodingError(path: ["items"]) { _ = try original.merging(incoming, skipEqual: true) }
    XCTAssertEqual(try original.merging(original, skipEqual: true), original)
    try merged.merge(original, skipEqual: true)
    XCTAssertEqual(merged, original)
    assertEncodingError(path: []) { try merged.merge(1, skipEqual: false) }
    XCTAssertEqual(merged, original)
    XCTAssertThrowsError(try original.merging(incoming, resolve: { path, old, new throws(Failure) in
      XCTAssertEqual(path, ["items"])
      XCTAssertEqual(old, [1, 2])
      XCTAssertEqual(new, [3])
      throw .conflict
    })) { XCTAssertEqual($0 as? Failure, .conflict) }
    XCTAssertEqual(original, ["items": [1, 2]])
    XCTAssertEqual(incoming, ["items": [3], "new": true])
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
    tree.merge(["parent": ["value": 2], "new": true], resolve: { path, lhs, rhs in
      XCTAssertEqual(path, ["parent", "value"])
      return .int(lhs.asInt! + rhs.asInt!)
    })
    XCTAssertEqual(tree, ["parent": ["value": 3], "array": [1], "new": true])
    XCTAssertEqual(initial, ["parent": ["value": 1], "array": [1]])
    XCTAssertThrowsError(try tree.merge(["parent": ["value": 2]], skipEqual: false)) { error in
      guard case EncodingError.invalidValue(_, let context) = error else { return XCTFail("\(error)") }
      XCTAssertEqual(context.codingPath.map(Enigma.Pin.init), ["parent", "value"])
    }
  }

  func testPinCodingKeyAndHashing() {
    let integer: Enigma.Pin = 42
    let universal: Enigma.Pin = "42"
    let string: Enigma.Pin = "s"
    XCTAssertTrue(integer.isInt)
    XCTAssertFalse(universal.isInt)
    XCTAssertFalse(string.isInt)
    XCTAssertEqual(integer.intValue, 42)
    XCTAssertEqual(universal.intValue, 42)
    XCTAssertNil(string.intValue)
    XCTAssertEqual(integer.stringValue, "42")
    XCTAssertEqual(universal.stringValue, "42")
    XCTAssertEqual(string.stringValue, "s")
    XCTAssertEqual(integer.description, "42")
    XCTAssertEqual(universal.description, "42")
    XCTAssertEqual(string.description, "s")
    XCTAssertEqual(Enigma.Pin.str("outer").description, "outer")
    XCTAssertEqual(integer, universal)
    XCTAssertEqual(Set([integer, string, universal]).count, 2)
    XCTAssertEqual(Enigma.Pin(intValue: 42), integer)
    XCTAssertEqual(Enigma.Pin(stringValue: "42"), universal)
    XCTAssertEqual(Enigma.Pin(stringValue: "s"), string)
  }

  func testNumericPinsCompareByCanonicalSpellingButKeepTheirPathKind() {
    for value in [Int.min, -1, 0, 1, Int.max] {
      let integer = Enigma.Pin.int(value)
      let string = Enigma.Pin.str(String(value))
      XCTAssertEqual(integer, string)
      XCTAssertEqual(string, integer)
      XCTAssertEqual([integer: "found"][string], "found")
      XCTAssertTrue(integer.isInt)
      XCTAssertFalse(string.isInt)
    }
    for spelling in ["01", "+1", "-0"] {
      let pin = Enigma.Pin.str(spelling)
      XCTAssertNotNil(pin.intValue)
      XCTAssertNotEqual(pin, .int(pin.intValue!))
    }
    XCTAssertNil(Enigma.Pin.str("99999999999999999999").intValue)
    XCTAssertEqual(Enigma.Pin.int(1).debugDescription, "Pin.int(1)")
    XCTAssertEqual(Enigma.Pin.str("1").debugDescription, "Pin.str(\"1\")")
    let dictionary: Enigma = ["1": "key"]
    let array: Enigma = ["index", "one"]
    XCTAssertEqual(dictionary["1"], "key")
    XCTAssertNil(dictionary[1])
    XCTAssertEqual(array[1], "one")
    XCTAssertNil(array["1"])
  }

  @available(macOS 12.3, iOS 15.4, watchOS 8.5, tvOS 15.4, *)
  func testPinCodingKeyRepresentableUsesTheIntegerRepresentationWhenPresent() {
    XCTAssertEqual(Enigma.Pin(codingKey: Enigma.Pin.str("01")), .int(1))
    XCTAssertEqual(Enigma.Pin(codingKey: Enigma.Pin.str("key")), .str("key"))
    XCTAssertEqual(Enigma.Pin.int(-2).codingKey.stringValue, "-2")
    XCTAssertEqual(Enigma.Pin.str("key").codingKey.stringValue, "key")
  }
}
