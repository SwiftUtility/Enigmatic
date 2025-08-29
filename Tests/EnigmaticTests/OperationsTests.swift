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
    XCTAssertThrowsError(try enigma.merging(encode: a, or: Enigma.fail))
    XCTAssertNoThrow(try enigma.merging(encode: a, or: Enigma.skipEqual))
    XCTAssertNoThrow(try enigma.merging(encode: a, or: Enigma.replace))
    a.int1 += 1
    XCTAssertThrowsError(try enigma.merging(encode: a, or: Enigma.fail))
    XCTAssertThrowsError(try enigma.merging(encode: a, or: Enigma.skipEqual))
    XCTAssertNoThrow(try enigma.merge(encode: a, or: Enigma.replace))
    let b = B()
    XCTAssertNoThrow(try enigma.merging(encode: b, or: Enigma.skipEqual))
    XCTAssertNoThrow(try enigma.merging(encode: b, or: Enigma.replace))
    XCTAssertNoThrow(try enigma.merge(encode: b, or: Enigma.fail))
    XCTAssertEqual(try enigma.decode(), b)
    XCTAssertEqual(try enigma.decode(), a)
  }

  func testPinSubscript() throws {
    var enigma = try Enigma(encode: [1])
    enigma[[.head]] = 0
    XCTAssertEqual(enigma, [0, 1])
    enigma[[.tail]] = 2
    XCTAssertEqual(enigma, [0, 1, 2])
    enigma[[1]] = nil
    XCTAssertEqual(enigma, [0, 2])
    enigma[["a"]] = true
    enigma[["b"]] = false
    XCTAssertEqual(enigma, ["a": true, "b": false])
    enigma[["b", 0, "c"]] = false
    XCTAssertEqual(enigma, ["a": true, "b": [["c": false]]])
    enigma[["b", 0]] = nil
    XCTAssertEqual(enigma, ["a": true, "b": []])
  }
}
