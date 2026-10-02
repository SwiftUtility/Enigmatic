import Foundation
import XCTest
@testable import Enigmatic

final class SerializationContractTests: XCTestCase {
  func testJSONAndPlistErrorPaths() throws {
    for value in [Enigma.data(Data()), .date(Date()), .double(.infinity), .float(.nan)] {
      let tree: Enigma = ["values": .array([value])]
      XCTAssertEqual(try Enigma(cast: tree.rawAny), tree)
      XCTAssertThrowsError(try tree.jsonObject) { error in
        guard case EncodingError.invalidValue(_, let context) = error else { return XCTFail("\(error)") }
        XCTAssertEqual(context.codingPath.map(Enigma.Pin.init), ["values", 0])
      }
    }
    let tree: Enigma = ["values": [nil]]
    XCTAssertThrowsError(try tree.plistObject) { error in
      guard case EncodingError.invalidValue(_, let context) = error else { return XCTFail("\(error)") }
      XCTAssertEqual(context.codingPath.map(Enigma.Pin.init), ["values", 0])
    }
    XCTAssertEqual(try Enigma(cast: tree.jsonObject), tree)
  }

  func testSerializationAndFoundationBridging() throws {
    let tree: Enigma = ["list": [.bool(true), .int8(-1), .uint64(.max), .double(1.25), "text"], "empty": [:]]
    XCTAssertEqual(try Enigma(cast: tree.rawAny), tree)
    XCTAssertEqual(try Enigma(cast: tree.jsonObject), tree)
    let bytes = try JSONSerialization.data(withJSONObject: tree.jsonObject)
    XCTAssertEqual(try Enigma(cast: JSONSerialization.jsonObject(with: bytes)), tree)
    let plist: Enigma = ["date": .date(Date(timeIntervalSince1970: 0)), "data": .data(Data([0, 255]))]
    for format in [PropertyListSerialization.PropertyListFormat.xml, .binary] {
      let data = try PropertyListSerialization.data(fromPropertyList: plist.plistObject, format: format, options: 0)
      XCTAssertEqual(try Enigma(cast: PropertyListSerialization.propertyList(from: data, format: nil)), plist)
    }
    XCTAssertEqual(try Enigma(cast: NSNumber(value: true)).asBool, true)
    XCTAssertEqual(try Enigma(cast: NSNumber(value: 2)).asInt, 2)
    XCTAssertEqual(try Enigma(cast: NSNull()), .null)
    XCTAssertEqual(try Enigma(cast: nil), .null)
  }

  func testUnsupportedObjectsAndCollidingKeysReportErrors() {
    struct Unsupported {}
    assertDecodingError("dataCorrupted", path: ["items", 0]) {
      _ = try Enigma(cast: ["items": [Unsupported()]])
    }
    let keys: [AnyHashable: Any] = [AnyHashable(1): true, AnyHashable("1"): false]
    assertDecodingError("dataCorrupted", path: []) { _ = try Enigma(cast: keys) }
  }

  @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
  func testInt128NativeValuesAndSerializationRestrictions() throws {
    for value in [Int128.min, -1, 0, 1, Int128.max] {
      let tree = try Enigma(encode: value)
      XCTAssertEqual(tree.rawAny as? Int128, value)
      XCTAssertEqual(try tree.decode(Int128.self), value)
      XCTAssertEqual(try Enigma(cast: tree.rawAny), tree)
      XCTAssertEqual(tree.description, String(describing: value))
      XCTAssertEqual(tree.debugDescription, String(reflecting: value))
      XCTAssertThrowsError(try tree.jsonObject)
      XCTAssertThrowsError(try tree.plistObject)
    }
    for value in [UInt128.min, 1, UInt128.max] {
      let tree = try Enigma(encode: value)
      XCTAssertEqual(tree.rawAny as? UInt128, value)
      XCTAssertEqual(try tree.decode(UInt128.self), value)
      XCTAssertEqual(try Enigma(cast: tree.rawAny), tree)
      XCTAssertEqual(tree.description, String(describing: value))
      XCTAssertEqual(tree.debugDescription, String(reflecting: value))
      XCTAssertThrowsError(try tree.jsonObject)
      XCTAssertThrowsError(try tree.plistObject)
    }
  }
}
