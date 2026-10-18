import Foundation
import Enigmatic
import PotentCodables
import PotentJSON
import SwiftyJSON
import PMJSON
import AnyCodable
import IkigaJSON

enum Wire: String, CaseIterable {
  case tree, json, jsonStrings, xml, binary
  var title: String {
    switch self {
    case .tree: return "In-memory model → tree → model"
    case .json: return "JSON (default policies)"
    case .jsonStrings: return "JSON (non-finite numbers as strings)"
    case .xml: return "XML plist"
    case .binary: return "Binary plist"
    }
  }
  var plistFormat: PropertyListSerialization.PropertyListFormat { self == .xml ? .xml : .binary }
}

enum Engine: String, CaseIterable {
  case foundation, foundationObjects, enigma, enigmaCodec, enigmaObjects
  case potentAny, potentJSON, swiftyJSON, pmJSON, anyCodable, swiftJSON
  case codableWrappers, betterCodable, metaCodable

  var title: String {
    switch self {
    case .foundation: return "Foundation Codable"
    case .foundationObjects: return "Foundation Codable + Serialization"
    case .enigma: return "Enigmatic + Foundation Codable"
    case .enigmaCodec: return "Enigmatic Codec JSON"
    case .enigmaObjects: return "Enigmatic + Foundation Serialization"
    case .potentAny: return "PotentCodables AnyValue + Foundation"
    case .potentJSON: return "PotentJSON"
    case .swiftyJSON: return "SwiftyJSON + Foundation Codable"
    case .pmJSON: return "PMJSON"
    case .anyCodable: return "AnyCodable + Foundation Codable"
    case .swiftJSON: return "swift-json (IkigaJSON)"
    case .codableWrappers: return "CodableWrappers + Foundation"
    case .betterCodable: return "BetterCodable + Foundation"
    case .metaCodable: return "MetaCodable + Foundation"
    }
  }

  func supports(_ wire: Wire) -> Bool {
    if wire == .tree { return [.enigma, .potentAny, .potentJSON, .pmJSON].contains(self) }
    switch self {
    case .enigmaCodec, .swiftyJSON, .pmJSON, .swiftJSON: return wire == .json
    case .potentJSON: return wire == .json || wire == .jsonStrings
    case .foundationObjects, .enigmaObjects: return wire != .jsonStrings
    default: return true
    }
  }

  func encode<T: Encodable>(_ value: T, wire: Wire) throws -> Data {
    switch self {
    case .foundation, .codableWrappers, .betterCodable, .metaCodable:
      return try foundationEncode(value, wire: wire)
    case .foundationObjects:
      let bytes = try foundationEncode(value, wire: wire)
      return try serialize(object(bytes, wire: wire), wire: wire)
    case .enigma:
      return try foundationEncode(Enigma(encode: value), wire: wire)
    case .enigmaCodec:
      return try Codec.encode(json: Enigma(encode: value), as: .utf8)
    case .enigmaObjects:
      let tree = try Enigma(encode: value)
      return try serialize(wire == .json ? tree.asJsonObject : tree.asPlistObject, wire: wire)
    case .potentAny:
      return try foundationEncode(AnyValueEncoder().encode(value), wire: wire)
    case .potentJSON:
      let encoder = PotentJSON.JSONEncoder()
      if wire == .jsonStrings {
        encoder.nonConformingFloatEncodingStrategy = .convertToString(
          positiveInfinity: "Infinity", negativeInfinity: "-Infinity", nan: "NaN")
      }
      return try encoder.encode(value)
    case .swiftyJSON:
      return try SwiftyJSON.JSON(data: foundationEncode(value, wire: wire)).rawData()
    case .pmJSON:
      return try PMJSON.JSON.Encoder().encodeAsData(value)
    case .anyCodable:
      let bytes = try foundationEncode(value, wire: wire)
      return try foundationEncode(foundationDecode(AnyCodable.self, bytes, wire: wire), wire: wire)
    case .swiftJSON:
      return try IkigaJSONEncoder().encode(value)
    }
  }

