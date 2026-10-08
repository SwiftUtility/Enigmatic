@testable import Enigmatic
import Foundation
import XCTest

final class EquatableTests: XCTestCase {
  func checkEq(_ one: Enigma, _ two: Enigma) {
    XCTAssertEqual(one, two)
  }

  func checkDif(_ one: Enigma, _ two: Enigma) {
    XCTAssertNotEqual(one, two)
  }

  func checkMiscoded<T: Codable & Equatable>(_ sample: T) throws {
    let encoded = try Enigma(encode: sample)
    let decoded = try encoded.decode() as T
    XCTAssertNotEqual(sample, decoded)
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
    checkEq(.int(1), .float(1))
  }

  func testBig() throws {
    checkDif(.int(Int.max), .int(Int.max - 1))
    checkDif(.int(Int.min), .int(Int.min + 1))
    checkDif(.uint(UInt.max), .uint(UInt.max - 1))
  }

  func testDifferentIntegerWidthsCompareExactly() {
    let value: Int64 = 9_007_199_254_740_993
    XCTAssertEqual(Enigma.int64(value), .uint64(UInt64(value)))
    XCTAssertNotEqual(Enigma.int64(value), .uint64(UInt64(value - 1)))
    XCTAssertEqual(Enigma.int32(16_777_217), .int64(16_777_217))
    XCTAssertNotEqual(Enigma.int32(16_777_217), .int64(16_777_216))
  }

  func testFloatingPointSafeIntegerBoundaries() {
    XCTAssertEqual(Enigma.int64(16_777_216), .float(16_777_216))
    XCTAssertEqual(Enigma.int64(-16_777_216), .float(-16_777_216))
    XCTAssertNotEqual(Enigma.int64(16_777_217), .float(16_777_216))
    XCTAssertEqual(Enigma.int64(16_777_218), .float(16_777_218))

    XCTAssertEqual(Enigma.int64(9_007_199_254_740_992), .double(9_007_199_254_740_992))
    XCTAssertEqual(Enigma.int64(-9_007_199_254_740_992), .double(-9_007_199_254_740_992))
    XCTAssertNotEqual(Enigma.int64(9_007_199_254_740_993), .double(9_007_199_254_740_992))

    // Above the safe boundary, preserve decimal equality rather than the exact
    // integer represented by the floating-point bit pattern.
    XCTAssertEqual(Enigma.float(1e12), .int64(1_000_000_000_000))
    XCTAssertNotEqual(Enigma.float(1e12), .int64(999_999_995_904))
  }

  func testFraction() throws {
    XCTAssertEqual(Float(0.5 as Double), 0.5 as Float)
    XCTAssertEqual(Double(0.5 as Float), 0.5 as Double)
    checkEq(.float(0.5), .double(0.5))
    XCTAssertEqual(Float(0.1 as Double), 0.1 as Float)
    XCTAssertNotEqual(Double(0.1 as Float), 0.1 as Double)
    checkEq(.float(0.1), .double(0.1))
    XCTAssertNotEqual(Double.nan, Double.nan)
    XCTAssertEqual(Enigma.double(Double.nan), Enigma.double(Double.nan))
    XCTAssertNotEqual(Float.nan, Float.nan)
    XCTAssertEqual(Enigma.float(Float.nan), Enigma.float(Float.nan))
  }

  func testMixedFloatingEqualityUsesDecimalRepresentations() {
    let float = Enigma.float(0.1)
    let widened = Enigma.double(Double(Float(0.1)))
    XCTAssertEqual(float, .double(0.1))
    XCTAssertEqual(Enigma.double(0.1), float)
    XCTAssertNotEqual(.double(0.1), widened)

    let different: [(Enigma, Enigma)] = [
      (widened, float),
      (.double(16_777_217), .float(16_777_216)),
      (.double(.leastNonzeroMagnitude), .float(0)),
      (.double(-Double.leastNonzeroMagnitude), .float(-0.0)),
      (.double(Double(Float.greatestFiniteMagnitude).nextUp), .float(.greatestFiniteMagnitude)),
    ]
    for (lhs, rhs) in different {
      XCTAssertNotEqual(lhs, rhs)
      XCTAssertNotEqual(rhs, lhs)
      XCTAssertNotEqual(Enigma.array([lhs]), .array([rhs]))
      XCTAssertNotEqual(Enigma.dictionary(["value": .array([lhs])]), .dictionary(["value": .array([rhs])]))
    }
    XCTAssertFalse([widened].contains(.double(0.1)))
    XCTAssertFalse([widened].contains(float))
  }

  func testNumericEqualityLaws() {
    var values: [Enigma] = [
      .int(0), .int64(0), .int32(0), .int16(0), .int8(0),
      .uint(0), .uint64(0), .uint32(0), .uint16(0), .uint8(0),
      .double(0), .double(-0.0), .float(0), .float(-0.0),
      .int(-1), .int(1), .uint(1), .double(1), .float(1),
      .double(0.1), .float(0.1), .double(Double(Float(0.1))),
      .int32(16_777_217), .double(16_777_217), .float(16_777_216),
      .int64(9_007_199_254_740_993), .double(9_007_199_254_740_992),
      .float(1e12), .double(1e12), .int64(1_000_000_000_000), .int64(999_999_995_904),
      .double(1e23),
      .int(.min), .int(.max), .uint(.max), .int64(.min), .uint64(.max),
      .double(.leastNonzeroMagnitude), .double(-Double.leastNonzeroMagnitude),
      .double(.greatestFiniteMagnitude), .float(.greatestFiniteMagnitude),
      .double(.infinity), .float(.infinity), .double(-.infinity), .float(-.infinity),
      .double(.nan), .float(.nan), .double(Double(bitPattern: 0xfff8000000000001)),
      .float(Float(bitPattern: 0x7f800001)), .double(Double(bitPattern: 0x7ff0000000000001)),
    ]
    var bits: UInt32 = 1
    for _ in 0..<32 {
      bits = bits &* 1_664_525 &+ 1_013_904_223
      let value = Float(bitPattern: bits)
      if value.isFinite {
        values += [.float(value), .double(Double(String(value))!), .double(Double(value))]
      }
    }
    if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
      values += [.int128(.init(0)), .uint128(.init(0)), .int128(.init(-1)),
                 .int128(.init(100_000_000_000_000_000_000_000)),
                 .uint128(.init(100_000_000_000_000_000_000_000)),
                 .int128(.init(Int128(Double(1e23)))),
                 .int128(.init(.min)), .int128(.init(.max)), .uint128(.init(.max))]
    }
    checkEqualityLaws(values)
    checkEqualityLaws(values.map { .array([$0]) })
    checkEqualityLaws(values.map { .dictionary(["value": .array([$0])]) })

