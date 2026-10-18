import Foundation
import Enigmatic
import CodableWrappers

enum Probe: String, CaseIterable {
  case string, bool, int, int8, int16, int32, int64, uint, uint8, uint16, uint32, uint64
  case int128, uint128, float16, float, double, floatInfinity, doubleInfinity, floatNaN, doubleNaN
  case decimal, cgFloat, data, date, url, uuid, nested, optional, explicitNull, defaultNull, libraryNull
  case nativeData, nativeDate, plistDataType, plistDateType, scalarRoot, arrayRoot, nullRoot
}

struct ProbeResult: Codable {
  var status: String
  var detail: String
  static func pass(_ detail: String = "Exact model roundtrip") -> Self { .init(status: "✅", detail: detail) }
  static func unsupported(_ detail: String) -> Self { .init(status: "—", detail: detail) }
}

struct EnigmaNull: Codable, Equatable {
  @Codec.Box<Codec.Nullable<Codec.Id<String>>> var value: String? = nil
}
struct WrapperNull: Codable, Equatable {
  @EncodeNulls var value: String? = nil
}

func probe(_ kind: Probe, engine: Engine, wire: Wire) -> ProbeResult {
  guard engine.supports(wire) else { return .unsupported("No adapter for this format/path") }
  if [.nativeData, .nativeDate, .plistDataType, .plistDateType].contains(kind), wire != .xml && wire != .binary {
    return .unsupported("Native plist storage is checked only in plist formats")
  }
  if [.defaultNull, .explicitNull, .libraryNull].contains(kind), wire != .json && wire != .jsonStrings {
    return .unsupported("JSON object null-key check")
  }
  do {
    func check<T: Codable>(_ value: T, equal: (T, T) -> Bool) throws -> ProbeResult {
      let box = ValueBox(value: value)
      let decoded: ValueBox<T>
      if wire == .tree {
        decoded = try engine.treeRoundtrip(box)
      } else {
        decoded = try engine.decode(ValueBox<T>.self, data: engine.encode(box, wire: wire), wire: wire)
      }
      return equal(value, decoded.value) ? .pass() : .init(status: "❌", detail: "Value or precision changed")
    }
    func exact<T: Codable & Equatable>(_ value: T) throws -> ProbeResult { try check(value, equal: ==) }
    func nullKey<T: Codable & Equatable>(_ value: T) throws -> ProbeResult {
      let bytes = try engine.encode(value, wire: wire)
      let dictionary = try object(bytes, wire: wire) as? [String: Any]
      guard dictionary?["value"] is NSNull else {
        return .init(status: "❌", detail: "Optional nil key is absent or not JSON null")
      }
      guard try engine.decode(T.self, data: bytes, wire: wire) == value else {
        return .init(status: "❌", detail: "Optional model value changed")
      }
      return .pass("JSON contains value: null and model decodes")
    }
    switch kind {
    case .string: return try exact(["", "Привет 世界 😀", "\u{0}\n\r\t\\\"/"])
    case .bool: return try exact([true, false])
    case .int: return try exact([Int.min, -1, 0, Int.max])
    case .int8: return try exact([Int8.min, -1, 0, Int8.max])
    case .int16: return try exact([Int16.min, -1, 0, Int16.max])
    case .int32: return try exact([Int32.min, -1, 0, Int32.max])
    case .int64: return try exact([Int64.min, -9_007_199_254_740_993, 0, 9_007_199_254_740_993, Int64.max])
    case .uint: return try exact([UInt.min, UInt.max])
    case .uint8: return try exact([UInt8.min, UInt8.max])
    case .uint16: return try exact([UInt16.min, UInt16.max])
    case .uint32: return try exact([UInt32.min, UInt32.max])
    case .uint64: return try exact([UInt64.min, 9_007_199_254_740_993, UInt64.max])
    case .int128: return try exact([Int128.min, -1, 0, Int128.max])
    case .uint128: return try exact([UInt128.min, UInt128.max])
    case .float16:
      return try check([Float16.leastNonzeroMagnitude, -0.0, 1.5, .greatestFiniteMagnitude]) {
        $0.map(\.bitPattern) == $1.map(\.bitPattern)
      }
    case .float:
      return try check([Float.leastNonzeroMagnitude, -0.0, 1.5, .greatestFiniteMagnitude]) {
        $0.map(\.bitPattern) == $1.map(\.bitPattern)
      }
    case .double:
      return try check([Double.leastNonzeroMagnitude, -0.0, 1.5, .greatestFiniteMagnitude]) {
        $0.map(\.bitPattern) == $1.map(\.bitPattern)
      }
    case .floatInfinity: return try exact([Float.infinity, -Float.infinity])
    case .doubleInfinity: return try exact([Double.infinity, -Double.infinity])
    case .floatNaN: return try check(Float.nan) { $0.isNaN && $1.isNaN }
    case .doubleNaN: return try check(Double.nan) { $0.isNaN && $1.isNaN }
    case .decimal: return try exact(Decimal(string: "12345678901234567890.123456789012345678")!)
    case .cgFloat: return try exact([CGFloat(-1.25), 0, 1.25, .greatestFiniteMagnitude])
    case .data: return try exact(Data([0, 1, 127, 128, 255]))
    case .date: return try exact(Date(timeIntervalSinceReferenceDate: 123_456_789.125))
    case .url: return try exact(URL(string: "https://example.com/a?q=%D0%B0#section")!)
    case .uuid: return try exact(UUID(uuidString: "12345678-1234-1234-1234-123456789ABC")!)
    case .nested: return try exact(["items": [[1, 2], [], [3]], "empty": []])
    case .optional: return try exact([Optional<Int>.none, 0, 42])
    case .explicitNull: return try nullKey(ExplicitNull())
    case .defaultNull: return try nullKey(NilField())
    case .libraryNull:
      switch engine {
      case .enigma, .enigmaCodec, .enigmaObjects: return try nullKey(EnigmaNull())
      case .codableWrappers: return try nullKey(WrapperNull())
      default: return .unsupported("No library-specific null wrapper configured; see explicitNull")
      }
    case .plistDataType:
      let bytes = try engine.encode(ValueBox(value: Data([0, 128, 255])), wire: wire)
      let dictionary = try object(bytes, wire: wire) as? [String: Any]
      return dictionary?["value"] is Data ? .pass("Native plist Data type (type-only check)")
        : .init(status: "❌", detail: "Encoded plist value is not native Data")
    case .plistDateType:
      let bytes = try engine.encode(ValueBox(value: Date(timeIntervalSinceReferenceDate: 123_456_789.125)), wire: wire)
      let dictionary = try object(bytes, wire: wire) as? [String: Any]
      return dictionary?["value"] is Date ? .pass("Native plist Date type (type-only check)")
        : .init(status: "❌", detail: "Encoded plist value is not native Date")
    case .nativeData:
      let input = ValueBox(value: Data([0, 128, 255]))
      let bytes = try engine.encode(input, wire: wire)
      let dictionary = try object(bytes, wire: wire) as? [String: Any]
      let output = try engine.decode(ValueBox<Data>.self, data: bytes, wire: wire)
      guard dictionary?["value"] is Data, output.value == input.value else {
        return .init(status: "❌", detail: "Data is not stored as native plist data, or changed")
      }
      return .pass("Native plist Data and exact model roundtrip")
    case .nativeDate:
      let input = ValueBox(value: Date(timeIntervalSinceReferenceDate: 123_456_789.125))
      let bytes = try engine.encode(input, wire: wire)
      let dictionary = try object(bytes, wire: wire) as? [String: Any]
      let output = try engine.decode(ValueBox<Date>.self, data: bytes, wire: wire)
      guard dictionary?["value"] is Date else {
        return .init(status: "❌", detail: "Date is not stored as native plist date")
      }
      guard output.value == input.value else {
        return .init(status: "❌", detail: "Native plist Date present, but timestamp changed: \(input.value.timeIntervalSinceReferenceDate) → \(output.value.timeIntervalSinceReferenceDate)")
      }
      return .pass("Native plist Date and exact model roundtrip")
    case .scalarRoot:
      let value = "root 😀"
      let decoded: String = wire == .tree
        ? try engine.treeRoundtrip(value)
        : try engine.decode(String.self, data: engine.encode(value, wire: wire), wire: wire)
      return decoded == value ? .pass() : .init(status: "❌", detail: "Root value changed")
    case .nullRoot:
      let value: String? = nil
      let decoded: String? = wire == .tree
        ? try engine.treeRoundtrip(value)
        : try engine.decode(String?.self, data: engine.encode(value, wire: wire), wire: wire)
      return decoded == nil ? .pass() : .init(status: "❌", detail: "Root null changed")
    case .arrayRoot:
      let value = [1, 2, 3]
      let decoded: [Int] = wire == .tree
        ? try engine.treeRoundtrip(value)
        : try engine.decode([Int].self, data: engine.encode(value, wire: wire), wire: wire)
      return decoded == value ? .pass() : .init(status: "❌", detail: "Root array changed")
    }
  } catch {
    return .init(status: "⚠️", detail: String(describing: error))
  }
}
