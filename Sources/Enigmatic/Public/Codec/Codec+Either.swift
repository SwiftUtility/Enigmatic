extension Codec {
  /// A value decoded as Right first, then Left if the first attempt fails.
  ///
  /// If both fail, the decoding error retains both causes in a CompositeError.
  public enum Either<Right, Left> {
    /// The selected right-hand value.
    case right(Right)
    /// The selected left-hand value.
    case left(Left)

    /// Returns the right value, or nil when this value is left.
    /// - Complexity: O(1); it checks the selected alternative.
    @inlinable
    public var right: Right? {
      if case .right(let right) = self { right } else { nil }
    }

    /// Returns the left value, or nil when this value is right.
    /// - Complexity: O(1); it checks the selected alternative.
    @inlinable
    public var left: Left? {
      if case .left(let left) = self { left } else { nil }
    }
  }
}

extension Codec.Either: Sendable where Right: Sendable, Left: Sendable {}

extension Codec.Either: Decodable where Right: Decodable, Left: Decodable {
  /// Decodes the right type first, then tries the left type if decoding fails.
  /// - Complexity: O(R + L) worst case, where R and L are the costs of decoding the right and left alternatives;
  ///   the left attempt runs only if the right fails.
  @inlinable
  public init(from decoder: Decoder) throws {
    var error = Enigma.CompositeError()
    self = if let right = error.get(try Right(from: decoder)) {
      .right(right)
    } else if let left = error.get(try Left(from: decoder)) {
      .left(left)
    } else {
      throw error.dataCorrupted(decoder.codingPath, "Neither \(Right.self) nor \(Left.self)")
    }
  }
}

extension Codec.Either: Encodable where Right: Encodable, Left: Encodable {
  /// Encodes the active alternative using that alternative's Codable conformance.
  /// - Complexity: The cost of encoding the selected alternative.
  @inlinable
  public func encode(to encoder: Encoder) throws {
    switch self {
    case .right(let right): try right.encode(to: encoder)
    case .left(let left): try left.encode(to: encoder)
    }
  }
}

extension Codec.Either: Equatable where Right: Equatable, Left: Equatable {
  /// Compares both the selected alternative and its associated value.
  /// - Complexity: The cost of comparing the selected associated values.
  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.right(let lhs), .right(let rhs)): lhs == rhs
    case (.left(let lhs), .left(let rhs)): lhs == rhs
    case (.left, .right), (.right, .left): false
    }
  }
}

extension Codec.Either: Hashable where Right: Hashable, Left: Hashable {
  /// Hashes the selected alternative and its associated value.
  /// - Complexity: The cost of hashing the selected associated value.
  @inlinable
  public func hash(into hasher: inout Hasher) {
    switch self {
    case .right(let right): right.hash(into: &hasher)
    case .left(let left): left.hash(into: &hasher)
    }
  }
}

extension Codec.Either: Codec.Strategy where Right: Codec.Strategy, Left: Codec.Strategy {
  /// A choice containing either strategy's boxed value.
  public typealias BoxedValue = Codec.Either<Right.BoxedValue, Left.BoxedValue>
}

extension Codec.Either: Codec.DecodeStrategy where Right: Codec.DecodeStrategy, Left: Codec.DecodeStrategy {
  /// Decodes the right strategy first and falls back to the left strategy.
  /// - Complexity: O(R + L) worst case, where R and L are the costs of decoding the right and left alternatives;
  ///   the left attempt runs only if the right fails.
  @inlinable
  public static func decode(decoder: some Decoder) throws -> BoxedValue {
    var error = Enigma.CompositeError()
    return if let right = error.get(try Right.decode(decoder: decoder)) {
      .right(right)
    } else if let left = error.get(try Left.decode(decoder: decoder)) {
      .left(left)
    } else {
      throw error.dataCorrupted(decoder.codingPath, "Neither \(Right.BoxedValue.self) nor \(Left.BoxedValue.self)")
    }
  }
}

extension Codec.Either: Codec.EncodeStrategy where Right: Codec.EncodeStrategy, Left: Codec.EncodeStrategy {
  /// Encodes the active alternative with its corresponding strategy.
  /// - Complexity: The cost of encoding the selected alternative.
  @inlinable
  public static func encode(value: BoxedValue, encoder: some Encoder) throws {
    switch value {
    case .right(let right): try Right.encode(value: right, encoder: encoder)
    case .left(let left): try Left.encode(value: left, encoder: encoder)
    }
  }
}
