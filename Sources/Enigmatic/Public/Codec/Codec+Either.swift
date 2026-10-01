extension Codec {
  /// Coproduct type that is either Right or Left
  public enum Either<Right, Left> {
    case right(Right)
    case left(Left)

    @inlinable
    public var right: Right? {
      if case .right(let right) = self { right } else { nil }
    }

    @inlinable
    public var left: Left? {
      if case .left(let left) = self { left } else { nil }
    }
  }
}

extension Codec.Either: Sendable where Right: Sendable, Left: Sendable {}

extension Codec.Either: Decodable where Right: Decodable, Left: Decodable {
  @inlinable
  public init(from decoder: Decoder) throws {
    var error = Enigma.CompositeError()
    guard let result = error.report(try Self.right(Right(from: decoder)))
      ?? error.report(try Self.left(Left(from: decoder)))
    else {
      throw DecodingError.dataCorrupted(DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Neither \(Right.self) nor \(Left.self)",
        underlyingError: error
      ))
    }
    self = result
  }
}

extension Codec.Either: Encodable where Right: Encodable, Left: Encodable {
  @inlinable
  public func encode(to encoder: Encoder) throws {
    switch self {
    case .right(let right): try right.encode(to: encoder)
    case .left(let left): try left.encode(to: encoder)
    }
  }
}

extension Codec.Either: Equatable where Right: Equatable, Left: Equatable {
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
  @inlinable
  public func hash(into hasher: inout Hasher) {
    switch self {
    case .right(let right): right.hash(into: &hasher)
    case .left(let left): left.hash(into: &hasher)
    }
  }
}

extension Codec.Either: Codec.Strategy where Right: Codec.Strategy, Left: Codec.Strategy {
  public typealias BoxedValue = Codec.Either<Right.BoxedValue, Left.BoxedValue>
}

extension Codec.Either: Codec.DecodeStrategy where Right: Codec.DecodeStrategy, Left: Codec.DecodeStrategy {
  @inlinable
  public static func decode(decoder: some Decoder) throws -> BoxedValue {
    var error = Enigma.CompositeError()
    return if let right = error.report(try Right.decode(decoder: decoder)) {
      .right(right)
    } else if let left = error.report(try Left.decode(decoder: decoder)) {
      .left(left)
    } else {
      throw DecodingError.dataCorrupted(DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Neither \(Right.BoxedValue.self) nor \(Left.BoxedValue.self)",
        underlyingError: error
      ))
    }
  }
}

extension Codec.Either: Codec.EncodeStrategy where Right: Codec.EncodeStrategy, Left: Codec.EncodeStrategy {
  @inlinable
  public static func encode(value: BoxedValue, encoder: some Encoder) throws {
    switch value {
    case .right(let right): try Right.encode(value: right, encoder: encoder)
    case .left(let left): try Left.encode(value: left, encoder: encoder)
    }
  }
}
