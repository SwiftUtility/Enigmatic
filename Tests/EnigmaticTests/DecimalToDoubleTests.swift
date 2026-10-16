import Foundation
import XCTest
import Enigmatic

final class DecimalToDoubleTests: XCTestCase {
  func testDecimalBoundariesAndWideCoefficients() throws {
    let values = [
      "0", "-0", "0.10000000149011612", "-0.10000000149011612",
      "1.1111110643192938e38", "-1.500000042698307e-38",
      "3.4028234663852886e38", "18446744073709551615", "18446744073709551616",
      "340282366920938463463374607431768211455", "1e-128", "1e127", "-1e127",
    ]
    for text in values {
      try assertConversion(XCTUnwrap(Decimal(string: text)))
    }
    try assertConversion(.greatestFiniteMagnitude)
    try assertConversion(.leastFiniteMagnitude)
    try assertConversion(.leastNonzeroMagnitude)
    try assertConversion(.nan)
  }

  func testHalfwayValuesRoundToEven() throws {
    let cases: [(String, Double)] = [
      ("9007199254740993", 9_007_199_254_740_992),
      ("9007199254740995", 9_007_199_254_740_996),
      ("-9007199254740993", -9_007_199_254_740_992),
      ("-9007199254740995", -9_007_199_254_740_996),
      ("18014398509481983", 18_014_398_509_481_984),
    ]
    for (text, expected) in cases {
      let decimal = try XCTUnwrap(Decimal(string: text))
      let tree = try Enigma(cast: NSDecimalNumber(decimal: decimal))
      XCTAssertEqual(tree.asDouble?.bitPattern, expected.bitPattern, text)
    }
  }

  func testNSDecimalNumberBridgePreservesCorrectDoubleBits() throws {
    for text in ["0.10000000149011612", "1.1111110643192938e38", "-1.500000042698307e-38"] {
      let number = NSDecimalNumber(string: text)
      let expected = try XCTUnwrap(Double(text))
      let tree = try Enigma(cast: number)
      XCTAssertEqual(tree.asDouble?.bitPattern, expected.bitPattern, text)
      let nested = try Enigma(cast: ["value": number])
      XCTAssertEqual(nested["value"]?.asDouble?.bitPattern, expected.bitPattern, text)
      let array = try Enigma(cast: [number])
      XCTAssertEqual(array[0]?.asDouble?.bitPattern, expected.bitPattern, text)
    }
    XCTAssertTrue(try Enigma(cast: NSDecimalNumber.notANumber).asDouble?.isNaN == true)
  }

  func testSeededValuesMatchDecimalStringRounding() throws {
    var state: UInt64 = 0x123456789abcdef
    func nextSample() -> UInt64 {
      state ^= state << 13
      state ^= state >> 7
      state ^= state << 17
      return state
    }
    for _ in 0..<2_000 {
      let magnitude = Decimal(nextSample())
      let exponent = Int(nextSample() % 256) - 128
      let sign: FloatingPointSign = nextSample() & 1 == 0 ? .plus : .minus
      try assertConversion(Decimal(sign: sign, exponent: exponent, significand: magnitude))
      let wide = magnitude * Decimal(1_000_000_000_000_000_000 as UInt64)
        + Decimal(nextSample() % 1_000_000_000_000_000_000)
      try assertConversion(Decimal(sign: sign, exponent: exponent, significand: wide))
    }
  }

  private func assertConversion(
    _ decimal: Decimal, file: StaticString = #filePath, line: UInt = #line
  ) throws {
    let number = NSDecimalNumber(decimal: decimal)
    let text = number.stringValue
    let expected = try XCTUnwrap(Double(text), file: file, line: line)
    let tree = try Enigma(cast: number)
    guard case .double(let actual) = tree else {
      return XCTFail("Expected a Double node for \(text), got \(tree)", file: file, line: line)
    }
    if expected.isNaN {
      XCTAssertTrue(actual.isNaN, file: file, line: line)
    } else {
      XCTAssertEqual(actual.bitPattern, expected.bitPattern, text, file: file, line: line)
    }
  }
}
