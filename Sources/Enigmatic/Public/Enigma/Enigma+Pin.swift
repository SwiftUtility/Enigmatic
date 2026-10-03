extension Enigma {
  /// One component of a path through an Enigma tree.
  public enum Pin: Sendable {
    /// An array position.
    case int(Int)
    /// A dictionary key.
    case str(String)

    init(_ key: borrowing CodingKey) {
      self = if let intValue = key.intValue { .int(intValue) } else { .str(key.stringValue) }
    }

    /// Whether this pin identifies an array index.
    public var isInt: Bool {
      if case .int = self { true } else { false }
    }

    /// The coding key used by an encoder or decoder for a superclass value.
    public static let `super` = Self.str("super")
  }
}

extension Enigma.Pin: Equatable {
  /// Compares the pin kind and its associated value.
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.int(let lhs), .int(let rhs)): lhs == rhs
    case (.str(let lhs), .str(let rhs)): lhs == rhs
    case (.int, .str), (.str, .int): false
    }
  }
}

extension Enigma.Pin: Hashable {
  /// Combines the pin kind and associated value into the hasher.
  public func hash(into hasher: inout Hasher) {
    switch self {
    case .int(let value): hasher.combine(value)
    case .str(let value): hasher.combine(value)
    }
  }
}

extension Enigma.Pin: ExpressibleByStringLiteral {
  /// Creates a string-key pin from a string literal.
  public init(stringLiteral value: StringLiteralType) {
    self = .str(value)
  }
}

extension Enigma.Pin: ExpressibleByIntegerLiteral {
  /// Creates an index pin from an integer literal.
  public init(integerLiteral value: IntegerLiteralType) {
    self = .int(value)
  }
}

extension Enigma.Pin: CodingKey {
  /// Creates a string-key pin from a coding key's string representation.
  public init?(stringValue: String) {
    self = .str(stringValue)
  }

  /// Creates an index pin from a coding key's integer representation.
  public init?(intValue: Int) {
    self = .int(intValue)
  }

  /// The integer index, or nil when this pin is a string key.
  public var intValue: Int? {
    if case .int(let value) = self { value } else { nil }
  }

  /// The string key or decimal representation of the integer index.
  public var stringValue: String {
    switch self {
    case .int(let value): "\(value)"
    case .str(let value): value
    }
  }
}
