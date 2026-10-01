@testable import Enigmatic
import Foundation
import XCTest

final class ContainersTests: XCTestCase {
  func check<T: Codable & Equatable>(value: T, enigma: Enigma) throws {
    let decoded = try enigma.decode() as T
    XCTAssertEqual(value, decoded)
  }

  func testEach2() throws {
    let a = A()
    let b = B()
    let product = Codec.Each2<A, B>(values: (a: a, b: b))
    let encoded = try Enigma(encode: product)
    try check(value: a, enigma: encoded)
    try check(value: b, enigma: encoded)
    try check(value: product, enigma: encoded)
    var enigma = try Enigma(encode: a)
    try enigma.merge(encode: b, or: Enigma.fail)
    XCTAssertEqual(encoded, enigma)
  }

  func testEach3() throws {
    let a = A()
    let b = B()
    let c = C()
    let product = Codec.Each3<A, B, C>(values: (a: a, b: b, c: c))
    let encoded = try Enigma(encode: product)
    try check(value: a, enigma: encoded)
    try check(value: b, enigma: encoded)
    try check(value: c, enigma: encoded)
    try check(value: product, enigma: encoded)
    var enigma = try Enigma(encode: a)
    try enigma.merge(encode: b, or: Enigma.fail)
    try enigma.merge(encode: c, or: Enigma.fail)
    XCTAssertEqual(encoded, enigma)
  }

  func testEach4() throws {
    let a = A()
    let b = B()
    let c = C()
    let d = D()
    let product = Codec.Each4<A, B, C, D>(values: (a: a, b: b, c: c, d: d))
    let encoded = try Enigma(encode: product)
    try check(value: a, enigma: encoded)
    try check(value: b, enigma: encoded)
    try check(value: c, enigma: encoded)
    try check(value: d, enigma: encoded)
    try check(value: product, enigma: encoded)
    var enigma = try Enigma(encode: a)
    try enigma.merge(encode: b, or: Enigma.fail)
    try enigma.merge(encode: c, or: Enigma.fail)
    try enigma.merge(encode: d, or: Enigma.fail)
    XCTAssertEqual(encoded, enigma)
  }

  @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
  func testEach() throws {
    let a = A()
    let b = B()
    let c = C()
    let d = D()
    let product = Codec.Each(values: (a, b, c, d))
    let encoded = try Enigma(encode: product)
    try check(value: a, enigma: encoded)
    try check(value: b, enigma: encoded)
    try check(value: c, enigma: encoded)
    try check(value: d, enigma: encoded)
    try check(value: product, enigma: encoded)
    var enigma = try Enigma(encode: a)
    try enigma.merge(encode: b, or: Enigma.fail)
    try enigma.merge(encode: c, or: Enigma.fail)
    try enigma.merge(encode: d, or: Enigma.fail)
    XCTAssertEqual(encoded, enigma)
  }

  func testEitherR() throws {
    let a = A()
    let product = Codec.Either<A, B>.right(a)
    let encoded = try Enigma(encode: product)
    try check(value: a, enigma: encoded)
    try check(value: product, enigma: encoded)
  }

  func testEitherL() throws {
    let b = B()
    let product = Codec.Either<A, B>.left(b)
    let encoded = try Enigma(encode: product)
    try check(value: b, enigma: encoded)
    try check(value: product, enigma: encoded)
  }

  func testInterleaved() throws {
    XCTAssertThrowsError(try Enigma(encode: Codec.Each2(values: (a: True(), b: False()))))
    XCTAssertThrowsError(try Enigma(encode: Codec.Each2(values: (a: True(), b: True()))))
    XCTAssertNoThrow(try Enigma(encode: Codec.Each2(values: (a: Box(value: A()), b: Box(value: B())))))
  }
}
