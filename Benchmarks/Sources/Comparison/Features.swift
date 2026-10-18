import Foundation

/// API descriptions refer to the pinned packages; measured cells come from RunData.
private struct FeatureLibrary {
  let name: String
  let source: String
  let json: Engine
  let foundation: Engine?
  let jsonObject: Engine?
  let plistObject: Engine?
}

func featureMatrix(_ run: RunData) -> String {
  let libraries: [FeatureLibrary] = [
    .init(name: "Foundation", source: "https://developer.apple.com/documentation/foundation/jsonencoder", json: .foundation, foundation: .foundation, jsonObject: .foundationObjects, plistObject: .foundationObjects),
    .init(name: "Enigmatic", source: "https://github.com/SwiftUtility/Enigmatic", json: .enigmaCodec, foundation: .enigma, jsonObject: .enigmaObjects, plistObject: .enigmaObjects),
    .init(name: "PotentCodables", source: "https://github.com/outfoxx/PotentCodables/tree/3.5.3", json: .potentJSON, foundation: .potentAny, jsonObject: nil, plistObject: nil),
    .init(name: "SwiftyJSON", source: "https://github.com/SwiftyJSON/SwiftyJSON/tree/5.0.2", json: .swiftyJSON, foundation: .swiftyJSON, jsonObject: .swiftyJSON, plistObject: nil),
    .init(name: "PMJSON", source: "https://github.com/postmates/PMJSON/tree/v4.0.0", json: .pmJSON, foundation: nil, jsonObject: nil, plistObject: nil),
    .init(name: "AnyCodable", source: "https://github.com/Flight-School/AnyCodable/tree/0.6.7", json: .anyCodable, foundation: .anyCodable, jsonObject: nil, plistObject: nil),
    .init(name: "swift-json", source: "https://github.com/orlandos-nl/swift-json/tree/2.5.4", json: .swiftJSON, foundation: nil, jsonObject: nil, plistObject: nil),
    .init(name: "CodableWrappers", source: "https://github.com/GottaGetSwifty/CodableWrappers/tree/3.1.0", json: .codableWrappers, foundation: .codableWrappers, jsonObject: nil, plistObject: nil),
    .init(name: "BetterCodable", source: "https://github.com/marksands/BetterCodable/tree/0.4.0", json: .betterCodable, foundation: .betterCodable, jsonObject: nil, plistObject: nil),
    .init(name: "MetaCodable", source: "https://github.com/SwiftyLab/MetaCodable/tree/v1.6.1", json: .metaCodable, foundation: .metaCodable, jsonObject: nil, plistObject: nil),
  ]
  var text = """
  ## Feature matrix

  One column per library, combining its benchmark paths. **API** cells describe capabilities
  inspected in the pinned source/documentation linked in the headers; these are not benchmark assertions.
  **PASS / PARTIAL / FAIL / REJECTED** cells are computed from the saved probes below.
  PARTIAL means only some probes in that cell pass. **Not probed** means this harness has no
  applicable result, not that the library lacks the feature. A rejected default JSON infinity is expected.
  Layout means serialized key names, nesting/flattening and field representations, not Swift memory layout.
  Manual means custom Codable code or explicit tree edits, rather than a dedicated built-in feature.

  """
  text += "| Feature | " + libraries.map { "[\($0.name)](\($0.source))" }.joined(separator: " | ") + " |\n"
  text += "| --- | " + libraries.map { _ in "---" }.joined(separator: " | ") + " |\n"
  func row(_ title: String, _ cells: [String]) {
    precondition(cells.count == libraries.count)
    text += "| \(title) | " + cells.joined(separator: " | ") + " |\n"
  }
  row("Own byte parser/writer (API)", ["JSON, plist", "JSON", "JSON, YAML, CBOR, ASN.1", "No; Foundation", "JSON", "No; external coder", "JSON", "No; external coder", "No; external coder", "No; generated Codable"])
  row("Dynamic value tree (API)", ["Any objects", "Enigma", "AnyValue / format trees", "JSON", "JSON", "Type-erased AnyCodable", "JSONObject / JSONArray", "No", "No", "No dedicated tree"])
  row("Direct model ↔ tree without bytes (API)", ["No generic model bridge", "Encoder + decoder", "AnyValue / format coders", "Needs model bridge", "JSON coders", "No generic model decoder", "Object/array coders", "Uses external coder", "Uses external coder", "Generates model Codable"])
  row("Foundation Codable interoperability (API)", ["Built in", "Codable tree", "Codable AnyValue; see measured limits", "Uses Foundation model bridge", "Codable JSON value", "Codable wrappers", "Uses own model coders", "Codable property wrappers", "Codable property wrappers", "Generated Codable"])
  row("Foundation object interoperability (API)", ["JSON / plist objects", "init(cast:), asJsonObject, asPlistObject", "AnyValue.wrapped / unwrapped", "Object initializer / object", "init(ns:) / ns", "Any-backed values; manual bridge", "Use explicit adapter", "Model layer; external bridge", "Model layer; external bridge", "Model layer; external bridge"])
  row("Key renaming (API)", ["CodingKeys / key strategies", "CodingKeys / tree edits", "Key strategies / CodingKeys", "Tree edits", "Key strategies / CodingKeys", "Consumer model CodingKeys", "Key strategies / CodingKeys", "Coding-key macros", "Consumer model CodingKeys", "CodedAt / CodingKeys macros"])
  row("Nesting / flattening layout (API)", ["Manual Codable", "Codec.Each composition / tree edits", "Manual Codable / tree edits", "Tree edits", "Manual Codable / tree edits", "Manual consumer Codable", "Manual Codable / object edits", "Manual Codable beyond key macros", "Manual consumer Codable", "CodedAt / CodedIn / composition"])
  row("Per-property representations (API)", ["Manual Codable; global coder strategies", "Composable Codec strategies", "Manual Codable; coder strategies", "Manual tree edits", "Manual Codable; coder strategies", "Manual consumer Codable", "Manual Codable; coder strategies", "Static coders / wrappers", "DateValue / LosslessValue", "HelperCoder / CodedBy"])
  row("Ready-made defaults / lossy collections (API)", ["Manual", "Custom strategies", "Custom Codable", "Defaulting getters; not model wrappers", "Manual Codable", "Manual consumer Codable", "Manual Codable", "Fallback / lossy wrappers", "Default / lossy wrappers", "Default / LossySequenceCoder"])
  row("Tree editing / merge (API)", ["Manual collections", "Path mutation / merge policies", "Value-tree APIs; manual composition", "Subscripts / merge / merged", "Mutable JSON; manual composition", "Any-backed edits; manual composition", "Mutable objects/arrays", "Not a tree library", "Not a tree library", "Not a tree library"])
  row("Macros in library API (API)", ["No", "No", "No", "No", "No", "No", "No", "Key macros + runtime wrappers", "No", "Codable generation macros"])

  let basic: [Probe] = [.string, .bool, .int32, .nested, .optional]
  row("Foundation JSON Codable: basic probes", libraries.map {
    featureStatus(run, $0.foundation, .json, basic)
  })
  row("Foundation plist Codable: basic probes (XML + binary)", libraries.map {
    featureStatus(run, $0.foundation, [.xml, .binary], basic)
  })
  row("JSONSerialization bridge: basic probes", libraries.map {
    featureStatus(run, $0.jsonObject, .json, basic)
  })
  row("PropertyListSerialization bridge: basic probes (XML + binary)", libraries.map {
    featureStatus(run, $0.plistObject, [.xml, .binary], basic)
  })
  for (kind, title) in [(Probe.plistDataType, "Native plist Data type"), (.plistDateType, "Native plist Date type")] {
    row(title + " (XML + binary)", libraries.map { library in
      let codable = featureStatus(run, library.foundation, [.xml, .binary], [kind])
      guard let bridge = library.plistObject else { return codable }
      return "Codable: \(codable); Serialization: \(featureStatus(run, bridge, [.xml, .binary], [kind]))"
    })
  }
  row("Exact native Date roundtrip: binary plist", libraries.map {
    featureStatus(run, $0.plistObject ?? $0.foundation, .binary, [.nativeDate])
  })
  row("Exact native Date roundtrip: XML plist (.125 s fraction)", libraries.map {
    featureStatus(run, $0.plistObject ?? $0.foundation, .xml, [.nativeDate])
  })
  row("Native Swift Int128 / UInt128 JSON roundtrip", libraries.map {
    featureStatus(run, $0.json, .json, [.int128, .uint128])
  })
  row("Non-finite Float / Double: default JSON", libraries.map {
    featureStatus(run, $0.json, .json, [.floatInfinity, .doubleInfinity, .floatNaN, .doubleNaN])
  })
  row("Non-finite Float / Double: binary plist", libraries.map {
    featureStatus(run, $0.plistObject ?? $0.foundation, .binary, [.floatInfinity, .doubleInfinity, .floatNaN, .doubleNaN])
  })
  row("Synthesized Optional nil keeps a JSON null key", libraries.map {
    featureStatus(run, $0.json, .json, [.defaultNull])
  })
  row("Explicit encode(Optional.nil) keeps a JSON null key", libraries.map {
    featureStatus(run, $0.json, .json, [.explicitNull])
  })
  row("Configured library null wrapper (tested adapters)", libraries.map { library in
    featureStatus(run, library.json, .json, [.libraryNull])
  })
  text += """

  Basic probes cover String, Bool, Int32, nested collections and Optional elements; they do not
  imply support for every numeric/native type. Wrapper/macro scalar results inherit Foundation behavior.
  SwiftyJSON's JSON bridge includes Foundation model coding and JSONSerialization inside SwiftyJSON;
  PMJSON's ns bridge and PotentCodables' wrapped/unwrapped bridge are API-listed but not probed here.
  Native plist cells show Codable and Serialization separately where both adapters exist.
  Exact Date rows choose the Serialization adapter when available, otherwise the Codable adapter.
  JSON numeric/null rows use each library's JSON adapter (Enigmatic Codec, PotentJSON, or the named
  Foundation-backed wrapper adapter). A Not probed libraryNull cell does not rule out a custom coder.
  The tables below identify every individual path and case behind these summaries.

  """
  return text
}

private func featureStatus(_ run: RunData, _ engine: Engine?, _ wire: Wire, _ probes: [Probe]) -> String {
  featureStatus(run, engine, [wire], probes)
}

private func featureStatus(_ run: RunData, _ engine: Engine?, _ wires: [Wire], _ probes: [Probe]) -> String {
  guard let engine else { return "Not probed" }
  let results = wires.flatMap { wire in
    probes.compactMap { kind in
      run.checks.first { $0.engine == engine && $0.wire == wire && $0.probe == kind.rawValue }?.result.status
    }
  }
  guard results.count == wires.count * probes.count, !results.contains("—") else { return "Not probed" }
  let passed = results.filter { $0 == "✅" }.count
  if passed == results.count { return "PASS" }
  if passed > 0 { return "PARTIAL (\(passed)/\(results.count))" }
  if results.allSatisfy({ $0 == "⚠️" }) { return "REJECTED" }
  return "FAIL"
}
