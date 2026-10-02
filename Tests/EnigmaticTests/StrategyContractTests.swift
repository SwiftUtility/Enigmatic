import Foundation
import XCTest
@testable import Enigmatic

final class StrategyContractTests: XCTestCase {
  func roundTrip<S: Codec.EncodeStrategy & Codec.DecodeStrategy>(
    _ strategy: S.Type, _ value: S.BoxedValue, expected: Enigma,
    file: StaticString = #filePath, line: UInt = #line
  ) throws where S.BoxedValue: Equatable {
    let box = Codec.Box<S>(wrappedValue: value)
    let tree = try Enigma(encode: box)
    XCTAssertEqual(tree, expected, file: file, line: line)
    XCTAssertEqual(try tree.decode(Codec.Box<S>.self).wrappedValue, value, file: file, line: line)
    XCTAssertEqual(try JSONDecoder().decode(Codec.Box<S>.self, from: JSONEncoder().encode(box)), box, file: file, line: line)
  }

  func testScalarAndCollectionStrategies() throws {
    try roundTrip(Codec.Id<Int>.self, 42, expected: 42)
    try roundTrip(Codec.Base64Data.self, Data([1, 2, 3]), expected: "AQID")
    try roundTrip(Codec.Base64Data.self, Data(), expected: "")
    try roundTrip(Codec.Base64Data?.self, nil, expected: nil)
    try roundTrip(Codec.StringURL.self, URL(string: "https://example.com/a")!, expected: "https://example.com/a")
    try roundTrip([Codec.Id<Int>].self, [], expected: [])
    try roundTrip([String: Codec.Id<Int>].self, ["x": 1], expected: ["x": 1])
    let set = try Enigma.array([1, 1, 2]).decode(Codec.Box<Set<Codec.Id<Int>>>.self)
    XCTAssertEqual(set.wrappedValue, [1, 2])
    let encoded = try Enigma(encode: set)
    XCTAssertEqual(Set(try encoded.decode([Int].self)), [1, 2])
    try roundTrip(Set<Codec.Id<Int>>.self, [], expected: [])
    assertDecodingError("dataCorrupted", path: ["data"]) {
      _ = try Enigma.dictionary(["data": "!"]).decode([String: Codec.Box<Codec.Base64Data>].self)
    }
    assertDecodingError("dataCorrupted", path: []) {
      _ = try Enigma.string("http://[").decode(Codec.Box<Codec.StringURL>.self)
    }
    assertDecodingError("typeMismatch", path: [1]) {
      _ = try Enigma.array([1, "x"]).decode(Codec.Box<Set<Codec.Id<Int>>>.self)
    }
  }

  func testOptionalBox() throws {
    typealias OptionalStrategy = Codec.Id<Int>?
    let box = Codec.OptionalBox<OptionalStrategy>(wrappedValue: 42)

    let json = try JSONEncoder().encode(box)
    XCTAssertEqual(String(decoding: json, as: UTF8.self), "42")
    XCTAssertEqual(try JSONDecoder().decode(Codec.OptionalBox<OptionalStrategy>.self, from: json), box)

    let tree = try Enigma(encode: box)
    XCTAssertEqual(tree, 42)
    XCTAssertEqual(try tree.decode(Codec.OptionalBox<OptionalStrategy>.self), box)

    typealias NestedOptionalStrategy = Codec.Id<Int>??
    let nestedNil = Codec.OptionalBox<NestedOptionalStrategy>(wrappedValue: nil)
    let nestedNilJSON = try JSONEncoder().encode(nestedNil)
    XCTAssertEqual(String(decoding: nestedNilJSON, as: UTF8.self), "null")
    XCTAssertNil(try JSONDecoder().decode(Codec.OptionalBox<NestedOptionalStrategy>.self, from: nestedNilJSON).wrappedValue)

    let nestedNilTree = try Enigma(encode: nestedNil)
    XCTAssertEqual(nestedNilTree, .null)
    XCTAssertNil(try nestedNilTree.decode(Codec.OptionalBox<NestedOptionalStrategy>.self).wrappedValue)
  }

  func testResultDefersFailureAndPreservesCause() throws {
    typealias Wrapped = Codec.Box<Result<Codec.Id<Int>, any Error>>
    let success = try Enigma.int(7).decode(Wrapped.self)
    XCTAssertEqual(try success.wrappedValue.get(), 7)
    XCTAssertEqual(try Enigma(encode: success), 7)
    let failed = try Enigma.string("bad").decode(Wrapped.self)
    guard case .failure(let original) = failed.wrappedValue else { return XCTFail("Expected failure") }
    XCTAssertTrue(original is DecodingError)
    XCTAssertThrowsError(try Enigma(encode: ["result": failed])) { error in
      guard case EncodingError.invalidValue(_, let context) = error else { return XCTFail("\(error)") }
      XCTAssertEqual(context.codingPath.map(Enigma.Pin.init), ["result"])
      XCTAssertTrue(context.underlyingError is DecodingError)
    }
  }

