@testable import Enigmatic
import Foundation
import XCTest

final class CodableTests: XCTestCase {
  func check<T: Codable & Equatable>(decode sample: T, canSerialize: Bool = true) throws {
    let encoded = try Enigma(encode: sample)
    let decoded = try encoded.decode() as T
    XCTAssertEqual(sample, decoded)
    let erased = encoded.asAnyObject
    let restored = try Enigma(cast: erased)
    XCTAssertEqual(encoded, restored)
    let enjsoned = try Helper.enjson(encoded)
    let dejsoned = try Helper.dejson(Enigma.self, from: enjsoned)
    XCTAssertEqual(encoded, dejsoned)
    let jsoned = try dejsoned.decode() as T
    XCTAssertEqual(sample, jsoned)
    if encoded.asArray != nil || encoded.asDictionary != nil {
      let reference = try Helper.deplist(Enigma.self, from: Helper.enplist(sample))
      XCTAssertEqual(encoded, reference)
      let enplisted = try Helper.enplist(encoded)
      let deplisted = try Helper.deplist(Enigma.self, from: enplisted)
      XCTAssertEqual(encoded, deplisted)
      let plisted = try deplisted.decode() as T
      XCTAssertEqual(sample, plisted)
    }
    if canSerialize {
      let serialized = try Helper.serialize(encoded.asAnyObject)
      let deserialized = try Enigma(cast: Helper.deserialize(serialized))
      XCTAssertEqual(encoded, deserialized)
    }
  }

  func testMaxInts() throws {
    try check(decode: MaxInts())
  }

  func testMinInts() throws {
    try check(decode: MinInts())
  }

  func testOptInts() throws {
    try check(decode: OptInts())
  }

  func testNilInts() throws {
    try check(decode: NilInts())
  }

  func testMaxUInts() throws {
    try check(decode: MaxUInts())
  }

  func testOptUInts() throws {
    try check(decode: OptUInts())
  }

  func testNilUInts() throws {
    try check(decode: NilUInts())
  }

  func testCustom() throws {
    try check(decode: Custom())
  }

  func testOptCustom() throws {
    try check(decode: OptCustom())
  }

  func testNilCustom() throws {
    try check(decode: NilCustom())
  }

  func testArrays() throws {
    try check(decode: Arrays())
  }

  func testDicts() throws {
    try check(decode: Dicts())
  }

  func testFloats() throws {
    try check(decode: Floats())
  }

  func testComplex() throws {
    try check(decode: Complex(), canSerialize: false)
  }

  func testInfinitFloats() throws {
    try check(decode: InfinitFloats(), canSerialize: false)
  }

  func testDataValues() throws {
    try check(decode: DataValues())
  }

  func testDateValues() throws {
    try check(decode: DateValues())
  }

  func testParseNil() throws {
    try check(decode: nil as Int?)
  }

  func testParseNull() throws {
    try check(decode: Enigma.null)
  }

  func testParseInt() throws {
    try check(decode: -42)
  }

  func testParseUInt() throws {
    try check(decode: 42 as UInt)
  }

  func testParseString() throws {
    try check(decode: "Hello World!")
  }

  func testParseBool() throws {
    try check(decode: true)
  }

  func testParseDict() throws {
    try check(decode: [1: [:], 2: ["": ""]])
  }

  func testParseArray() throws {
    try check(decode: [[], [[]], [[1]], [[2, 2], [3, 3, 3]]])
  }

  func testAnyHashable() throws {
    let key1 = "café"
    let key2 = "cafe\u{301}"
    XCTAssertNotEqual(key1 as NSString, key2 as NSString)
    XCTAssertEqual(key1, key2)
    let enigma1 = try Enigma(cast: [key1: 1])
    let enigma2 = try Enigma(cast: [key2: 1])
    XCTAssertEqual(enigma1, enigma2)
    XCTAssertEqual(enigma1.asAnyObject, enigma2.asAnyObject)
  }

  func testSupers() throws {
    try check(decode: ParentKeyed.DefaultKeyedChild(int: 42))
    try check(decode: ParentKeyed.CustomKeyedChild(int: 42))
    try check(decode: ParentKeyed.ValueUnkeyedChild(int: 42))
    try check(decode: ParentKeyed.ArrayUnkeyedChild(int: 42))

    try check(decode: ParentKeyed.DefaultKeyedChild(int: nil))
    try check(decode: ParentKeyed.CustomKeyedChild(int: nil))
    try check(decode: ParentKeyed.ValueUnkeyedChild(int: nil))
    try check(decode: ParentKeyed.ArrayUnkeyedChild(int: nil))

    try check(decode: ParentUnkeyed.DefaultKeyedChild(ints: [42]))
    try check(decode: ParentUnkeyed.CustomKeyedChild(ints: [42]))
    try check(decode: ParentUnkeyed.ValueUnkeyedChild(ints: [42]))
    try check(decode: ParentUnkeyed.ArrayUnkeyedChild(ints: [42]))

    try check(decode: ParentUnkeyed.DefaultKeyedChild(ints: []))
    try check(decode: ParentUnkeyed.CustomKeyedChild(ints: []))
    try check(decode: ParentUnkeyed.ValueUnkeyedChild(ints: []))
    try check(decode: ParentUnkeyed.ArrayUnkeyedChild(ints: []))

    try check(decode: ParentValue.DefaultKeyedChild(int: 42))
    try check(decode: ParentValue.CustomKeyedChild(int: 42))
    try check(decode: ParentValue.ValueUnkeyedChild(int: 42))
    try check(decode: ParentValue.ArrayUnkeyedChild(int: 42))

    try check(decode: ParentValue.DefaultKeyedChild(int: nil))
    try check(decode: ParentValue.CustomKeyedChild(int: nil))
    try check(decode: ParentValue.ValueUnkeyedChild(int: nil))
    try check(decode: ParentValue.ArrayUnkeyedChild(int: nil))
  }

  func testNinja() throws {
    let ninja = Ninja()
    XCTAssertThrowsError(try Helper.enjson(ninja))
    XCTAssertThrowsError(try Enigma(encode: ninja))
  }
}
