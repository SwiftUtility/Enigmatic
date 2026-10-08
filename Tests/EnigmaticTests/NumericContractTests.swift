import Foundation
import XCTest
@testable import Enigmatic

final class NumericContractTests: XCTestCase {
  @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
  func testIntegerBoundariesAndCanonicalConversions() throws {
    try checkIntegers(Int.self)
    try checkIntegers(Int8.self)
    try checkIntegers(Int16.self)
    try checkIntegers(Int32.self)
    try checkIntegers(Int64.self)
    try checkIntegers(UInt.self)
    try checkIntegers(UInt8.self)
    try checkIntegers(UInt16.self)
    try checkIntegers(UInt32.self)
    try checkIntegers(UInt64.self)
    try checkIntegers(Int128.self)
    try checkIntegers(UInt128.self)
  }

  @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
  private func checkIntegers<T: FixedWidthInteger & Codable>(_ type: T.Type) throws {
    for value in [T.min, 0, 1, T.max] {
      let tree = try Enigma(encode: value)
      XCTAssertEqual(try tree.decode(T.self), value, "\(type): \(value)")
      XCTAssertEqual(try Enigma(encode: [value]).decode([T].self), [value])
      XCTAssertEqual(try Enigma(encode: ["v": value]).decode([String: T].self), ["v": value])
      XCTAssertEqual(tree.asInt, Int(exactly: value), "\(type): \(value) -> Int")
      XCTAssertEqual(tree.asInt8, Int8(exactly: value), "\(type): \(value) -> Int8")
      XCTAssertEqual(tree.asInt16, Int16(exactly: value), "\(type): \(value) -> Int16")
      XCTAssertEqual(tree.asInt32, Int32(exactly: value), "\(type): \(value) -> Int32")
      XCTAssertEqual(tree.asInt64, Int64(exactly: value), "\(type): \(value) -> Int64")
      XCTAssertEqual(tree.asUInt, UInt(exactly: value), "\(type): \(value) -> UInt")
      XCTAssertEqual(tree.asUInt8, UInt8(exactly: value), "\(type): \(value) -> UInt8")
      XCTAssertEqual(tree.asUInt16, UInt16(exactly: value), "\(type): \(value) -> UInt16")
      XCTAssertEqual(tree.asUInt32, UInt32(exactly: value), "\(type): \(value) -> UInt32")
      XCTAssertEqual(tree.asUInt64, UInt64(exactly: value), "\(type): \(value) -> UInt64")
      XCTAssertEqual(tree.asInt128, Int128(exactly: value), "\(type): \(value) -> Int128")
      XCTAssertEqual(tree.asUInt128, UInt128(exactly: value), "\(type): \(value) -> UInt128")
      let roundedDouble = Double(value)
      if tree == .double(roundedDouble) {
        XCTAssertEqual(tree.asDouble, roundedDouble, "\(type): \(value) -> Double")
      } else {
        XCTAssertNil(tree.asDouble, "\(type): \(value) -> Double")
      }
      let roundedFloat = Float(value)
      if tree == .float(roundedFloat) {
        XCTAssertEqual(tree.asFloat, roundedFloat, "\(type): \(value) -> Float")
      } else {
        XCTAssertNil(tree.asFloat, "\(type): \(value) -> Float")
      }
      XCTAssertFalse(tree.description.isEmpty)
      XCTAssertFalse(tree.debugDescription.isEmpty)
      XCTAssertEqual(tree, tree)
    }
  }