  func testEitherPriorityFallbackAndAggregatedErrors() throws {
    typealias Either = Codec.Either<Int, String>
    XCTAssertEqual(try Enigma.int(1).decode(Either.self).right, 1)
    XCTAssertEqual(try Enigma.string("s").decode(Either.self).left, "s")
    XCTAssertNil(Either.left("s").right)
    XCTAssertNil(Either.right(1).left)
    XCTAssertNotEqual(Either.left("1"), .right(1))
    XCTAssertEqual(Set([Either.left("s"), .right(1), .left("s")]).count, 2)
    XCTAssertEqual(try Enigma.int(1).decode(Codec.Either<Int, Double>.self), .right(1))
    XCTAssertEqual(try Enigma(encode: Either.left("s")), "s")
    typealias Strategy = Codec.Either<Codec.Id<Int>, Codec.Id<String>>
    try roundTrip(Strategy.self, .right(2), expected: 2)
    try roundTrip(Strategy.self, .left("s"), expected: "s")
    for decode in [
      { _ = try Enigma.array([true]).decode([Either].self) },
      { _ = try Enigma.array([true]).decode([Codec.Box<Strategy>].self) }
    ] {
      XCTAssertThrowsError(try decode()) { error in
        guard case DecodingError.dataCorrupted(let context) = error else { return XCTFail("\(error)") }
        XCTAssertEqual(context.codingPath.map(Enigma.Pin.init), [0])
        let composite = context.underlyingError as? Enigma.CompositeError
        XCTAssertEqual(composite?.errors.count, 2)
        XCTAssertTrue(composite?.errors.allSatisfy { $0 is DecodingError } == true)
      }
    }
  }

  func testBoxValueSemanticsAndCompositeError() throws {
    var box = Codec.Box<Codec.Id<Int>>(wrappedValue: 1)
    box.wrappedValue = 2
    XCTAssertEqual(box, .init(wrappedValue: 2))
    XCTAssertEqual(Set([box, box]).count, 1)
    XCTAssertEqual(box.description, "2")
    XCTAssertEqual(box.debugDescription, "2")
    var errors = Enigma.CompositeError()
    XCTAssertEqual(errors.report(3), 3)
    enum Failure: Error { case expected }
    func fail() throws -> Int { throw Failure.expected }
    XCTAssertNil(errors.report(try fail()))
    XCTAssertEqual(errors.errors.count, 1)
  }

  @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
  func testEachCompositionAndConflicts() throws {
    struct A: Codable, Hashable { let a: Int }
    struct B: Codable, Hashable { let b: String }
    let value = Codec.Each(values: (A(a: 1), B(b: "s")))
    let tree = try Enigma(encode: value)
    XCTAssertEqual(tree, ["a": 1, "b": "s"])
    XCTAssertEqual(try tree.decode(type(of: value)), value)
    XCTAssertEqual(Set([value, value]).count, 1)
    XCTAssertNotEqual(value, Codec.Each(values: (A(a: 2), B(b: "s"))))
    let boxed = Codec.Box<Codec.Each<Codec.Id<A>, Codec.Id<B>>>(wrappedValue: (A(a: 1), B(b: "s")))
    XCTAssertEqual(try Enigma(encode: boxed), tree)
    let restored = try tree.decode(type(of: boxed))
    XCTAssertEqual(restored.wrappedValue.0, A(a: 1))
    XCTAssertEqual(restored.wrappedValue.1, B(b: "s"))
    XCTAssertThrowsError(try Enigma(encode: Codec.Each(values: (A(a: 1), A(a: 2)))))
    XCTAssertThrowsError(try Enigma(encode: Codec.Each(values: (1, 2))))
    assertDecodingError("keyNotFound", path: []) { _ = try Enigma.dictionary(["a": 1]).decode(type(of: value)) }
  }

