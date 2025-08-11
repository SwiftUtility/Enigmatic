@testable import Enigmatic
import Foundation
import XCTest

final class ProdTests: XCTestCase {
  func check<T: Codable & Equatable>(value: T, enigma: Enigma) throws {
    let decoded = try enigma.decode() as T
    XCTAssertEqual(value, decoded)
  }

  func testProd2() throws {
    let a = A()
    let b = B()
    let product = Enigma.Prod2<A, B>(a: a, b: b)
    let encoded = try Enigma(encode: product)
    try check(value: a, enigma: encoded)
    try check(value: b, enigma: encoded)
    try check(value: product, enigma: encoded)
    var enigma = try Enigma(encode: a)
    try enigma.encode(b)
    XCTAssertEqual(encoded, enigma)
  }

  func testProd3() throws {
    let a = A()
    let b = B()
    let c = C()
    let product = Enigma.Prod3<A, B, C>(a: a, b: b, c: c)
    let encoded = try Enigma(encode: product)
    try check(value: a, enigma: encoded)
    try check(value: b, enigma: encoded)
    try check(value: c, enigma: encoded)
    try check(value: product, enigma: encoded)
    var enigma = try Enigma(encode: a)
    try enigma.encode(b)
    try enigma.encode(c)
    XCTAssertEqual(encoded, enigma)
  }

  func testProd4() throws {
    let a = A()
    let b = B()
    let c = C()
    let d = D()
    let product = Enigma.Prod4<A, B, C, D>(a: a, b: b, c: c, d: d)
    let encoded = try Enigma(encode: product)
    try check(value: a, enigma: encoded)
    try check(value: b, enigma: encoded)
    try check(value: c, enigma: encoded)
    try check(value: d, enigma: encoded)
    try check(value: product, enigma: encoded)
    var enigma = try Enigma(encode: a)
    try enigma.encode(b)
    try enigma.encode(c)
    try enigma.encode(d)
    XCTAssertEqual(encoded, enigma)
  }

  @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
  func testProd() throws {
    let a = A()
    let b = B()
    let c = C()
    let d = D()
    let product = Enigma.Prod<A, B, C, D>(values: (a, b, c, d))
    let encoded = try Enigma(encode: product)
    try check(value: a, enigma: encoded)
    try check(value: b, enigma: encoded)
    try check(value: c, enigma: encoded)
    try check(value: d, enigma: encoded)
    try check(value: product, enigma: encoded)
    var enigma = try Enigma(encode: a)
    try enigma.encode(b)
    try enigma.encode(c)
    try enigma.encode(d)
    XCTAssertEqual(encoded, enigma)
  }

  func testSum2A() throws {
    let a = A()
    let product = Enigma.Sum2<A, B>.a(a)
    let encoded = try Enigma(encode: product)
    try check(value: a, enigma: encoded)
    try check(value: product, enigma: encoded)
  }

  func testSum2B() throws {
    let b = B()
    let product = Enigma.Sum2<A, B>.b(b)
    let encoded = try Enigma(encode: product)
    try check(value: b, enigma: encoded)
    try check(value: product, enigma: encoded)
  }

  func testSum3A() throws {
    let a = A()
    let product = Enigma.Sum3<A, B, C>.a(a)
    let encoded = try Enigma(encode: product)
    try check(value: a, enigma: encoded)
    try check(value: product, enigma: encoded)
  }

  func testSum3B() throws {
    let b = B()
    let product = Enigma.Sum3<A, B, C>.b(b)
    let encoded = try Enigma(encode: product)
    try check(value: b, enigma: encoded)
    try check(value: product, enigma: encoded)
  }

  func testSum3C() throws {
    let c = C()
    let product = Enigma.Sum3<A, B, C>.c(c)
    let encoded = try Enigma(encode: product)
    try check(value: c, enigma: encoded)
    try check(value: product, enigma: encoded)
  }

  func testSum4A() throws {
    let a = A()
    let product = Enigma.Sum4<A, B, C, D>.a(a)
    let encoded = try Enigma(encode: product)
    try check(value: a, enigma: encoded)
    try check(value: product, enigma: encoded)
  }

  func testSum4B() throws {
    let b = B()
    let product = Enigma.Sum4<A, B, C, D>.b(b)
    let encoded = try Enigma(encode: product)
    try check(value: b, enigma: encoded)
    try check(value: product, enigma: encoded)
  }

  func testSum4C() throws {
    let c = C()
    let product = Enigma.Sum4<A, B, C, D>.c(c)
    let encoded = try Enigma(encode: product)
    try check(value: c, enigma: encoded)
    try check(value: product, enigma: encoded)
  }

  func testSum4D() throws {
    let d = D()
    let product = Enigma.Sum4<A, B, C, D>.d(d)
    let encoded = try Enigma(encode: product)
    try check(value: d, enigma: encoded)
    try check(value: product, enigma: encoded)
  }

  @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
  func testSum() throws {
    let a = A()
    let c = C()
    let product = Enigma.Sum<A, B, C, D>(values: (a, nil, c, nil))
    let encoded = try Enigma(encode: product)
    try check(value: a, enigma: encoded)
    try check(value: c, enigma: encoded)
    try check(value: product, enigma: encoded)
    var enigma = try Enigma(encode: a)
    try enigma.encode(c)
    XCTAssertEqual(encoded, enigma)
  }

  @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
  func testSumA() throws {
    let a = A()
    let product = Enigma.Sum<A, B, C, D>(values: (a, nil, nil, nil))
    let encoded = try Enigma(encode: product)
    try check(value: a, enigma: encoded)
    try check(value: product, enigma: encoded)
  }

  @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
  func testSumB() throws {
    let b = B()
    let product = Enigma.Sum<A, B, C, D>(values: (nil, b, nil, nil))
    let encoded = try Enigma(encode: product)
    try check(value: b, enigma: encoded)
    try check(value: product, enigma: encoded)
  }

  @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
  func testSumC() throws {
    let c = C()
    let product = Enigma.Sum<A, B, C, D>(values: (nil, nil, c, nil))
    let encoded = try Enigma(encode: product)
    try check(value: c, enigma: encoded)
    try check(value: product, enigma: encoded)
  }

  @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
  func testSumD() throws {
    let d = D()
    let product = Enigma.Sum<A, B, C, D>(values: (nil, nil, nil, d))
    let encoded = try Enigma(encode: product)
    try check(value: d, enigma: encoded)
    try check(value: product, enigma: encoded)
  }

  func testInterleaved() throws {
    XCTAssertThrowsError(try Enigma(encode: Enigma.Prod2(a: True(), b: False())))
    XCTAssertNoThrow(try Enigma(encode: Enigma.Prod2(a: True(), b: True())))
  }
}