  @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
  func testAllPrimitiveContainerOverloads() throws {
    let encoded = try Enigma(encode: EncodingProbe { encoder in
      var root = encoder.container(keyedBy: Enigma.Pin.self)
      var array = root.nestedUnkeyedContainer(forKey: "values")
      try array.encode(true)
      try array.encode("text")
      try array.encode(Int(1))
      try array.encode(Int8(1))
      try array.encode(Int16(1))
      try array.encode(Int32(1))
      try array.encode(Int64(1))
      try array.encode(UInt(1))
      try array.encode(UInt8(1))
      try array.encode(UInt16(1))
      try array.encode(UInt32(1))
      try array.encode(UInt64(1))
      try array.encode(Int128(1))
      try array.encode(UInt128(1))
      try array.encode(Double(1.5))
      try array.encode(Float(1.5))
    })
    var array = try EnigmaDecoder.decoder(enigma: encoded["values"]!, userInfo: [:]).unkeyedContainer()
    XCTAssertEqual(try array.decode(Bool.self), true)
    XCTAssertEqual(try array.decode(String.self), "text")
    XCTAssertEqual(try array.decode(Int.self), Int(1))
    XCTAssertEqual(try array.decode(Int8.self), Int8(1))
    XCTAssertEqual(try array.decode(Int16.self), Int16(1))
    XCTAssertEqual(try array.decode(Int32.self), Int32(1))
    XCTAssertEqual(try array.decode(Int64.self), Int64(1))
    XCTAssertEqual(try array.decode(UInt.self), UInt(1))
    XCTAssertEqual(try array.decode(UInt8.self), UInt8(1))
    XCTAssertEqual(try array.decode(UInt16.self), UInt16(1))
    XCTAssertEqual(try array.decode(UInt32.self), UInt32(1))
    XCTAssertEqual(try array.decode(UInt64.self), UInt64(1))
    XCTAssertEqual(try array.decode(Int128.self), Int128(1))
    XCTAssertEqual(try array.decode(UInt128.self), UInt128(1))
    XCTAssertEqual(try array.decode(Double.self), Double(1.5))
    XCTAssertEqual(try array.decode(Float.self), Float(1.5))
    XCTAssertTrue(array.isAtEnd)
    // A failed typed decode must neither advance nor consume the input.
    do {
      var invalid = try EnigmaDecoder.decoder(enigma: ["wrong"], userInfo: [:]).unkeyedContainer()
      assertDecodingError("typeMismatch", path: [0]) { _ = try invalid.decode(Bool.self) }
      XCTAssertEqual(invalid.currentIndex, 0)
      var empty = try EnigmaDecoder.decoder(enigma: [], userInfo: [:]).unkeyedContainer()
      assertDecodingError("valueNotFound", path: []) { _ = try empty.decode(Bool.self) }
    }
    do {
      var invalid = try EnigmaDecoder.decoder(enigma: [1], userInfo: [:]).unkeyedContainer()
      assertDecodingError("typeMismatch", path: [0]) { _ = try invalid.decode(String.self) }
      XCTAssertEqual(invalid.currentIndex, 0)
      var empty = try EnigmaDecoder.decoder(enigma: [], userInfo: [:]).unkeyedContainer()
      assertDecodingError("valueNotFound", path: []) { _ = try empty.decode(String.self) }
    }
    do {
      var invalid = try EnigmaDecoder.decoder(enigma: ["wrong"], userInfo: [:]).unkeyedContainer()
      assertDecodingError("typeMismatch", path: [0]) { _ = try invalid.decode(Int.self) }
      XCTAssertEqual(invalid.currentIndex, 0)
      var empty = try EnigmaDecoder.decoder(enigma: [], userInfo: [:]).unkeyedContainer()
      assertDecodingError("valueNotFound", path: []) { _ = try empty.decode(Int.self) }
    }
    do {
      var invalid = try EnigmaDecoder.decoder(enigma: ["wrong"], userInfo: [:]).unkeyedContainer()
      assertDecodingError("typeMismatch", path: [0]) { _ = try invalid.decode(Int8.self) }
      XCTAssertEqual(invalid.currentIndex, 0)
      var empty = try EnigmaDecoder.decoder(enigma: [], userInfo: [:]).unkeyedContainer()
      assertDecodingError("valueNotFound", path: []) { _ = try empty.decode(Int8.self) }
    }
    do {
      var invalid = try EnigmaDecoder.decoder(enigma: ["wrong"], userInfo: [:]).unkeyedContainer()
      assertDecodingError("typeMismatch", path: [0]) { _ = try invalid.decode(Int16.self) }
      XCTAssertEqual(invalid.currentIndex, 0)
      var empty = try EnigmaDecoder.decoder(enigma: [], userInfo: [:]).unkeyedContainer()
      assertDecodingError("valueNotFound", path: []) { _ = try empty.decode(Int16.self) }
    }
    do {
      var invalid = try EnigmaDecoder.decoder(enigma: ["wrong"], userInfo: [:]).unkeyedContainer()
      assertDecodingError("typeMismatch", path: [0]) { _ = try invalid.decode(Int32.self) }
      XCTAssertEqual(invalid.currentIndex, 0)
      var empty = try EnigmaDecoder.decoder(enigma: [], userInfo: [:]).unkeyedContainer()
      assertDecodingError("valueNotFound", path: []) { _ = try empty.decode(Int32.self) }
    }
    do {
      var invalid = try EnigmaDecoder.decoder(enigma: ["wrong"], userInfo: [:]).unkeyedContainer()
      assertDecodingError("typeMismatch", path: [0]) { _ = try invalid.decode(Int64.self) }
      XCTAssertEqual(invalid.currentIndex, 0)
      var empty = try EnigmaDecoder.decoder(enigma: [], userInfo: [:]).unkeyedContainer()
      assertDecodingError("valueNotFound", path: []) { _ = try empty.decode(Int64.self) }
    }
    do {
      var invalid = try EnigmaDecoder.decoder(enigma: ["wrong"], userInfo: [:]).unkeyedContainer()
      assertDecodingError("typeMismatch", path: [0]) { _ = try invalid.decode(UInt.self) }
      XCTAssertEqual(invalid.currentIndex, 0)
      var empty = try EnigmaDecoder.decoder(enigma: [], userInfo: [:]).unkeyedContainer()
      assertDecodingError("valueNotFound", path: []) { _ = try empty.decode(UInt.self) }
    }
    do {
      var invalid = try EnigmaDecoder.decoder(enigma: ["wrong"], userInfo: [:]).unkeyedContainer()
      assertDecodingError("typeMismatch", path: [0]) { _ = try invalid.decode(UInt8.self) }
      XCTAssertEqual(invalid.currentIndex, 0)
      var empty = try EnigmaDecoder.decoder(enigma: [], userInfo: [:]).unkeyedContainer()
      assertDecodingError("valueNotFound", path: []) { _ = try empty.decode(UInt8.self) }
    }
    do {
      var invalid = try EnigmaDecoder.decoder(enigma: ["wrong"], userInfo: [:]).unkeyedContainer()
      assertDecodingError("typeMismatch", path: [0]) { _ = try invalid.decode(UInt16.self) }
      XCTAssertEqual(invalid.currentIndex, 0)
      var empty = try EnigmaDecoder.decoder(enigma: [], userInfo: [:]).unkeyedContainer()
      assertDecodingError("valueNotFound", path: []) { _ = try empty.decode(UInt16.self) }
    }
    do {
      var invalid = try EnigmaDecoder.decoder(enigma: ["wrong"], userInfo: [:]).unkeyedContainer()
      assertDecodingError("typeMismatch", path: [0]) { _ = try invalid.decode(UInt32.self) }
      XCTAssertEqual(invalid.currentIndex, 0)
      var empty = try EnigmaDecoder.decoder(enigma: [], userInfo: [:]).unkeyedContainer()
      assertDecodingError("valueNotFound", path: []) { _ = try empty.decode(UInt32.self) }
    }
    do {
      var invalid = try EnigmaDecoder.decoder(enigma: ["wrong"], userInfo: [:]).unkeyedContainer()
      assertDecodingError("typeMismatch", path: [0]) { _ = try invalid.decode(UInt64.self) }
      XCTAssertEqual(invalid.currentIndex, 0)
      var empty = try EnigmaDecoder.decoder(enigma: [], userInfo: [:]).unkeyedContainer()
      assertDecodingError("valueNotFound", path: []) { _ = try empty.decode(UInt64.self) }
    }
    do {
      var invalid = try EnigmaDecoder.decoder(enigma: ["wrong"], userInfo: [:]).unkeyedContainer()
      assertDecodingError("typeMismatch", path: [0]) { _ = try invalid.decode(Int128.self) }
      XCTAssertEqual(invalid.currentIndex, 0)
      var empty = try EnigmaDecoder.decoder(enigma: [], userInfo: [:]).unkeyedContainer()
      assertDecodingError("valueNotFound", path: []) { _ = try empty.decode(Int128.self) }
    }
    do {
      var invalid = try EnigmaDecoder.decoder(enigma: ["wrong"], userInfo: [:]).unkeyedContainer()
      assertDecodingError("typeMismatch", path: [0]) { _ = try invalid.decode(UInt128.self) }
      XCTAssertEqual(invalid.currentIndex, 0)
      var empty = try EnigmaDecoder.decoder(enigma: [], userInfo: [:]).unkeyedContainer()
      assertDecodingError("valueNotFound", path: []) { _ = try empty.decode(UInt128.self) }
    }
    do {
      var invalid = try EnigmaDecoder.decoder(enigma: ["wrong"], userInfo: [:]).unkeyedContainer()
      assertDecodingError("typeMismatch", path: [0]) { _ = try invalid.decode(Double.self) }
      XCTAssertEqual(invalid.currentIndex, 0)
      var empty = try EnigmaDecoder.decoder(enigma: [], userInfo: [:]).unkeyedContainer()
      assertDecodingError("valueNotFound", path: []) { _ = try empty.decode(Double.self) }
    }
    do {
      var invalid = try EnigmaDecoder.decoder(enigma: ["wrong"], userInfo: [:]).unkeyedContainer()
      assertDecodingError("typeMismatch", path: [0]) { _ = try invalid.decode(Float.self) }
      XCTAssertEqual(invalid.currentIndex, 0)
      var empty = try EnigmaDecoder.decoder(enigma: [], userInfo: [:]).unkeyedContainer()
      assertDecodingError("valueNotFound", path: []) { _ = try empty.decode(Float.self) }
    }
  }

