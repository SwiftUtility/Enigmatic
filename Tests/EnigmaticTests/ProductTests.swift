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
    let product = Codec.Each2<A, B>(a, b)
    let encoded = try Enigma(encode: product)
    try check(value: a, enigma: encoded)
    try check(value: b, enigma: encoded)
    try check(value: product, enigma: encoded)
    var enigma = try Enigma(encode: a)
    try enigma.merge(Enigma(encode: b), skipEqual: false)
    XCTAssertEqual(encoded, enigma)
  }

  func testEach3() throws {
    let a = A()
    let b = B()
    let c = C()
    let product = Codec.Each3<A, B, C>(a, b, c)
    let encoded = try Enigma(encode: product)
    try check(value: a, enigma: encoded)
    try check(value: b, enigma: encoded)
    try check(value: c, enigma: encoded)
    try check(value: product, enigma: encoded)
    var enigma = try Enigma(encode: a)
    try enigma.merge(Enigma(encode: b), skipEqual: false)
    try enigma.merge(Enigma(encode: c), skipEqual: false)
    XCTAssertEqual(encoded, enigma)
  }

  func testEach4() throws {
    let a = A()
    let b = B()
    let c = C()
    let d = D()
    let product = Codec.Each4<A, B, C, D>(a, b, c, d)
    let encoded = try Enigma(encode: product)
    try check(value: a, enigma: encoded)
    try check(value: b, enigma: encoded)
    try check(value: c, enigma: encoded)
    try check(value: d, enigma: encoded)
    try check(value: product, enigma: encoded)
    var enigma = try Enigma(encode: a)
    try enigma.merge(Enigma(encode: b), skipEqual: false)
    try enigma.merge(Enigma(encode: c), skipEqual: false)
    try enigma.merge(Enigma(encode: d), skipEqual: false)
    XCTAssertEqual(encoded, enigma)
  }

  func testLegacyEachWritableMembersKeepCopiesIndependent() {
    let pair = Codec.Each2([1], "old")
    var changedPair = pair
    changedPair.0.append(2)
    changedPair.1 = "new"
    XCTAssertEqual(pair.0, [1])
    XCTAssertEqual(pair.1, "old")
    XCTAssertEqual(changedPair, Codec.Each2([1, 2], "new"))

    let triple = Codec.Each3([1], "old", false)
    var changedTriple = triple
    changedTriple.0.append(2)
    changedTriple.1 = "new"
    changedTriple.2 = true
    XCTAssertEqual(triple.0, [1])
    XCTAssertEqual(triple.1, "old")
    XCTAssertFalse(triple.2)
    XCTAssertEqual(changedTriple, Codec.Each3([1, 2], "new", true))

    let quad = Codec.Each4([1], "old", false, 3)
    var changedQuad = quad
    changedQuad.0.append(2)
    changedQuad.1 = "new"
    changedQuad.2 = true
    changedQuad.3 = 4
    XCTAssertEqual(quad.0, [1])
    XCTAssertEqual(quad.1, "old")
    XCTAssertFalse(quad.2)
    XCTAssertEqual(quad.3, 3)
    XCTAssertEqual(changedQuad, Codec.Each4([1, 2], "new", true, 4))
  }

  @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
  func testEach() throws {
    let a = A()
    let b = B()
    let c = C()
    let d = D()
    let product = Codec.Each(a, b, c, d)
    let encoded = try Enigma(encode: product)
    try check(value: a, enigma: encoded)
    try check(value: b, enigma: encoded)
    try check(value: c, enigma: encoded)
    try check(value: d, enigma: encoded)
    try check(value: product, enigma: encoded)
    var enigma = try Enigma(encode: a)
    try enigma.merge(Enigma(encode: b), skipEqual: false)
    try enigma.merge(Enigma(encode: c), skipEqual: false)
    try enigma.merge(Enigma(encode: d), skipEqual: false)
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
    XCTAssertThrowsError(try Enigma(encode: Codec.Each(True(), False())))
    XCTAssertThrowsError(try Enigma(encode: Codec.Each(True(), True())))
    XCTAssertThrowsError(try Enigma(encode: Codec.Each(Box(value: A()), Box(value: B()))))
  }
}
