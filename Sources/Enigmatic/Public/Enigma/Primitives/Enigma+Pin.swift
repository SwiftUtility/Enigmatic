extension Enigma {
  /// One component of a path through an Enigma tree.
  ///
  /// See [paths and mutations](https://swiftutility.github.io/Enigmatic/documentation/enigmatic/treeoperations/#Paths-and-mutations)
  /// for traversal, insertion, and deletion rules.
  public enum Pin: Sendable {
    /// An array position.
    case int(Int)
    /// A dictionary key.
    case str(String)

    /// Converts a coding key to an integer pin when it has an integer value;
    /// otherwise it uses the key's string representation.
    /// - Complexity: O(1) to select the integer or string coding-key representation.
    public init(_ key: borrowing CodingKey) {
      self = if let intValue = key.intValue { .int(intValue) } else { .str(key.stringValue) }
    }

    /// Whether this pin identifies an array index.
    /// - Complexity: O(1); it checks the pin case.
    public var isInt: Bool {
      if case .int = self { true } else { false }
    }

    /// The coding key used by an encoder or decoder for a superclass value.
    /// - Complexity: O(1) to return the shared string-key value.
    public static let `super` = Self.str("super")
  }
}

extension Enigma.Pin: Equatable {
  /// Compares values; an integer equals a string with its canonical decimal spelling.
  /// The pin case still determines whether tree traversal uses an array or dictionary.
  /// - Complexity: O(m) in the string length or integer's decimal digit count.
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.int(let lhs), .int(let rhs)): lhs == rhs
    case (.str(let lhs), .str(let rhs)): lhs == rhs
    case (.int(let int), .str(let str)), (.str(let str), .int(let int)): str == String(int)
    }
  }
}

extension Enigma.Pin: Hashable {
  /// Hashes the string representation, matching equality between integer and string pins.
  /// - Complexity: O(m) in the string length or integer's decimal digit count.
  public func hash(into hasher: inout Hasher) {
    switch self {
    case .int(let value): hasher.combine(String(value))
    case .str(let value): hasher.combine(value)
    }
  }
}

extension Enigma.Pin: ExpressibleByStringLiteral {
  /// Creates a string-key pin from a string literal.
  /// - Complexity: O(m), where m is the length of the string literal; integer literals take O(1).
  public init(stringLiteral value: StringLiteralType) {
    self = .str(value)
  }
}

extension Enigma.Pin: ExpressibleByIntegerLiteral {
  /// Creates an index pin from an integer literal.
  /// - Complexity: O(1) for the integer literal value.
  public init(integerLiteral value: IntegerLiteralType) {
    self = .int(value)
  }
}

extension Enigma.Pin: CodingKey {
  /// Creates a string-key pin from a coding key's string representation.
  /// - Complexity: O(m), where m is the number of output characters.
  public init?(stringValue: String) {
    self = .str(stringValue)
  }

  /// Creates an index pin from a coding key's integer representation.
  /// - Complexity: O(1); it checks the pin case.
  public init?(intValue: Int) {
    self = .int(intValue)
  }

  /// The integer value, parsing string pins with `Int.init(_:)`.
  /// - Complexity: O(m) for string pins of length m; O(1) for integer pins.
  public var intValue: Int? {
    switch self {
    case .str(let value): Int(value)
    case .int(let value): value
    }
  }

  /// The string key or decimal representation of the integer index.
  /// - Complexity: O(m), where m is the number of output characters.
  public var stringValue: String {
    switch self {
    case .int(let value): String(value)
    case .str(let value): value
    }
  }

  /// A user-facing description of the pin's associated value.
  /// - Complexity: O(m), where m is the number of output characters.
  public var description: String {
    switch self {
    case .int(let value): String(describing: value)
    case .str(let value): String(describing: value)
    }
  }

  /// A debug description that includes the pin case and reflected value.
  /// - Complexity: O(m), where m is the number of output characters.
  public var debugDescription: String {
    switch self {
    case .int(let value): "Pin.int(\(String(reflecting: value)))"
    case .str(let value): "Pin.str(\(String(reflecting: value)))"
    }
  }
}

@available(macOS 12.3, iOS 15.4, watchOS 8.5, tvOS 15.4, *)
extension Enigma.Pin: CodingKeyRepresentable {
  /// This pin as a coding key.
  public var codingKey: any CodingKey { self }

  /// Uses the key's integer value when present, otherwise its string value.
  public init?<T>(codingKey: T) where T : CodingKey {
    self = Self(codingKey)
  }
}