  @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
  func testNonNumericValuesAndFractionalConversions() {
    for value in [Enigma.null, .bool(true), .string("1"), .data(Data()), .date(Date()), .array([]), .dictionary([:])] {
      XCTAssertNil(value.asInt)
      XCTAssertNil(value.asInt8)
      XCTAssertNil(value.asInt16)
      XCTAssertNil(value.asInt32)
      XCTAssertNil(value.asInt64)
      XCTAssertNil(value.asUInt)
      XCTAssertNil(value.asUInt8)
      XCTAssertNil(value.asUInt16)
      XCTAssertNil(value.asUInt32)
      XCTAssertNil(value.asUInt64)
      XCTAssertNil(value.asInt128)
      XCTAssertNil(value.asUInt128)
      XCTAssertNil(value.asDouble)
      XCTAssertNil(value.asFloat)
    }
    for value in [Double(-1.5), 0, 1.5, .infinity, -.infinity, .nan, .greatestFiniteMagnitude] {
      let tree = Enigma.double(value)
      XCTAssertEqual(tree.asInt, Int(exactly: value))
      XCTAssertEqual(tree.asInt8, Int8(exactly: value))
      XCTAssertEqual(tree.asInt16, Int16(exactly: value))
      XCTAssertEqual(tree.asInt32, Int32(exactly: value))
      XCTAssertEqual(tree.asInt64, Int64(exactly: value))
      XCTAssertEqual(tree.asUInt, UInt(exactly: value))
      XCTAssertEqual(tree.asUInt8, UInt8(exactly: value))
      XCTAssertEqual(tree.asUInt16, UInt16(exactly: value))
      XCTAssertEqual(tree.asUInt32, UInt32(exactly: value))
      XCTAssertEqual(tree.asUInt64, UInt64(exactly: value))
      XCTAssertEqual(tree.asInt128, Int128(exactly: value))
      XCTAssertEqual(tree.asUInt128, UInt128(exactly: value))
      if value.isNaN { XCTAssertTrue(tree.asFloat?.isNaN == true) }
      else if value.isFinite && !Float(value).isFinite { XCTAssertNil(tree.asFloat) }
      else { XCTAssertEqual(tree.asFloat, Float(value)) }
    }
    XCTAssertNil(Enigma.int(-1).asUInt)
    XCTAssertNil(Enigma.uint64(.max).asInt64)
    XCTAssertNil(Enigma.int64(16_777_217).asFloat)
    XCTAssertNil(Enigma.int64(9_007_199_254_740_993).asDouble)
    XCTAssertEqual(Enigma.int64(1_000_000_000_000).asFloat, Float(1_000_000_000_000))
    XCTAssertEqual(Enigma.int64(1_000_000_000_000).asDouble, Double(1_000_000_000_000))
    XCTAssertEqual(Enigma.double(0.1).asFloat, Float(0.1))
    XCTAssertEqual(Enigma.float(0.1).asDouble, Double(0.1))
    XCTAssertNil(Enigma.double(Double(Float(0.1))).asFloat)
    XCTAssertEqual(Enigma.double(1e-45).asFloat, Float(1e-45))
    XCTAssertNil(Enigma.double(.leastNonzeroMagnitude).asFloat)
    XCTAssertNil(Enigma.double(Double(Float.greatestFiniteMagnitude).nextUp).asFloat)
    XCTAssertEqual(Enigma.double(.nan), .float(.nan))
    XCTAssertEqual(Enigma.float(.infinity), .double(.infinity))
    XCTAssertNotEqual(Enigma.float(.infinity), .double(.greatestFiniteMagnitude))
  }