  func testPlistDateAndLegacyUnixStrategies() throws {
    let epoch = Date(timeIntervalSinceReferenceDate: 0)
    try roundTrip(Codec.PlistDate.self, epoch, expected: 0)
    let date = Date(timeIntervalSince1970: -123)
    try roundTrip(Codec.UnixSecondsDate.self, date, expected: -123)
    try roundTrip(Codec.UnixMillisecondsDate.self, date, expected: -123000)
    try roundTrip(Codec.UnixIntSecondsDate.self, date, expected: -123)
    try roundTrip(Codec.UnixIntMillisecondsDate.self, date, expected: -123000)
    try checkInvalidDates(Codec.PlistDate.self)
    try checkInvalidDates(Codec.UnixSecondsDate.self)
    try checkInvalidDates(Codec.UnixMillisecondsDate.self)
    try checkInvalidDates(Codec.UnixIntSecondsDate.self)
    try checkInvalidDates(Codec.UnixIntMillisecondsDate.self)
    XCTAssertThrowsError(try Enigma(encode: Codec.Box<Codec.UnixMillisecondsDate>(wrappedValue: Date(timeIntervalSince1970: .greatestFiniteMagnitude))))
    XCTAssertThrowsError(try Enigma(encode: Codec.Box<Codec.UnixIntSecondsDate>(wrappedValue: Date(timeIntervalSince1970: Double(Int.max)))))
    XCTAssertThrowsError(try Enigma(encode: Codec.Box<Codec.UnixIntMillisecondsDate>(wrappedValue: Date(timeIntervalSince1970: Double(Int.max)))))
  }

  private func checkInvalidDates<S: Codec.EncodeStrategy & Codec.DecodeStrategy>(_ strategy: S.Type) throws where S.BoxedValue == Date {
    for number in [Double.nan, .infinity, -.infinity] {
      XCTAssertThrowsError(try Enigma(encode: Codec.Box<S>(wrappedValue: Date(timeIntervalSince1970: number)))) { error in
        XCTAssertTrue(error is EncodingError)
      }
      XCTAssertThrowsError(try Enigma.double(number).decode(Codec.Box<S>.self)) { error in
        XCTAssertTrue(error is DecodingError)
      }
    }
  }

  @available(anyAppleOS 26, *)
  func testScaledDatesAndTruncation() throws {
    let date = Date(timeIntervalSince1970: -123.25)
    try roundTrip(Codec.UnixDate<0>.self, date, expected: .double(-123.25))
    try roundTrip(Codec.UnixDate<3>.self, date, expected: -123250)
    try roundTrip(Codec.UnixDate<6>.self, date, expected: -123250000)
    try roundTrip(Codec.UnixIntDate<3>.self, date, expected: -123250)
    try roundTrip(Codec.UnixIntDate<6>.self, date, expected: -123250000)
    let truncated = try Enigma(encode: Codec.Box<Codec.UnixIntDate<0>>(wrappedValue: date))
    XCTAssertEqual(truncated, -123)
    XCTAssertEqual(try truncated.decode(Codec.Box<Codec.UnixIntDate<0>>.self).wrappedValue, Date(timeIntervalSince1970: -123))
    try checkInvalidDates(Codec.UnixDate<0>.self)
    try checkInvalidDates(Codec.UnixIntDate<0>.self)
    XCTAssertThrowsError(try Enigma(encode: Codec.Box<Codec.UnixDate<3>>(wrappedValue: Date(timeIntervalSince1970: .greatestFiniteMagnitude))))
    XCTAssertThrowsError(try Enigma(encode: Codec.Box<Codec.UnixIntDate<3>>(wrappedValue: Date(timeIntervalSince1970: .greatestFiniteMagnitude))))
    XCTAssertThrowsError(try Enigma(encode: Codec.Box<Codec.UnixIntDate<0>>(wrappedValue: Date(timeIntervalSince1970: Double(Int.max)))))
    // The lower bound is representable and must not be excluded by a strict comparison.
    XCTAssertEqual(try Enigma(encode: Codec.Box<Codec.UnixIntDate<0>>(wrappedValue: Date(timeIntervalSince1970: Double(Int.min)))), .int(Int.min))
    try checkInvalidScale(Codec.UnixDate<400>.self)
    try checkInvalidScale(Codec.UnixDate< -400 >.self)
    try checkInvalidScale(Codec.UnixIntDate<400>.self)
    try checkInvalidScale(Codec.UnixIntDate< -400 >.self)
    XCTAssertThrowsError(try Enigma.double(.greatestFiniteMagnitude).decode(Codec.Box<Codec.UnixDate< -3 >>.self))
    XCTAssertThrowsError(try Enigma.int(Int.max).decode(Codec.Box<Codec.UnixIntDate< -300 >>.self))
  }

  private func checkInvalidScale<S: Codec.EncodeStrategy & Codec.DecodeStrategy>(_ strategy: S.Type) throws where S.BoxedValue == Date {
    assertDecodingError("dataCorrupted", path: []) { _ = try Enigma.int(1).decode(Codec.Box<S>.self) }
    XCTAssertThrowsError(try Enigma(encode: Codec.Box<S>(wrappedValue: Date(timeIntervalSince1970: 1)))) { error in
      guard case EncodingError.invalidValue(_, let context) = error else { return XCTFail("\(error)") }
      XCTAssertTrue(context.codingPath.isEmpty)
    }
  }
}
