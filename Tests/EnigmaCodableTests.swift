@testable import Enigmatic
import Foundation
import XCTest

final class EnigmaCodableTests: XCTestCase {
  lazy var jsonEncoder: JSONEncoder = {
    let result = JSONEncoder()
    result.nonConformingFloatEncodingStrategy = .convertToString(
      positiveInfinity: "Infinity", negativeInfinity: "-Infinity", nan: "NaN"
    )
    return result
  }()
  lazy var jsonDecoder: JSONDecoder = {
    let result = JSONDecoder()
    result.nonConformingFloatDecodingStrategy = .convertFromString(
      positiveInfinity: "Infinity", negativeInfinity: "-Infinity", nan: "NaN"
    )
    return result
  }()
  lazy var plistEncoder: PropertyListEncoder = {
    let result = PropertyListEncoder()
    result.outputFormat = .xml
    return result
  }()
  lazy var plistDecoder = PropertyListDecoder()

  func check<T: Codable & Equatable>(decode sample: T, exact: Bool = true) throws {
    let encoded = try Enigma(encode: sample)
    let decoded = try encoded.decode() as T
    XCTAssertEqual(sample, decoded)
    let enjsoned = try jsonEncoder.encode(encoded)
    let dejsoned = try jsonDecoder.decode(Enigma.self, from: enjsoned)
    if exact { XCTAssertEqual(encoded, dejsoned) }
    let jsoned = try dejsoned.decode() as T
    XCTAssertEqual(sample, jsoned)
    if encoded.asArray != nil || encoded.asDictionary != nil {
      let reference = try plistDecoder.decode(Enigma.self, from: plistEncoder.encode(sample))
      XCTAssertEqual(encoded, reference)
      let enplisted = try plistEncoder.encode(encoded)
      let deplisted = try plistDecoder.decode(Enigma.self, from: enplisted)
      XCTAssertEqual(encoded, deplisted)
      let plisted = try deplisted.decode() as T
      XCTAssertEqual(sample, plisted)
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

  func testEnigmaFloatKeyDict() throws {
    try check(decode: [.float(0.5): "0.5"] as [Enigma: String])
  }

  func testEnigmaDoubleKeyDict() throws {
    try check(decode: [.double(0.1): "0.1"] as [Enigma: String])
  }

  func testEnigmaBoolKeyDict() throws {
    try check(decode: [true: "true", false: "false"] as [Enigma: String])
  }

  func testFloats() throws {
    try check(decode: Floats(), exact: false)
  }

  func testComplex() throws {
    try check(decode: Complex(), exact: false)
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
    let enigma1 = try Enigma(parse: [key1: 1])
    let enigma2 = try Enigma(parse: [key2: 1])
    XCTAssertEqual(enigma1, enigma2)
  }

  func testSupers() throws {
    try check(decode: KeyedParent.DefaultKeyedChild(int: 42))
    try check(decode: KeyedParent.CustomKeyedChild(int: 42))
    try check(decode: KeyedParent.ValueUnkeyedChild(int: 42))
    try check(decode: KeyedParent.ArrayUnkeyedChild(int: 42))

    try check(decode: KeyedParent.DefaultKeyedChild(int: nil))
    try check(decode: KeyedParent.CustomKeyedChild(int: nil))
    try check(decode: KeyedParent.ValueUnkeyedChild(int: nil))
    try check(decode: KeyedParent.ArrayUnkeyedChild(int: nil))

    try check(decode: UnkeyedParent.DefaultKeyedChild(ints: [42]))
    try check(decode: UnkeyedParent.CustomKeyedChild(ints: [42]))
    try check(decode: UnkeyedParent.ValueUnkeyedChild(ints: [42]))
    try check(decode: UnkeyedParent.ArrayUnkeyedChild(ints: [42]))

    try check(decode: UnkeyedParent.DefaultKeyedChild(ints: []))
    try check(decode: UnkeyedParent.CustomKeyedChild(ints: []))
    try check(decode: UnkeyedParent.ValueUnkeyedChild(ints: []))
    try check(decode: UnkeyedParent.ArrayUnkeyedChild(ints: []))

    try check(decode: ValueParent.DefaultKeyedChild(int: 42))
    try check(decode: ValueParent.CustomKeyedChild(int: 42))
    try check(decode: ValueParent.ValueUnkeyedChild(int: 42))
    try check(decode: ValueParent.ArrayUnkeyedChild(int: 42))

    try check(decode: ValueParent.DefaultKeyedChild(int: nil))
    try check(decode: ValueParent.CustomKeyedChild(int: nil))
    try check(decode: ValueParent.ValueUnkeyedChild(int: nil))
    try check(decode: ValueParent.ArrayUnkeyedChild(int: nil))
  }

  func testNinja() throws {
    let ninja = Ninja()
    XCTAssertThrowsError(try jsonEncoder.encode(ninja))
    XCTAssertThrowsError(try Enigma(encode: ninja))
  }
}
