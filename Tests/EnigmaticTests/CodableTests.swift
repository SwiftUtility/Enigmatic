@testable import Enigmatic
import Foundation
import XCTest

final class CodableTests: XCTestCase {
  func testMaxInts() throws {
    Checker().check(value: MaxInts())
    Checker().check(value: MaxInts())
  }

  func testMinInts() throws {
    Checker().check(value: MinInts())
  }

  func testOptInts() throws {
    Checker().check(value: OptInts())
  }

  func testNilInts() throws {
    Checker().check(value: NilInts())
  }

  func testMaxUInts() throws {
    Checker().check(value: MaxUInts())
  }

  func testOptUInts() throws {
    Checker().check(value: OptUInts())
  }

  func testNilUInts() throws {
    Checker().check(value: NilUInts())
  }

  func testCustom() throws {
    Checker().check(value: Custom())
  }

  func testOptCustom() throws {
    Checker().check(value: OptCustom())
  }

  func testNilCustom() throws {
    Checker().check(value: NilCustom())
  }

  func testArrays() throws {
    Checker().check(value: Arrays())
  }

  func testDicts() throws {
    Checker().check(value: Dicts())
  }

  func testFloats() throws {
    Checker().check(value: Floats())
  }

  func testComplex() throws {
    Checker(nonConformingFloats: true, hasData: true, hasDates: true).check(value: Complex())
  }

  func testInfinitFloats() throws {
    Checker(nonConformingFloats: true).check(value: InfinitFloats())
  }

  func testDataValues() throws {
    Checker(hasData: true).check(value: DataValues())
  }

  func testDateValues() throws {
    Checker(hasDates: true).check(value: DateValues())
  }

  func testParseNil() throws {
    Checker(topLevelNil: true).check(value: nil as Int?)
  }

  func testParseNull() throws {
    Checker(topLevelNil: true).check(value: Enigma.null)
  }

  func testParseInt() throws {
    Checker().check(value: -42)
  }

  func testParseUInt() throws {
    Checker().check(value: 42 as UInt)
  }

  func testParseString() throws {
    Checker().check(value: "Hello World!")
  }

  func testParseBool() throws {
    Checker().check(value: true)
  }

  func testParseDict() throws {
    Checker().check(value: [1: [:], 2: ["": ""]])
  }

  func testParseArray() throws {
    Checker().check(value: [[], [[]], [[1]], [[2, 2], [3, 3, 3]]])
  }

  func testAnyHashable() throws {
    let key1 = "café"
    let key2 = "cafe\u{301}"
    #if os(anyAppleOS)
    XCTAssertNotEqual(key1 as NSString, key2 as NSString)
    #endif
    XCTAssertEqual(key1, key2)
    let enigma1 = try Enigma(cast: [key1: 1])
    let enigma2 = try Enigma(cast: [key2: 1])
    XCTAssertEqual(enigma1, enigma2)
    XCTAssertEqual(enigma1.rawObject, enigma2.rawObject)
  }

