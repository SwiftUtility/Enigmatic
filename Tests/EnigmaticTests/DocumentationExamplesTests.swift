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
    let merged = original.merging(patch, replace: true)
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

  func testConsumerCodingPathsPreserveBothKeyRepresentations() throws {
    enum Key: Int, CodingKey { case item = 7 }
    struct Leaf: Codable {
      init() {}
      init(from decoder: any Decoder) throws {
        XCTAssertEqual(decoder.codingPath.map(\.stringValue), ["item"])
        XCTAssertEqual(decoder.codingPath.map(\.intValue), [7])
        _ = try decoder.singleValueContainer().decode(Int.self)
      }
      func encode(to encoder: any Encoder) throws {
        XCTAssertEqual(encoder.codingPath.map(\.stringValue), ["item"])
        XCTAssertEqual(encoder.codingPath.map(\.intValue), [7])
        var single = encoder.singleValueContainer()
        try single.encode(42)
      }
    }
    struct Model: Codable {
      init() {}
      init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: Key.self)
        let child = try c.superDecoder(forKey: .item)
        XCTAssertEqual(child.codingPath.map(\.stringValue), ["item"])
        XCTAssertEqual(child.codingPath.map(\.intValue), [7])
        _ = try c.decode(Leaf.self, forKey: .item)
      }
      func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: Key.self)
        try c.encode(Leaf(), forKey: .item)
        XCTAssertThrowsError(try c.encode(0, forKey: .item)) { error in
          guard case EncodingError.invalidValue(_, let context) = error else { return XCTFail("\(error)") }
          XCTAssertEqual(context.codingPath.map(\.stringValue), ["item"])
          XCTAssertEqual(context.codingPath.map(\.intValue), [7])
        }
        var nested = c.nestedContainer(keyedBy: Key.self, forKey: .item)
        XCTAssertThrowsError(try nested.encode(0, forKey: .item)) { error in
          guard case EncodingError.invalidValue(_, let context) = error else { return XCTFail("\(error)") }
          XCTAssertEqual(context.codingPath.map(\.stringValue), ["item", "item"])
          XCTAssertEqual(context.codingPath.map(\.intValue), [7, 7])
        }
      }
    }
    struct Nested: Decodable {
      init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: Key.self)
        let child = try c.nestedContainer(keyedBy: Key.self, forKey: .item)
        XCTAssertEqual(child.codingPath.map(\.stringValue), ["item"])
        XCTAssertEqual(child.codingPath.map(\.intValue), [7])
        _ = try child.decode(Int.self, forKey: .item)
      }
    }
    let tree = try Enigma(encode: Model())
    XCTAssertEqual(tree, ["item": 42])
    _ = try tree.decode(Model.self)
    XCTAssertThrowsError(try Enigma.dictionary(["item": "wrong"]).decode(Model.self)) { error in
      guard case DecodingError.typeMismatch(_, let context) = error else { return XCTFail("\(error)") }
      XCTAssertEqual(context.codingPath.map(\.stringValue), ["item"])
      XCTAssertEqual(context.codingPath.map(\.intValue), [7])
    }
    XCTAssertThrowsError(try Enigma.dictionary(["item": ["item": "wrong"]]).decode(Nested.self)) { error in
      guard case DecodingError.typeMismatch(_, let context) = error else { return XCTFail("\(error)") }
      XCTAssertEqual(context.codingPath.map(\.stringValue), ["item", "item"])
      XCTAssertEqual(context.codingPath.map(\.intValue), [7, 7])
    }
  }

  func testConsumerDistinguishesMissingNullAndMismatchedValues() throws {
    struct Model: Decodable {
      enum Key: String, CodingKey { case value }
      init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: Key.self)
        _ = try c.decodeNil(forKey: .value)
        _ = try c.decode(Int.self, forKey: .value)
      }
    }
    let cases: [(Enigma, String)] = [([:], "missing"), (["value": nil], "null"), (["value": "wrong"], "mismatch")]
    for (tree, expected) in cases {
      XCTAssertThrowsError(try tree.decode(Model.self)) { error in
        switch (expected, error) {
        case ("missing", DecodingError.keyNotFound(let key, let context)):
          XCTAssertEqual(key.stringValue, "value")
          XCTAssertTrue(context.codingPath.isEmpty)
        case ("null", DecodingError.valueNotFound(let type, let context)),
             ("mismatch", DecodingError.typeMismatch(let type, let context)):
          XCTAssertTrue(type == Int.self)
          XCTAssertEqual(context.codingPath.map(\.stringValue), ["value"])
        default: XCTFail("Unexpected \(error) for \(expected)")
        }
      }
    }
  }
}
