import Foundation
import XCTest
@testable import Enigmatic

final class BackendResponseTests: XCTestCase {
  func testJSONFixture() throws {
    let model = BackendResponse()
    let bytes = try JSONEncoder().encode(model)
    XCTAssertTrue((950_000...1_150_000).contains(bytes.count), "Fixture size: \(bytes.count) bytes")
    XCTAssertEqual(model, BackendResponse())
    XCTAssertEqual(model.pagination.pageSize, model.data.count)
    XCTAssertEqual(try JSONDecoder().decode(BackendResponse.self, from: bytes), model)

    let tree = try Enigma(encode: model)
    XCTAssertEqual(try Codec.decode(json: bytes, as: .utf8), tree)
    let json = try Codec.encode(json: tree, as: .utf8)
    XCTAssertEqual(try JSONDecoder().decode(BackendResponse.self, from: json), model)
    XCTAssertEqual(try tree.decode(BackendResponse.self), model)

    let object = try XCTUnwrap(JSONSerialization.jsonObject(with: bytes) as? [String: Any])
    let orders = try XCTUnwrap(object["data"] as? [[String: Any]])
    let customer = try XCTUnwrap(orders.first?["customer"] as? [String: Any])
    XCTAssertTrue(customer["phone"] is NSNull)
    XCTAssertTrue(orders.first?["tracking"] is NSNull)
    XCTAssertTrue(orders.first?["comment"] is NSNull)
  }
}
