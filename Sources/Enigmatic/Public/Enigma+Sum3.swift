@available(macOS, deprecated: 14.0, message: "Use Enigma.Prod instead")
@available(iOS, deprecated: 17.0, message: "Use Enigma.Prod instead")
@available(tvOS, deprecated: 17.0, message: "Use Enigma.Prod instead")
@available(watchOS, deprecated: 10.0, message: "Use Enigma.Prod instead")
@available(visionOS, deprecated, message: "Use Enigma.Prod instead")
extension Enigma {
  /// Coproduct type that is either A, B or C
  public enum Sum3<A, B, C> {
    case a(A)
    case b(B)
    case c(C)

    public var a: A? { if case .a(let a) = self { a } else { nil } }
    public var b: B? { if case .b(let b) = self { b } else { nil } }
    public var c: C? { if case .c(let c) = self { c } else { nil } }
  }
}

@available(macOS, deprecated: 14.0, message: "Use Enigma.Prod instead")
@available(iOS, deprecated: 17.0, message: "Use Enigma.Prod instead")
@available(tvOS, deprecated: 17.0, message: "Use Enigma.Prod instead")
@available(watchOS, deprecated: 10.0, message: "Use Enigma.Prod instead")
@available(visionOS, deprecated, message: "Use Enigma.Prod instead")
extension Enigma.Sum3: Decodable
where A: Decodable, B: Decodable, C: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    guard let result = (try? Self.a(container.decode(A.self)))
      ?? (try? Self.b(container.decode(B.self)))
      ?? (try? Self.c(container.decode(C.self)))
    else {
      throw DecodingError.dataCorrupted(DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Not either \(A.self) nor \(B.self) nor \(C.self)"
      ))
    }
    self = result
  }
}

@available(macOS, deprecated: 14.0, message: "Use Enigma.Prod instead")
@available(iOS, deprecated: 17.0, message: "Use Enigma.Prod instead")
@available(tvOS, deprecated: 17.0, message: "Use Enigma.Prod instead")
@available(watchOS, deprecated: 10.0, message: "Use Enigma.Prod instead")
@available(visionOS, deprecated, message: "Use Enigma.Prod instead")
extension Enigma.Sum3: Encodable
where A: Encodable, B: Encodable, C: Encodable {
  public func encode(to encoder: Encoder) throws {
    switch self {
    case .a(let a): try a.encode(to: encoder)
    case .b(let b): try b.encode(to: encoder)
    case .c(let c): try c.encode(to: encoder)
    }
  }
}

@available(macOS, deprecated: 14.0, message: "Use Enigma.Prod instead")
@available(iOS, deprecated: 17.0, message: "Use Enigma.Prod instead")
@available(tvOS, deprecated: 17.0, message: "Use Enigma.Prod instead")
@available(watchOS, deprecated: 10.0, message: "Use Enigma.Prod instead")
@available(visionOS, deprecated, message: "Use Enigma.Prod instead")
extension Enigma.Sum3: Equatable
where A: Equatable, B: Equatable, C: Equatable {
  public static func ==(lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.a(let lhs), .a(let rhs)): lhs == rhs
    case (.b(let lhs), .b(let rhs)): lhs == rhs
    case (.c(let lhs), .c(let rhs)): lhs == rhs
    default: false
    }
  }
}

@available(macOS, deprecated: 14.0, message: "Use Enigma.Prod instead")
@available(iOS, deprecated: 17.0, message: "Use Enigma.Prod instead")
@available(tvOS, deprecated: 17.0, message: "Use Enigma.Prod instead")
@available(watchOS, deprecated: 10.0, message: "Use Enigma.Prod instead")
@available(visionOS, deprecated, message: "Use Enigma.Prod instead")
extension Enigma.Sum3: Hashable
where A: Hashable, B: Hashable, C: Hashable {
  public func hash(into hasher: inout Hasher) {
    switch self {
    case .a(let value): value.hash(into: &hasher)
    case .b(let value): value.hash(into: &hasher)
    case .c(let value): value.hash(into: &hasher)
    }
  }
}
