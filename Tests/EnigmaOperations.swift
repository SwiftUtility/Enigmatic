@testable import Enigmatic
import Foundation
import XCTest

final class EnigmaOperations: XCTestCase {
  func check<T: Codable & Equatable>(value: T, enigma: Enigma) throws {
    let decoded = try enigma.decode() as T
    XCTAssertEqual(value, decoded)
  }

  func testEncode() throws {
    var a = A()
    var enigma = try Enigma(encode: a)
    XCTAssertEqual(enigma[A.self], a)
    XCTAssertNoThrow(try enigma.encode(a))
    let b = B()
    XCTAssertNoThrow(try enigma.encode(b))
    XCTAssertEqual(enigma[B.self], b)
    a.int1 += 1
    XCTAssertThrowsError(try enigma.encode(a))
  }

  func testMerge() throws {
    var a = A()
    let b = B()
    var enigma = try Enigma(encode: a)
    XCTAssertEqual(enigma[A.self], a)
    XCTAssertNoThrow(try enigma.encode(a))
    XCTAssertNoThrow(try enigma.encode(b))
    XCTAssertEqual(enigma[B.self], b)
    a.int1 += 1
    XCTAssertNotEqual(enigma[A.self], a)
    XCTAssertNoThrow(try enigma.merge(a))
    XCTAssertEqual(enigma[A.self], a)
  }

  func testArray() throws {
    var enigma = try Enigma(encode: [1])
    XCTAssertEqual(enigma[[Int].self], [1])
    XCTAssertEqual(enigma[0], .int(1))
    XCTAssertNoThrow(try enigma.encode([1]))
    XCTAssertEqual(enigma[[Int].self], [1])
    XCTAssertThrowsError(try enigma.encode([2]))
    XCTAssertEqual(enigma[[Int].self], [1])
    XCTAssertNoThrow(try enigma.merge([2]))
    XCTAssertEqual(enigma[[Int].self], [2])
    XCTAssertEqual(enigma, [2])
    XCTAssertEqual(enigma[0]?[Int.self], 2)
    XCTAssertEqual(enigma[0], 2)
    enigma[0]?[Int.self] = 3
    XCTAssertEqual(enigma[[Int].self], [3])
    XCTAssertEqual(enigma, [3])
  }
}