  func testLiteralDownscalingAndDescriptions() {
    for value in [0, -1, 256, -129, 65_536, -32_769, 4_294_967_296, -2_147_483_649, Int.max, Int.min] {
      XCTAssertEqual(Enigma(integerLiteral: value).asInt, value)
      let tree = Enigma(floatLiteral: Double(value))
      if tree == .double(Double(value)) {
        XCTAssertEqual(tree.asDouble, Double(value))
      } else {
        XCTAssertNil(tree.asDouble)
      }
    }
    for value in [0.5, Double.pi, Double.greatestFiniteMagnitude] {
      XCTAssertEqual(Enigma(floatLiteral: value).asDouble, value)
    }
    let nothing: Enigma = nil
    let string: Enigma = "s"
    XCTAssertTrue(nothing.isNull)
    XCTAssertEqual(nothing.description, "null")
    XCTAssertEqual(string.description, "s")
    let values: [Enigma] = [.null, .bool(true), .string("text"), .data(Data([1])), .date(Date(timeIntervalSince1970: 0)), .array([1]), .dictionary(["a": 1])]
    for value in values {
      XCTAssertFalse(value.description.isEmpty)
      XCTAssertFalse(value.debugDescription.isEmpty)
    }
    var tree: Enigma = .null
    XCTAssertEqual(tree.array, [])
    XCTAssertEqual(tree.dictionary, [:])
    tree.array = [1]
    XCTAssertTrue(tree.isArray)
    XCTAssertFalse(tree.isDictionary)
    tree.dictionary = ["a": 1]
    XCTAssertTrue(tree.isDictionary)
    XCTAssertFalse(tree.isArray)
  }

  func testCanonicalFloatDoubleRoundTrips() {
    for (index, value) in [Float(1.1111111e38), -1.1111111e38, 1.5e-38, -1.5e-38, 0.1].enumerated() {
      guard let widened = NumberComponents(value).asDouble else {
        XCTFail("Float at index \(index) must convert to its canonical Double")
        continue
      }
      XCTAssertEqual(NumberComponents(widened).asFloat, value)
      XCTAssertEqual(Enigma.double(widened).asFloat, value)
    }
  }

  func testCanonicalNumericIdentityAcrossCases() {
    let floatPointOne = Enigma.float(0.1)
    XCTAssertEqual(floatPointOne, .double(0.1))
    XCTAssertNotEqual(floatPointOne, .double(Double(Float(0.1))))
    XCTAssertEqual(Enigma.double(0.1).asFloat, Float(0.1))
    XCTAssertNil(Enigma.double(Double(Float(0.1))).asFloat)
    XCTAssertEqual(Enigma.float(-0.0), .double(0.0))
  }
}
