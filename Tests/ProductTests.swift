@testable import Enigmatic
import Foundation
import XCTest

final class ProductTests: XCTestCase {
  func check<T: Codable & Equatable>(value: T, enigma: Enigma) throws {
    let decoded = try enigma.decode() as T
    XCTAssertEqual(value, decoded)
  }

  func testProduct2() throws {
    let a = A()
    let b = B()
    let product = Enigma.Product2<A, B>(a: a, b: b)
    let encoded = try Enigma(encode: product)
    try check(value: a, enigma: encoded)
    try check(value: b, enigma: encoded)
    try check(value: product, enigma: encoded)
    var enigma = try Enigma(encode: a)
    try enigma.encode(b)
    XCTAssertEqual(encoded, enigma)
  }

  func testProduct3() throws {
    let a = A()
    let b = B()
    let c = C()
    let product = Enigma.Product3<A, B, C>(a: a, b: b, c: c)
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

  func testProduct4() throws {
    let a = A()
    let b = B()
    let c = C()
    let d = D()
    let product = Enigma.Product4<A, B, C, D>(a: a, b: b, c: c, d: d)
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

  func testCoproduct2A() throws {
    let a = A()
    let product = Enigma.Coproduct2<A, B>.a(a)
    let encoded = try Enigma(encode: product)
    try check(value: a, enigma: encoded)
    try check(value: product, enigma: encoded)
  }

  func testCoproduct2B() throws {
    let b = B()
    let product = Enigma.Coproduct2<A, B>.b(b)
    let encoded = try Enigma(encode: product)
    try check(value: b, enigma: encoded)
    try check(value: product, enigma: encoded)
  }

  func testCoproduct3A() throws {
    let a = A()
    let product = Enigma.Coproduct3<A, B, C>.a(a)
    let encoded = try Enigma(encode: product)
    try check(value: a, enigma: encoded)
    try check(value: product, enigma: encoded)
  }

  func testCoproduct3B() throws {
    let b = B()
    let product = Enigma.Coproduct3<A, B, C>.b(b)
    let encoded = try Enigma(encode: product)
    try check(value: b, enigma: encoded)
    try check(value: product, enigma: encoded)
  }

  func testCoproduct3C() throws {
    let c = C()
    let product = Enigma.Coproduct3<A, B, C>.c(c)
    let encoded = try Enigma(encode: product)
    try check(value: c, enigma: encoded)
    try check(value: product, enigma: encoded)
  }

  func testCoproduct4A() throws {
    let a = A()
    let product = Enigma.Coproduct4<A, B, C, D>.a(a)
    let encoded = try Enigma(encode: product)
    try check(value: a, enigma: encoded)
    try check(value: product, enigma: encoded)
  }

  func testCoproduct4B() throws {
    let b = B()
    let product = Enigma.Coproduct4<A, B, C, D>.b(b)
    let encoded = try Enigma(encode: product)
    try check(value: b, enigma: encoded)
    try check(value: product, enigma: encoded)
  }

  func testCoproduct4C() throws {
    let c = C()
    let product = Enigma.Coproduct4<A, B, C, D>.c(c)
    let encoded = try Enigma(encode: product)
    try check(value: c, enigma: encoded)
    try check(value: product, enigma: encoded)
  }

  func testCoproduct4D() throws {
    let d = D()
    let product = Enigma.Coproduct4<A, B, C, D>.d(d)
    let encoded = try Enigma(encode: product)
    try check(value: d, enigma: encoded)
    try check(value: product, enigma: encoded)
  }

  func testInterleaved() throws {
    XCTAssertThrowsError(try Enigma(encode: Enigma.Product2(a: True(), b: False())))
    XCTAssertNoThrow(try Enigma(encode: Enigma.Product2(a: True(), b: True())))
  }
}
