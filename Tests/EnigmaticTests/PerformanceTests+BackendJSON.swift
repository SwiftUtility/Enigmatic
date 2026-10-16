import Foundation
import XCTest
@testable import Enigmatic

extension PerformanceTests {
  func testBackendJSONEncoding() throws {
    let model = BackendResponse()
    let encoder = JSONEncoder()
    // Codec sorts keys too, so all encoders perform the same ordering work.
    encoder.outputFormatting = [.sortedKeys]
    let bytes = try encoder.encode(model)
    let tree = try Enigma(encode: model)
    let object = try tree.asJsonObject
    let string = try Codec.encode(json: tree)
    let modelToTree = BenchmarkStage("model -> tree", { try Enigma(encode: model).asDictionary?.count ?? 0 })
    let stages: [[BenchmarkStage]] = [
      [],
      [modelToTree, BenchmarkStage("tree -> Data", { try encoder.encode(tree).count })],
      [modelToTree, BenchmarkStage("tree -> Data", { try Codec.encode(json: tree, as: .utf8).count })],
      [
        modelToTree,
        BenchmarkStage("tree -> String", { try Codec.encode(json: tree).utf8.count }),
        BenchmarkStage("String -> Data", { Data(string.utf8).count }),
      ],
      [
        modelToTree,
        BenchmarkStage("tree -> object", { try (tree.asJsonObject as? [String: Any])?.count ?? 0 }),
        BenchmarkStage("object -> Data", {
          try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys]).count
        }),
      ],
    ]
    let paths: [(name: String, encode: () throws -> Data)] = [
      ("JSONEncoder: model -> Data", {
        try encoder.encode(model)
      }),
      ("Enigma + JSONEncoder: model -> tree -> Data", {
        try encoder.encode(Enigma(encode: model))
      }),
      ("Enigma + Codec Data: model -> tree -> Data", {
        try Codec.encode(json: Enigma(encode: model), as: .utf8)
      }),
      ("Enigma + Codec String: model -> tree -> String -> Data", {
        Data(try Codec.encode(json: Enigma(encode: model)).utf8)
      }),
      ("Enigma + JSONSerialization: model -> tree -> object -> Data", {
        try JSONSerialization.data(
          withJSONObject: Enigma(encode: model).asJsonObject, options: [.sortedKeys]
        )
      }),
    ]
    // Validate every complete pipeline before starting any measurements.
    for path in paths {
      XCTAssertEqual(try JSONDecoder().decode(BackendResponse.self, from: path.encode()), model, path.name)
    }
    try benchmark(
      "BackendResponse JSON encoding (sorted keys, \(bytes.count) UTF-8 bytes, \(model.data.count) orders)",
      paths: paths.enumerated().map { index, path in
        BenchmarkPath(path.name, { try path.encode().count }, stages: stages[index])
      }
    )
  }

  func testBackendJSONDecoding() throws {
    let model = BackendResponse()
    let bytes = try JSONEncoder().encode(model)
    let decoder = JSONDecoder()
    let tree = try Codec.decode(json: bytes, as: .utf8)
    let string = String(decoding: bytes, as: UTF8.self)
    let object = try JSONSerialization.jsonObject(with: bytes)
    let treeToModel = BenchmarkStage("tree -> model", { try tree.decode(BackendResponse.self).data.count })
    let stages: [[BenchmarkStage]] = [
      [],
      [
        BenchmarkStage("Data -> tree", { try decoder.decode(Enigma.self, from: bytes).asDictionary?.count ?? 0 }),
        treeToModel,
      ],
      [
        BenchmarkStage("Data -> tree", { try Codec.decode(json: bytes, as: .utf8).asDictionary?.count ?? 0 }),
        treeToModel,
      ],
      [
        BenchmarkStage("Data -> String", { String(decoding: bytes, as: UTF8.self).utf8.count }),
        BenchmarkStage("String -> tree", { try Codec.decode(json: string).asDictionary?.count ?? 0 }),
        treeToModel,
      ],
      [
        BenchmarkStage("Data -> object", { try (JSONSerialization.jsonObject(with: bytes) as? [String: Any])?.count ?? 0 }),
        BenchmarkStage("object -> tree", { try Enigma(cast: object).asDictionary?.count ?? 0 }),
        treeToModel,
      ],
    ]
    let paths: [(name: String, decode: () throws -> BackendResponse)] = [
      ("JSONDecoder: Data -> model", {
        try decoder.decode(BackendResponse.self, from: bytes)
      }),
      ("JSONDecoder + Enigma: Data -> tree -> model", {
        try decoder.decode(Enigma.self, from: bytes).decode(BackendResponse.self)
      }),
      ("Codec Data + Enigma: Data -> tree -> model", {
        try Codec.decode(json: bytes, as: .utf8).decode(BackendResponse.self)
      }),
      ("Codec String + Enigma: Data -> String -> tree -> model", {
        try Codec.decode(json: String(decoding: bytes, as: UTF8.self)).decode(BackendResponse.self)
      }),
      ("JSONSerialization + Enigma: Data -> object -> tree -> model", {
        try Enigma(cast: JSONSerialization.jsonObject(with: bytes)).decode(BackendResponse.self)
      }),
    ]
    for path in paths {
      XCTAssertEqual(try path.decode(), model, path.name)
    }
    try benchmark(
      "BackendResponse JSON decoding (\(bytes.count) UTF-8 bytes, \(model.data.count) orders)",
      paths: paths.enumerated().map { index, path in
        BenchmarkPath(path.name, { try path.decode().data.count }, stages: stages[index])
      }
    )
  }

}
