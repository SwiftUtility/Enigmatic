@testable import Enigmatic
import Foundation
import XCTest

final class PerformanceTests: XCTestCase {
  struct BenchmarkStage {
    var name: String
    var operation: () throws -> Int

    init(_ name: String, _ operation: @escaping () throws -> Int) {
      self.name = name
      self.operation = operation
    }
  }

  struct BenchmarkPath {
    var name: String
    var operation: () throws -> Int
    var stages: [BenchmarkStage]

    init(_ name: String, _ operation: @escaping () throws -> Int, stages: [BenchmarkStage] = []) {
      self.name = name
      self.operation = operation
      self.stages = stages
    }
  }

  /// Full paths and isolated stages are measured independently on prepared inputs.
  func benchmark(_ title: String, paths: [BenchmarkPath], samples: Int = 25) throws {
    precondition(!paths.isEmpty && samples > 0 && !samples.isMultiple(of: 2))
    var operations = paths.map { BenchmarkStage($0.name, $0.operation) }
    var stageIndices: [[Int]] = []
    for (index, path) in paths.enumerated() {
      if path.stages.isEmpty {
        stageIndices.append([index])
      } else {
        stageIndices.append(Array(operations.count..<(operations.count + path.stages.count)))
        operations.append(contentsOf: path.stages)
      }
    }
    var timings = Array(repeating: [Double](), count: operations.count)
    var checksum = 0
    for operation in operations {
      checksum &+= try autoreleasepool { try operation.operation() }
    }
    for sample in 0..<samples {
      for offset in operations.indices {
        let index = (offset + sample) % operations.count
        let start = DispatchTime.now().uptimeNanoseconds
        checksum &+= try autoreleasepool { try operations[index].operation() }
        let elapsed = DispatchTime.now().uptimeNanoseconds - start
        timings[index].append(Double(elapsed))
      }
    }
    XCTAssertGreaterThan(checksum, 0)
    let medians = timings.map { $0.sorted()[samples / 2] }
    print("\(title): median of \(samples) individual operations")
    print("  Time relative to baseline: 100% baseline, lower is faster")
    for index in paths.indices {
      let ratio = medians[index] / medians[0]
      let percentage = String(
        format: "%.3f%%", locale: Locale(identifier: "en_US_POSIX"), ratio * 100
      )
      let comparison: String
      if index == 0 {
        comparison = "\(percentage) | baseline"
      } else if ratio < 1 {
        comparison = "\(percentage) (\(number(1 / ratio))x faster)"
      } else {
        comparison = "\(percentage) (\(number(ratio))x slower)"
      }
      print("  \(paths[index].name) | \(comparison)")
      print("    Full path median: \(number(medians[index] / 1_000_000, precision: 6)) ms/op")
      for stage in stageIndices[index] {
        let name = operations[stage].name.components(separatedBy: ": ").last ?? operations[stage].name
        print("    \(name) median: \(number(medians[stage] / 1_000_000, precision: 6)) ms/op")
      }
    }
  }

  private func number(_ value: Double, precision: Int = 3) -> String {
    String(format: "%.*f", locale: Locale(identifier: "en_US_POSIX"), precision, value)
  }

  func testDictionaryStrategies() throws {
    struct MappedDictionary: Codable {
      let values: [String: Int]

      init(values: [String: Int]) { self.values = values }

      init(from decoder: any Decoder) throws {
        values = try [String: Codec.Box<Codec.Id<Int>>](from: decoder).mapValues(\.wrappedValue)
      }

      func encode(to encoder: any Encoder) throws {
        try values.mapValues { Codec.Box<Codec.Id<Int>>(wrappedValue: $0) }.encode(to: encoder)
      }
    }

    let values = Dictionary(uniqueKeysWithValues: (0..<10_000).map { ("key\($0)", $0) })
    let box = Codec.Box<[String: Codec.Id<Int>]>(wrappedValue: values)
    let mapped = MappedDictionary(values: values)
    let boxes = values.mapValues { Codec.Box<Codec.Id<Int>>(wrappedValue: $0) }
    let tree = try Enigma(encode: box)
    XCTAssertEqual(tree, try Enigma(encode: mapped))
    XCTAssertEqual(try tree.decode(type(of: box)).wrappedValue, values)
    XCTAssertEqual(try tree.decode(MappedDictionary.self).values, values)

    try benchmark("Dictionary encoding (10,000 entries)", paths: [
      BenchmarkPath("Dictionary strategy: values -> tree", {
        try Enigma(encode: box).asDictionary?.count ?? 0
      }),
      BenchmarkPath("Mapped boxes: values -> boxes -> tree", {
        try Enigma(encode: mapped).asDictionary?.count ?? 0
      }, stages: [
        BenchmarkStage("values -> boxes", { values.mapValues { Codec.Box<Codec.Id<Int>>(wrappedValue: $0) }.count }),
        BenchmarkStage("boxes -> tree", { try Enigma(encode: boxes).asDictionary?.count ?? 0 }),
      ]),
    ])
    try benchmark("Dictionary decoding (10,000 entries)", paths: [
      BenchmarkPath("Dictionary strategy: tree -> values", {
        try tree.decode(type(of: box)).wrappedValue.count
      }),
      BenchmarkPath("Mapped boxes: tree -> boxes -> values", {
        try tree.decode(MappedDictionary.self).values.count
      }, stages: [
        BenchmarkStage("tree -> boxes", { try tree.decode([String: Codec.Box<Codec.Id<Int>>].self).count }),
        BenchmarkStage("boxes -> values", { boxes.mapValues(\.wrappedValue).count }),
      ]),
    ])
  }

