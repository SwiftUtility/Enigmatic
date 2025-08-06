extension Enigma {
  public enum Pin: Sendable {
    case int(Int)
    case str(String)

    init(_ key: CodingKey) {
      self = if let intValue = key.intValue { .int(intValue) } else { .str(key.stringValue) }
    }

    public static let `super` = Self.str("super")
  }
}

extension Enigma.Pin: Equatable {
  public static func ==(lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.int(let lhs), .int(let rhs)): lhs == rhs
    case (.str(let lhs), .str(let rhs)): lhs == rhs
    default: false
    }
  }
}

extension Enigma.Pin: ExpressibleByStringLiteral {
  public init(stringLiteral value: StringLiteralType) {
    self = .str(value)
  }
}

extension Enigma.Pin: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: IntegerLiteralType) {
    self = .int(value)
  }
}

extension Enigma.Pin: CodingKey {
  public init?(stringValue: String) {
    self = .str(stringValue)
  }

  public init?(intValue: Int) {
    self = .int(intValue)
  }

  public var intValue: Int? {
    if case .int(let value) = self { value } else { nil }
  }

  public var stringValue: String {
    switch self {
    case .int(let value): "\(value)"
    case .str(let value): value
    }
  }
}