  func testSupers() throws {
    Checker().check(value: ParentKeyed.DefaultKeyedChild(int: 42))
    Checker().check(value: ParentKeyed.CustomKeyedChild(int: 42))
    Checker().check(value: ParentKeyed.ValueUnkeyedChild(int: 42))
    Checker().check(value: ParentKeyed.ArrayUnkeyedChild(int: 42))

    Checker().check(value: ParentKeyed.DefaultKeyedChild(int: nil))
    Checker().check(value: ParentKeyed.CustomKeyedChild(int: nil))
    Checker().check(value: ParentKeyed.ValueUnkeyedChild(int: nil))
    Checker().check(value: ParentKeyed.ArrayUnkeyedChild(int: nil))

    Checker().check(value: ParentUnkeyed.DefaultKeyedChild(ints: [42]))
    Checker().check(value: ParentUnkeyed.CustomKeyedChild(ints: [42]))
    Checker().check(value: ParentUnkeyed.ValueUnkeyedChild(ints: [42]))
    Checker().check(value: ParentUnkeyed.ArrayUnkeyedChild(ints: [42]))

    Checker().check(value: ParentUnkeyed.DefaultKeyedChild(ints: []))
    Checker().check(value: ParentUnkeyed.CustomKeyedChild(ints: []))
    Checker().check(value: ParentUnkeyed.ValueUnkeyedChild(ints: []))
    Checker().check(value: ParentUnkeyed.ArrayUnkeyedChild(ints: []))

    Checker(hasDeepNulls: true).check(value: ParentUnkeyed.DefaultKeyedChild(ints: [nil]))
    Checker(hasDeepNulls: true).check(value: ParentUnkeyed.CustomKeyedChild(ints: [nil]))
    Checker(hasDeepNulls: true).check(value: ParentUnkeyed.ValueUnkeyedChild(ints: [nil]))
    Checker(hasDeepNulls: true).check(value: ParentUnkeyed.ArrayUnkeyedChild(ints: [nil]))

    Checker().check(value: ParentValue.DefaultKeyedChild(int: 42))
    Checker().check(value: ParentValue.CustomKeyedChild(int: 42))
    Checker().check(value: ParentValue.ValueUnkeyedChild(int: 42))
    Checker().check(value: ParentValue.ArrayUnkeyedChild(int: 42))

    Checker(hasDeepNulls: true).check(value: ParentValue.DefaultKeyedChild(int: nil))
    Checker(hasDeepNulls: true).check(value: ParentValue.CustomKeyedChild(int: nil))
    Checker(hasDeepNulls: true).check(value: ParentValue.ValueUnkeyedChild(int: nil))
    Checker(hasDeepNulls: true).check(value: ParentValue.ArrayUnkeyedChild(int: nil))
  }

  func testNinja() throws {
    let ninja = Ninja()
    let ninjabox = Box(value: ninja)
    XCTAssertThrowsError(try Coder.encode(ninja, \.simpleJson))
    XCTAssertThrowsError(try Coder.encode(ninja, \.xmlPlistEncoder))
    XCTAssertThrowsError(try Coder.encode(ninja, \.binaryPlistEncoder))
    XCTAssertThrowsError(try Enigma(encode: ninja))

    XCTAssertNoThrow(try Coder.encode(ninjabox, \.simpleJson))
    XCTAssertNoThrow(try Coder.encode(ninjabox, \.xmlPlistEncoder))
    XCTAssertNoThrow(try Coder.encode(ninjabox, \.binaryPlistEncoder))
    XCTAssertNoThrow(try Enigma(encode: ninjabox))
    let direct = try String(data: Coder.encode(ninjabox, \.simpleJson), encoding: .utf8)
    let indirect = try String(data: Coder.encode(Enigma(encode: ninjabox), \.simpleJson), encoding: .utf8)
    XCTAssertEqual(direct, indirect)
  }

  @available(anyAppleOS 26, *)
  func testUnixTime() throws {
    struct CodecDates: Codable, Equatable {
      @Codec<Enigma.UnixDate<0>>
      var codecDateSeconds = Date(timeIntervalSince1970: 1789485877)
      @Codec<Enigma.UnixDate<3>>
      var codecDateMilliseconds = Date(timeIntervalSince1970: 1789485877)
    }
    let codecDates = CodecDates()
    XCTAssertEqual(
      try Enigma.UnixDate<0>.encode(value: codecDates.codecDateSeconds),
      codecDates.codecDateSeconds.timeIntervalSince1970
    )
    XCTAssertEqual(
      try Enigma.UnixDate<3>.encode(value: codecDates.codecDateSeconds),
      codecDates.codecDateSeconds.timeIntervalSince1970 * pow(10.0, Double(3 as Int))
    )
    Checker().check(value: codecDates)
  }
}
