import Foundation
import XCTest
import Enigmatic

final class DocumentationExamplesTests: XCTestCase {
  func testReadmeEditingExample() throws {
    struct User: Codable, Equatable {
      var name: String
      var scores: [Int]
    }
    var tree = try Enigma(encode: User(name: "Ada", scores: [10]))
    tree["scores", 1] = 20
    tree["name"] = "Grace"
    XCTAssertEqual(try tree.decode(User.self), User(name: "Grace", scores: [10, 20]))
    XCTAssertEqual(tree.allPaths, [["name"], ["scores"], ["scores", 0], ["scores", 1]])
  }

  func testReadmeMergeExample() {
    let original: Enigma = ["settings": ["enabled": false, "retries": 2]]
    let patch: Enigma = ["settings": ["enabled": true]]
    let merged = original.merging(patch, or: Enigma.replace)
    XCTAssertEqual(merged, ["settings": ["enabled": true, "retries": 2]])
  }

  func testReadmeStrategyExample() throws {
    struct Payload: Codable {
      @Codec.Box<Codec.Base64Data> var bytes: Data
      @Codec.Box<Codec.StringURL?> var link: URL?
    }
    let payload = Payload(bytes: Data([1, 2, 3]), link: nil)
    let tree = try Enigma(encode: payload)
    XCTAssertEqual(tree, ["bytes": "AQID", "link": nil])
    let restored = try tree.decode(Payload.self)
    XCTAssertEqual(restored.bytes, payload.bytes)
    XCTAssertNil(restored.link)
    XCTAssertThrowsError(try Enigma.dictionary(["bytes": "AQID"]).decode(Payload.self))
  }

  func testDocCTreeExample() {
    var tree: Enigma = ["items": [["name": "first"]]]
    tree["items", 1, "name"] = "second"
    tree["items", 0] = nil
    XCTAssertEqual(tree, ["items": [["name": "second"]]])
  }
}
