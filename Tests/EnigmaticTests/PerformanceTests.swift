@testable import Enigmatic
import Foundation
import XCTest

final class PerformanceTests: XCTestCase {
  func measureAvarage<T>(run count: Int = 1000, _ block: () throws -> T, call: StaticString = #function) rethrows {
    _ = try block()
    let start = DispatchTime.now()
    for _ in 0..<count {
      try autoreleasepool {
        _ = try block()
      }
    }
    let end = DispatchTime.now()
    let time = Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / Double(count)
    let formatted = time.formatted(.number.precision(.fractionLength(3)))
    print("Performance of \(call): \(formatted) ns")
  }

  func testDecodeJsonDirect() throws {
    let value = try Helper.enjson(Regular())
    try measureAvarage { try Helper.dejson(Regular.self, from: value) }
  }

  func testDecodeXmlPlistDirect() throws {
    let value = try Helper.enxml(Regular())
    try measureAvarage { try Helper.deplist(Regular.self, from: value) }
  }

  func testDecodeBinPlistDirect() throws {
    let value = try Helper.enbin(Regular())
    try measureAvarage { try Helper.deplist(Regular.self, from: value) }
  }

  func testDecodeJsonEnigma() throws {
    let value = try Helper.enjson(Regular())
    try measureAvarage { try Helper.dejson(Enigma.self, from: value) }
  }

  func testDecodeXmlPlistEnigma() throws {
    let value = try Helper.enxml(Regular())
    try measureAvarage { try Helper.deplist(Enigma.self, from: value) }
  }

  func testDecodeBinPlistEnigma() throws {
    let value = try Helper.enbin(Regular())
    try measureAvarage { try Helper.deplist(Enigma.self, from: value) }
  }

  func testDeserializeJson() throws {
    let value = try Helper.enjson(Regular())
    try measureAvarage { try Helper.deserialize(value) }
  }

  func testCastEnigma() throws {
    let value = try Helper.deserialize(Helper.enjson(Regular()))
    try measureAvarage { try Enigma(cast: value) }
  }

  func testDecodeEnigma() throws {
    let value = try Enigma(encode: Regular())
    try measureAvarage { try value.decode(Regular.self) }
  }

  func testEncodeJsonDirect() throws {
    let value = Regular()
    try measureAvarage { try Helper.enjson(value) }
  }

  func testEncodeJsonEnigma() throws {
    let value = try Enigma(encode: Regular())
    try measureAvarage { try Helper.enjson(value) }
  }

  func testEncodeXmlDirect() throws {
    let value = Regular()
    try measureAvarage { try Helper.enxml(value) }
  }

  func testEncodeXmlEnigma() throws {
    let value = try Enigma(encode: Regular())
    try measureAvarage { try Helper.enxml(value) }
  }

  func testEncodeBinDirect() throws {
    let value = Regular()
    try measureAvarage { try Helper.enbin(value) }
  }

  func testEncodeBinEnigma() throws {
    let value = try Enigma(encode: Regular())
    try measureAvarage { try Helper.enbin(value) }
  }

  func testEncodeEnigma() throws {
    let value = Regular()
    try measureAvarage { try Enigma(encode: value) }
  }

  func testSerializeEnigma() throws {
    let value = try Enigma(encode: Regular()).anyObject
    try measureAvarage { try Helper.serialize(value) }
  }

  func testAnyObjectEnigma() throws {
    let value = try Enigma(encode: Regular())
    measureAvarage { value.anyObject }
  }
}
