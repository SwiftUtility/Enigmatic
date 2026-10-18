import Foundation
import XCTest
@testable import Comparison

final class ComparisonTests: XCTestCase {
  func testPairedRatioMomentsAndMedian() {
    let stats = Statistics(times: [2, 12, 4], baseline: [2, 4, 2])
    XCTAssertEqual(stats.meanRatio, 2)
    XCTAssertEqual(stats.varianceRatio, 2.0 / 3, accuracy: 1e-12)
    XCTAssertEqual(stats.medianNanoseconds, 4)
    XCTAssertEqual(Statistics(times: [4, 2], baseline: [1, 1]).medianNanoseconds, 3)
  }

  func testBaselineHasUnitMeanAndZeroVariance() {
    let stats = Statistics(times: [1, 3, 2], baseline: [1, 3, 2])
    XCTAssertEqual(stats.meanRatio, 1)
    XCTAssertEqual(stats.varianceRatio, 0)
  }

  func testModelVariantsHaveIdenticalPayloads() throws {
    let plain = try foundationEncode(Payload(records: (0..<5).map(PlainRow.init)), wire: .json)
    for bytes in [
      try foundationEncode(Payload(records: (0..<5).map(WrappedRow.init)), wire: .json),
      try foundationEncode(Payload(records: (0..<5).map(BetterRow.init)), wire: .json),
      try foundationEncode(Payload(records: (0..<5).map(MacroRow.init)), wire: .json),
    ] {
      let expected = try XCTUnwrap(JSONSerialization.jsonObject(with: plain) as? NSDictionary)
      let actual = try XCTUnwrap(JSONSerialization.jsonObject(with: bytes) as? NSDictionary)
      XCTAssertEqual(expected, actual)
    }
  }

  func testNativePlistStorageIsDistinctFromModelRoundtrip() {
    XCTAssertEqual(probe(.data, engine: .enigma, wire: .binary).status, "✅")
    XCTAssertEqual(probe(.nativeData, engine: .enigma, wire: .binary).status, "❌")
    for engine in [Engine.foundation, .enigmaObjects] {
      XCTAssertEqual(probe(.nativeData, engine: engine, wire: .binary).status, "✅")
      XCTAssertEqual(probe(.nativeDate, engine: engine, wire: .binary).status, "✅")
    }
  }

  func testNativePlistTypeCanBeInspectedIndependentlyOfDatePrecision() {
    XCTAssertEqual(probe(.plistDateType, engine: .foundation, wire: .xml).status, "✅")
    XCTAssertEqual(probe(.plistDataType, engine: .foundation, wire: .xml).status, "✅")
    XCTAssertEqual(probe(.plistDateType, engine: .enigma, wire: .xml).status, "❌")
  }

  func testNullPolicyIsDistinctFromOptionalRoundtrip() {
    XCTAssertEqual(probe(.defaultNull, engine: .foundation, wire: .json).status, "❌")
    XCTAssertEqual(probe(.explicitNull, engine: .foundation, wire: .json).status, "✅")
    XCTAssertEqual(probe(.libraryNull, engine: .enigmaCodec, wire: .json).status, "✅")
    XCTAssertEqual(probe(.libraryNull, engine: .codableWrappers, wire: .json).status, "✅")
  }

  func testUnsupportedFormatIsNotSilentlyBridged() {
    XCTAssertEqual(probe(.string, engine: .swiftJSON, wire: .binary).status, "—")
    XCTAssertEqual(probe(.string, engine: .enigmaCodec, wire: .xml).status, "—")
  }

  func testConfiguredAndStrictNonFiniteJSONAreSeparate() {
    XCTAssertEqual(probe(.doubleInfinity, engine: .foundation, wire: .json).status, "⚠️")
    XCTAssertEqual(probe(.doubleInfinity, engine: .foundation, wire: .jsonStrings).status, "✅")
    XCTAssertEqual(probe(.doubleNaN, engine: .foundation, wire: .jsonStrings).status, "✅")
  }
}
