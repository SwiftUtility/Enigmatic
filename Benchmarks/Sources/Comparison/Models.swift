import Foundation
import CodableWrappers
import BetterCodable
import MetaCodable

struct Payload<Row: Codable & Equatable>: Codable, Equatable {
  var records: [Row]
  var page = 1
  var hasNextPage = true
  var cursor = "orders:900"
}

protocol SampleRow: Codable, Equatable {
  init(_ index: Int)
}

struct ValueBox<Value: Codable>: Codable {
  var value: Value
}

struct NilField: Codable, Equatable {
  var value: String? = nil
}

/// Explicit null independently of the encoder's synthesized Optional policy.
struct ExplicitNull: Codable, Equatable {
  var value: String? = nil
  enum CodingKeys: String, CodingKey { case value }
  init() {}
  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    guard container.contains(.value) else { throw CheckFailure("null key was omitted") }
    value = try container.decode(String?.self, forKey: .value)
  }
  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(value, forKey: .value)
  }
}

struct CheckFailure: Error, CustomStringConvertible {
  var description: String
  init(_ description: String) { self.description = description }
}

struct PlainRow: SampleRow {
  var id: Int
  var name: String
  var active: Bool
  var amount: Double
  var tags: [String]
  var quantities: [Int]
  var attributes: [String: String]
  var text: String
  var optional: String?

  init(_ index: Int) {
    id = index
    name = "Order \(index) — Привет 😀"
    active = index.isMultiple(of: 2)
    amount = Double(index) * 1.25
    tags = ["swift", "json", "заказ"]
    quantities = Array(0..<20)
    attributes = ["currency": "RUB", "status": "paid", "country": "RU"]
    text = String(repeating: "Escaped \"text\" / Unicode 世界; ", count: 22)
    optional = index.isMultiple(of: 3) ? nil : "note \(index)"
  }
}

struct WrappedRow: SampleRow {
  @Immutable var id: Int
  var name: String
  var active: Bool
  var amount: Double
  var tags: [String]
  var quantities: [Int]
  var attributes: [String: String]
  var text: String
  var optional: String?

  init(_ index: Int) {
    _id = Immutable(wrappedValue: index)
    name = "Order \(index) — Привет 😀"
    active = index.isMultiple(of: 2)
    amount = Double(index) * 1.25
    tags = ["swift", "json", "заказ"]
    quantities = Array(0..<20)
    attributes = ["currency": "RUB", "status": "paid", "country": "RU"]
    text = String(repeating: "Escaped \"text\" / Unicode 世界; ", count: 22)
    optional = index.isMultiple(of: 3) ? nil : "note \(index)"
  }
}

struct BetterRow: SampleRow {
  @LosslessValue var id: Int
  var name: String
  var active: Bool
  var amount: Double
  var tags: [String]
  var quantities: [Int]
  var attributes: [String: String]
  var text: String
  var optional: String?

  init(_ index: Int) {
    id = index
    name = "Order \(index) — Привет 😀"
    active = index.isMultiple(of: 2)
    amount = Double(index) * 1.25
    tags = ["swift", "json", "заказ"]
    quantities = Array(0..<20)
    attributes = ["currency": "RUB", "status": "paid", "country": "RU"]
    text = String(repeating: "Escaped \"text\" / Unicode 世界; ", count: 22)
    optional = index.isMultiple(of: 3) ? nil : "note \(index)"
  }
}

@Codable
struct MacroRow: SampleRow {
  var id: Int
  var name: String
  var active: Bool
  var amount: Double
  var tags: [String]
  var quantities: [Int]
  var attributes: [String: String]
  var text: String
  var optional: String?

  init(_ index: Int) {
    id = index
    name = "Order \(index) — Привет 😀"
    active = index.isMultiple(of: 2)
    amount = Double(index) * 1.25
    tags = ["swift", "json", "заказ"]
    quantities = Array(0..<20)
    attributes = ["currency": "RUB", "status": "paid", "country": "RU"]
    text = String(repeating: "Escaped \"text\" / Unicode 世界; ", count: 22)
    optional = index.isMultiple(of: 3) ? nil : "note \(index)"
  }
}
