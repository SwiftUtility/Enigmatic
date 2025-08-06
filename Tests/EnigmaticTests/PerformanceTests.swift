@testable import Enigmatic
import Foundation
import XCTest

final class PerformanceTests: XCTestCase {
  func measureAvarage(run count: Int = 1000, _ block: () throws -> Void) rethrows -> Double {
    try block()
    let start = DispatchTime.now()
    for _ in 0..<count { try block() }
    let end = DispatchTime.now()
    return Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000 / Double(count)
  }

  func testDecodeingTime() throws {
    let json = try Helper.enjson(Complex())

    let direct = try measureAvarage {
      _ = try Helper.dejson(Complex.self, from: json)
    }

    let decode = try measureAvarage {
      _ = try Helper.dejson(Enigma.self, from: json)
    }

    let serialize = try measureAvarage {
      _ = try Enigma(cast: Helper.deserialize(json))
    }

    decode.between(direct * 16, and: direct * 64)
    serialize.between(direct * 2, and: direct * 8)
  }

  func testEncodingTime() throws {
    let regular = Regular()
    let enigma = try Enigma(encode: regular)

    let direct = try measureAvarage {
      _ = try Helper.enjson(regular)
    }

    let encode = try measureAvarage {
      _ = try Helper.enjson(enigma)
    }

    let serialize = try measureAvarage {
      _ = try Helper.serialize(enigma.asAnyObject)
    }

    encode.between(direct * 0.5, and: direct * 2)
    serialize.between(direct * 0.5, and: direct * 2)
  }
}

extension Double {
  func between(_ a: Double, and b: Double) {
    XCTAssertGreaterThan(self, a)
    XCTAssertLessThan(self, b)

  }
}
