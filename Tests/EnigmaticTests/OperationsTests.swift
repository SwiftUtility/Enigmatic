@testable import Enigmatic
import Foundation
import XCTest

final class OperationsTests: XCTestCase {
  func check<T: Codable & Equatable>(value: T, enigma: Enigma) throws {
    let decoded = try enigma.decode() as T
    XCTAssertEqual(value, decoded)
  }

  func testMerge() throws {
    var a = A()
    var enigma = try Enigma(encode: a)
    XCTAssertEqual(try enigma.decode(), a)
    let same = try Enigma(encode: a)
    XCTAssertThrowsError(try enigma.merging(same, skipEqual: false))
    XCTAssertNoThrow(try enigma.merging(same, skipEqual: true))
    XCTAssertNoThrow(enigma.merging(same, replace: true))
    a.int1 += 1
    let changed = try Enigma(encode: a)
    XCTAssertThrowsError(try enigma.merging(changed, skipEqual: false))
    XCTAssertThrowsError(try enigma.merging(changed, skipEqual: true))
    XCTAssertNoThrow(enigma.merge(changed, replace: true))
    let b = B()
    let other = try Enigma(encode: b)
    XCTAssertNoThrow(try enigma.merging(other, skipEqual: true))
    XCTAssertNoThrow(enigma.merging(other, replace: true))
    XCTAssertNoThrow(try enigma.merge(other, skipEqual: false))
    XCTAssertEqual(try enigma.decode(), b)
    XCTAssertEqual(try enigma.decode(), a)
  }

  func testPinsSubscript() throws {
    var enigma = [0] as Enigma
    enigma[1] = 1
    XCTAssertEqual(enigma, [0, 1])
    enigma[2] = 2
    XCTAssertEqual(enigma, [0, 1, 2])
    enigma[1] = nil
    XCTAssertEqual(enigma, [0, 2])
    enigma[-1] = 1
    XCTAssertEqual(enigma, [0, 2])
    enigma[1] = 1
    XCTAssertEqual(enigma, [0, 1])
    enigma[2] = ["a": true, "b": [[:]]]
    XCTAssertEqual(enigma, [0, 1, ["a": true, "b": [[:]]]])
    enigma[2, "b", 1, "c"] = false
    XCTAssertEqual(enigma, [0, 1, ["a": true, "b": [[:], ["c": false]]]])
    enigma[2, "b", 0, "c"] = true
    XCTAssertEqual(enigma, [0, 1, ["a": true, "b": [["c": true], ["c": false]]]])
    XCTAssertEqual(enigma[2, "b", 0, "c"], true)
    XCTAssertEqual(enigma[2, "b", 1], ["c": false])
    enigma[2, "b", 2, "c", or: []].array.append(2)
    XCTAssertEqual(enigma[2, "b", 2, "c"], [2])
  }

  func testIntPinArraySubscript() throws {
    var enigma = [0] as Enigma
    enigma[[1]] = 1
    XCTAssertEqual(enigma, [0, 1])
    enigma[[2]] = 2
    XCTAssertEqual(enigma, [0, 1, 2])
    enigma[[1]] = nil
    XCTAssertEqual(enigma, [0, 2])
    enigma[[1]] = 1
    XCTAssertEqual(enigma, [0, 1])
    enigma[[2]] = ["a": true, "b": [[:]]]
    XCTAssertEqual(enigma, [0, 1, ["a": true, "b": [[:]]]])
    enigma[[2, "b", 1, "c"]] = false
    XCTAssertEqual(enigma, [0, 1, ["a": true, "b": [[:], ["c": false]]]])
    enigma[[2, "b", 0, "c"]] = true
    XCTAssertEqual(enigma, [0, 1, ["a": true, "b": [["c": true], ["c": false]]]])
    XCTAssertEqual(enigma[[2, "b", 0, "c"]], true)
    XCTAssertEqual(enigma[[2, "b", 1]], ["c": false])
    enigma[[2, "b", 2, "c"], or: []].array.append(2)
    XCTAssertEqual(enigma[2, "b", 2, "c"], [2])
  }
}
