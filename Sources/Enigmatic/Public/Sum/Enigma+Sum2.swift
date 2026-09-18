@available(macOS, deprecated: 14.0, message: "Use Enigma.Sum instead")
@available(iOS, deprecated: 17.0, message: "Use Enigma.Sum instead")
@available(tvOS, deprecated: 17.0, message: "Use Enigma.Sum instead")
@available(watchOS, deprecated: 10.0, message: "Use Enigma.Sum instead")
@available(visionOS, deprecated, message: "Use Enigma.Sum instead")
extension Enigma {
  /// Coproduct type that is either A or B
  public enum Sum2<A, B> {
    case a(A)
    case b(B)

    public var a: A? { if case .a(let a) = self { a } else { nil } }
    public var b: B? { if case .b(let b) = self { b } else { nil } }
  }
}

extension Enigma.Sum2: Sendable
where A: Sendable, B: Sendable {}

extension Enigma.Sum2: Decodable
where A: Decodable, B: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    guard let result = (try? Self.a(container.decode(A.self)))
      ?? (try? Self.b(container.decode(B.self)))
    else {
      throw DecodingError.dataCorrupted(DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Not either \(A.self) nor \(B.self)"
      ))
    }
    self = result
  }
}

extension Enigma.Sum2: Encodable
where A: Encodable, B: Encodable {
  public func encode(to encoder: Encoder) throws {
    switch self {
    case .a(let a): try a.encode(to: encoder)
    case .b(let b): try b.encode(to: encoder)
    }
  }
}

extension Enigma.Sum2: Equatable
where A: Equatable, B: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.a(let lhs), .a(let rhs)): lhs == rhs
    case (.b(let lhs), .b(let rhs)): lhs == rhs
    default: false
    }
  }
}

extension Enigma.Sum2: Hashable
where A: Hashable, B: Hashable {
  public func hash(into hasher: inout Hasher) {
    switch self {
    case .a(let a): a.hash(into: &hasher)
    case .b(let b): b.hash(into: &hasher)
    }
  }
}
