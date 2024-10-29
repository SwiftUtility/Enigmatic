@testable import Enigmatic
import Foundation
import XCTest

final class EnigmaHashableTests: XCTestCase {
  func checkFloat(_ float: Float) {
    if let double = Double(exactly: float) {
      checkEq(.float(float), .double(double))
      checkEq(.float(float), .double(Double(float)))
      XCTAssertEqual(Double(float), double)
    } else {
      checkDif(.float(float), .double(Double(float)))
    }
  }

  func checkEq(_ one: Enigma, _ two: Enigma) {
    XCTAssertEqual(one, two)
    XCTAssertEqual(one.hashValue, two.hashValue)
  }

  func checkDif(_ one: Enigma, _ two: Enigma) {
    XCTAssertNotEqual(one, two)
    XCTAssertNotEqual(one.hashValue, two.hashValue)
  }

  func checkMiscoded<T: Codable & Equatable>(_ sample: T) throws {
    let encoded = try Enigma(encode: sample)
    let decoded = try encoded.decode() as T
    XCTAssertNotEqual(sample, decoded)
  }

  func testEmpty() throws {
    checkEq(.array([]), .dictionary([:]))
    checkEq(.dictionary([:]), .array([]))
  }

  func testZero() throws {
    checkEq(.int(0), .int8(0))
    checkEq(.int(0), .int16(0))
    checkEq(.int(0), .int32(0))
    checkEq(.int(0), .int64(0))
    checkEq(.int(0), .uint(0))
    checkEq(.int(0), .uint8(0))
    checkEq(.int(0), .uint16(0))
    checkEq(.int(0), .uint32(0))
    checkEq(.int(0), .uint64(0))
    checkEq(.int(0), .double(0))
    checkEq(.int(0), .float(0))
  }

  func testOne() throws {
    checkEq(.int(1), .int8(1))
    checkEq(.int(1), .int16(1))
    checkEq(.int(1), .int32(1))
    checkEq(.int(1), .int64(1))
    checkEq(.int(1), .uint(1))
    checkEq(.int(1), .uint8(1))
    checkEq(.int(1), .uint16(1))
    checkEq(.int(1), .uint32(1))
    checkEq(.int(1), .uint64(1))
    checkEq(.int(1), .double(1))
    checkEq(.int(1), .float(1))
    checkEq(.int(1), .float(1.00000001))
  }

  func testBig() throws {
    checkDif(.int(Int.max), .int(Int.max - 1))
    checkDif(.int(Int.min), .int(Int.min + 1))
    checkDif(.uint(UInt.max), .uint(UInt.max - 1))
  }

  func testFraction() throws {
    checkFloat(0.1)
    checkFloat(0.5)
    checkFloat(.greatestFiniteMagnitude)
    checkEq(.float(0.5), .double(0.5))
    checkEq(.float(.greatestFiniteMagnitude), .double(Double(Float.greatestFiniteMagnitude)))
    XCTAssertNotEqual(Double.nan, Double.nan)
    XCTAssertNotEqual(Enigma.double(Double.nan), Enigma.double(Double.nan))
    XCTAssertNotEqual(Float.nan, Float.nan)
    XCTAssertNotEqual(Enigma.float(Float.nan), Enigma.float(Float.nan))
  }

  func testNils() throws {
    try checkMiscoded([nil: "1", .some(nil): "2"] as [Int??: String])
    try checkMiscoded([nil: "1", .null: "2"] as [Enigma?: String])
  }

  func testNotEqual() throws {
    XCTAssertNotEqual(0.1 as Double, Double(0.1 as Float))
    XCTAssertNotEqual(Enigma.double(0.1), Enigma.float(0.1))
  }
}
