import Foundation

enum CommonKey: Sendable, CodingKey, Equatable {
  case index(Int)
  case key(String)

  init?(stringValue: String) { self = .key(stringValue) }

  init?(intValue: Int) { self = .index(intValue) }

  init(_ key: CodingKey) { self = key.intValue.map(Self.index(_:)) ?? .key(key.stringValue) }

  var intValue: Int? { if case .index(let value) = self { value } else { nil } }

  var stringValue: String {
    switch self {
    case .index(let value): "\(value)"
    case .key(let value): value
    }
  }

  static let `super` = Self.key("super")

  static func ==(lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.index(let lhs), .index(let rhs)): lhs == rhs
    case (.key(let lhs), .key(let rhs)): lhs == rhs
    default: false
    }
  }
}