  /// Uses explicit URL/Data representations shared by JSON, plist and Enigma.
  struct PortablePayload: Codable, Equatable {
    // Fixed workload: targets roughly 15 ms for direct JSON coding in Release.
    var records = (0..<720).map { Record(id: $0) }

    struct Record: Codable, Equatable {
      var id: Int
      var maxInts = MaxInts()
      var minInts = MinInts()
      var maxUInts = MaxUInts()
      var floats = Floats()
      var arrays = Arrays()
      var dictionaries: [String: [Int]] = ["first": [1, 2, 3], "empty": []]
      var strings = ["Hello", "Привет", "😀"]
      var enabled = true
      @Codec.Box<Codec.StringURL>
      var url = URL(string: "https://example.com/path?query=value")!
      @Codec.Box<Codec.Base64Data>
      var bytes = Data([0, 1, 255])
    }
  }

  func testDecoding() throws {
    let value = PortablePayload()
    let formats: [(String, Data, Bool)] = [
      ("JSON", try Coder.encode(value, \.nonConformingFloatJson), true),
      ("XML plist", try Coder.encode(value, \.xmlPlistEncoder), false),
      ("Binary plist", try Coder.encode(value, \.binaryPlistEncoder), false),
    ]
    for (format, data, json) in formats {
      let tree = try Coder.decode(Enigma.self, data, json ? \.nonConformingFloatJson : nil)
      let object = try Coder.deserialize(data, json: json)
      let treeToModel = BenchmarkStage("tree -> model", { try tree.decode(PortablePayload.self).records.count })
      let decodeModel: () throws -> PortablePayload = {
        try Coder.decode(PortablePayload.self, data, json ? \.nonConformingFloatJson : nil)
      }
      let decodeTree: () throws -> PortablePayload = {
        try Coder.decode(Enigma.self, data, json ? \.nonConformingFloatJson : nil).decode(PortablePayload.self)
      }
      let deserialize: () throws -> PortablePayload = {
        try Enigma(cast: Coder.deserialize(data, json: json)).decode(PortablePayload.self)
      }
      XCTAssertEqual(try decodeModel(), value)
      XCTAssertEqual(try decodeTree(), value)
      XCTAssertEqual(try deserialize(), value)
      try benchmark("PortablePayload \(format) decoding", paths: [
        BenchmarkPath("Foundation decoder: Data -> model", { try decodeModel().records.count }),
        BenchmarkPath("Foundation decoder + Enigma: Data -> tree -> model", {
          try decodeTree().records.count
        }, stages: [
          BenchmarkStage("Data -> tree", {
            try Coder.decode(Enigma.self, data, json ? \.nonConformingFloatJson : nil).asDictionary?.count ?? 0
          }),
          treeToModel,
        ]),
        BenchmarkPath("Foundation serialization + Enigma: Data -> object -> tree -> model", {
          try deserialize().records.count
        }, stages: [
          BenchmarkStage("Data -> object", { try (Coder.deserialize(data, json: json) as? [String: Any])?.count ?? 0 }),
          BenchmarkStage("object -> tree", { try Enigma(cast: object).asDictionary?.count ?? 0 }),
          treeToModel,
        ]),
      ])
    }
  }

  func testEncoding() throws {
    let value = PortablePayload()
    let formats: [(String, PropertyListSerialization.PropertyListFormat?)] = [
      ("JSON", nil), ("XML plist", .xml), ("Binary plist", .binary),
    ]
    for (name, format) in formats {
      let tree = try Enigma(encode: value)
      let object = try format == nil ? tree.asJsonObject : tree.asPlistObject
      let modelToTree = BenchmarkStage("model -> tree", { try Enigma(encode: value).asDictionary?.count ?? 0 })
      let treeToData = BenchmarkStage("tree -> Data", {
        switch format {
        case .none: try Coder.encode(tree, \.nonConformingFloatJson).count
        case .some(.xml): try Coder.encode(tree, \.xmlPlistEncoder).count
        default: try Coder.encode(tree, \.binaryPlistEncoder).count
        }
      })
      let encodeModel: () throws -> Data = {
        switch format {
        case .none: try Coder.encode(value, \.nonConformingFloatJson)
        case .some(.xml): try Coder.encode(value, \.xmlPlistEncoder)
        default: try Coder.encode(value, \.binaryPlistEncoder)
        }
      }
      let encodeTree: () throws -> Data = {
        let tree = try Enigma(encode: value)
        return switch format {
        case .none: try Coder.encode(tree, \.nonConformingFloatJson)
        case .some(.xml): try Coder.encode(tree, \.xmlPlistEncoder)
        default: try Coder.encode(tree, \.binaryPlistEncoder)
        }
      }
      let serialize: () throws -> Data = {
        let tree = try Enigma(encode: value)
        let object = try format == nil ? tree.asJsonObject : tree.asPlistObject
        return try Coder.serialize(object, format)
      }
      for operation in [encodeModel, encodeTree, serialize] {
        XCTAssertEqual(try Coder.decode(
          PortablePayload.self, operation(), format == nil ? \.nonConformingFloatJson : nil
        ), value)
      }
      try benchmark("PortablePayload \(name) encoding", paths: [
        BenchmarkPath("Foundation encoder: model -> Data", { try encodeModel().count }),
        BenchmarkPath("Enigma + Foundation encoder: model -> tree -> Data", {
          try encodeTree().count
        }, stages: [modelToTree, treeToData]),
        BenchmarkPath("Enigma + Foundation serialization: model -> tree -> object -> Data", {
          try serialize().count
        }, stages: [
          modelToTree,
          BenchmarkStage("tree -> object", {
            try ((format == nil ? tree.asJsonObject : tree.asPlistObject) as? [String: Any])?.count ?? 0
          }),
          BenchmarkStage("object -> Data", { try Coder.serialize(object, format).count }),
        ]),
      ])
    }
  }
}