  func decode<T: Decodable>(_ type: T.Type, data: Data, wire: Wire) throws -> T {
    switch self {
    case .foundation, .codableWrappers, .betterCodable, .metaCodable:
      return try foundationDecode(type, data, wire: wire)
    case .foundationObjects:
      return try foundationDecode(type, serialize(object(data, wire: wire), wire: wire), wire: wire)
    case .enigma:
      return try foundationDecode(Enigma.self, data, wire: wire).decode(type)
    case .enigmaCodec:
      return try Codec.decode(json: data, as: .utf8).decode(type)
    case .enigmaObjects:
      return try Enigma(cast: object(data, wire: wire)).decode(type)
    case .potentAny:
      return try AnyValueDecoder().decode(type, from: foundationDecode(AnyValue.self, data, wire: wire))
    case .potentJSON:
      let decoder = PotentJSON.JSONDecoder()
      if wire == .jsonStrings {
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(
          positiveInfinity: "Infinity", negativeInfinity: "-Infinity", nan: "NaN")
      }
      return try decoder.decode(type, from: data)
    case .swiftyJSON:
      return try foundationDecode(type, SwiftyJSON.JSON(data: data).rawData(), wire: wire)
    case .pmJSON:
      return try PMJSON.JSON.Decoder().decode(type, from: data)
    case .anyCodable:
      let tree = try foundationDecode(AnyCodable.self, data, wire: wire)
      return try foundationDecode(type, foundationEncode(tree, wire: wire), wire: wire)
    case .swiftJSON:
      return try IkigaJSONDecoder().decode(type, from: data)
    }
  }

  func treeRoundtrip<T: Codable>(_ value: T) throws -> T {
    switch self {
    case .enigma: return try Enigma(encode: value).decode(T.self)
    case .pmJSON: return try PMJSON.JSON.Decoder().decode(T.self, from: PMJSON.JSON.Encoder().encodeAsJSON(value))
    case .potentJSON:
      return try PotentJSON.JSONDecoder().decodeTree(T.self, from: PotentJSON.JSONEncoder().encodeTree(value))
    case .potentAny: return try AnyValueDecoder().decode(T.self, from: AnyValueEncoder().encode(value))
    default: throw CheckFailure("No direct model/tree bridge")
    }
  }
}

func foundationEncode<T: Encodable>(_ value: T, wire: Wire) throws -> Data {
  if wire == .xml || wire == .binary {
    let encoder = PropertyListEncoder()
    encoder.outputFormat = wire.plistFormat
    return try encoder.encode(value)
  }
  let encoder = Foundation.JSONEncoder()
  if wire == .jsonStrings {
    encoder.nonConformingFloatEncodingStrategy = .convertToString(
      positiveInfinity: "Infinity", negativeInfinity: "-Infinity", nan: "NaN")
  }
  return try encoder.encode(value)
}

func foundationDecode<T: Decodable>(_ type: T.Type, _ bytes: Data, wire: Wire) throws -> T {
  if wire == .xml || wire == .binary { return try PropertyListDecoder().decode(type, from: bytes) }
  let decoder = Foundation.JSONDecoder()
  if wire == .jsonStrings {
    decoder.nonConformingFloatDecodingStrategy = .convertFromString(
      positiveInfinity: "Infinity", negativeInfinity: "-Infinity", nan: "NaN")
  }
  return try decoder.decode(type, from: bytes)
}

func object(_ bytes: Data, wire: Wire) throws -> Any {
  if wire == .xml || wire == .binary {
    return try PropertyListSerialization.propertyList(from: bytes, options: [], format: nil)
  }
  return try JSONSerialization.jsonObject(with: bytes, options: [.fragmentsAllowed])
}

func serialize(_ value: Any, wire: Wire) throws -> Data {
  if wire == .xml || wire == .binary {
    return try PropertyListSerialization.data(fromPropertyList: value, format: wire.plistFormat, options: 0)
  }
  return try JSONSerialization.data(withJSONObject: value, options: [.fragmentsAllowed])
}