    XCTAssertEqual(Enigma.int(16_777_217), .double(16_777_217))
    XCTAssertNotEqual(Enigma.int(16_777_217), .float(16_777_216))
    XCTAssertNotEqual(Enigma.int64(9_007_199_254_740_993), .double(9_007_199_254_740_992))
    XCTAssertEqual(Enigma.double(-0.0), .uint8(0))
    XCTAssertEqual(Enigma.double(.nan), .float(.nan))
    XCTAssertNotEqual(Enigma.double(.infinity), .float(-.infinity))
    XCTAssertNotEqual(Enigma.double(.greatestFiniteMagnitude), .float(.infinity))
    XCTAssertNotEqual(Enigma.bool(false), .int(0))
    XCTAssertEqual(Enigma.float(1e12), .int64(1_000_000_000_000))
    XCTAssertNotEqual(Enigma.float(1e12), .int64(999_999_995_904))
    XCTAssertEqual(Enigma.double(-1e12), .int64(-1_000_000_000_000))
    if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
      XCTAssertEqual(Enigma.double(1e23), .uint128(.init(100_000_000_000_000_000_000_000)))
      XCTAssertNotEqual(Enigma.double(1e23), .int128(.init(Int128(Double(1e23)))))
    }
  }

  private func checkEqualityLaws(_ values: [Enigma], file: StaticString = #filePath, line: UInt = #line) {
    let equal = values.map { lhs in values.map { lhs == $0 } }
    for i in values.indices {
      XCTAssertTrue(equal[i][i], "Reflexivity: sample \(i)", file: file, line: line)
      for j in values.indices {
        XCTAssertEqual(equal[i][j], equal[j][i], "Symmetry: samples \(i), \(j)", file: file, line: line)
      }
    }
    for i in values.indices {
      for j in values.indices where equal[i][j] {
        for k in values.indices where equal[j][k] && !equal[i][k] {
          XCTFail("Transitivity: samples \(i), \(j), \(k): \(values[i]), \(values[j]), \(values[k])", file: file, line: line)
          return
        }
      }
    }
  }

  func testSkipEqualUsesDecimalEquality() throws {
    let a = Enigma.double(0.1)
    let b = Enigma.float(0.1)
    let c = Enigma.double(Double(Float(0.1)))
    XCTAssertEqual(try a.merging(b, skipEqual: true).asDouble?.bitPattern, Double(0.1).bitPattern)
    XCTAssertEqual(try b.merging(a, skipEqual: true).asFloat?.bitPattern, Float(0.1).bitPattern)
    XCTAssertThrowsError(try b.merging(c, skipEqual: true))
    XCTAssertThrowsError(try a.merging(c, skipEqual: true))
    // Both groupings must reject the conflicting decimal representation.
    XCTAssertThrowsError(try a.merging(b, skipEqual: true).merging(c, skipEqual: true))
    XCTAssertThrowsError(try a.merging(b.merging(c, skipEqual: true), skipEqual: true))
    XCTAssertThrowsError(try Enigma.double(.leastNonzeroMagnitude).merging(.float(0), skipEqual: true))
    XCTAssertEqual(try Enigma.array([a]).merging(.array([b]), skipEqual: true), .array([a]))

    var tree = Enigma.dictionary(["value": .array([a])])
    XCTAssertNoThrow(try tree.merge(.dictionary(["value": .array([b])]), skipEqual: true))
    XCTAssertThrowsError(try tree.merge(.dictionary(["value": .array([c])]), skipEqual: true)) { error in
      guard case EncodingError.invalidValue(_, let context) = error else { return XCTFail("\(error)") }
      XCTAssertEqual(context.codingPath.map(Enigma.Pin.init), ["value"])
    }
    XCTAssertEqual(tree["value", 0]?.asDouble?.bitPattern, Double(0.1).bitPattern)
    XCTAssertNoThrow(try Enigma.double(.nan).merging(.float(.nan), skipEqual: true))
  }

  func testNaNDateTreesAreReflexive() {
    let value = Enigma.date(Date(timeIntervalSince1970: .nan))
    // Build containers separately so shared-storage shortcuts cannot hide unequal leaves.
    let pairs: [(Enigma, Enigma)] = [
      (value, value),
      (.array([value]), .array([value])),
      (.dictionary(["value": .array([value])]), .dictionary(["value": .array([value])])),
    ]
    for (lhs, rhs) in pairs {
      XCTAssertEqual(lhs, lhs)
      XCTAssertEqual(lhs, rhs)
      XCTAssertNoThrow(try lhs.merging(rhs, skipEqual: true))
    }
  }
}
