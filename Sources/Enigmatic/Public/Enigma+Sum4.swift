@available(macOS, deprecated: 14.0, message: "Use Enigma.Sum instead")
@available(iOS, deprecated: 17.0, message: "Use Enigma.Sum instead")
@available(tvOS, deprecated: 17.0, message: "Use Enigma.Sum instead")
@available(watchOS, deprecated: 10.0, message: "Use Enigma.Sum instead")
@available(visionOS, deprecated, message: "Use Enigma.Sum instead")
extension Enigma {
  /// Coproduct type that is either A, B, C or D
  public enum Sum4<A, B, C, D> {
    case a(A)
    case b(B)
    case c(C)
    case d(D)

    public var a: A? { if case .a(let a) = self { a } else { nil } }
    public var b: B? { if case .b(let b) = self { b } else { nil } }
    public var c: C? { if case .c(let c) = self { c } else { nil } }
    public var d: D? { if case .d(let d) = self { d } else { nil } }
  }
}

@available(macOS, deprecated: 14.0, message: "Use Enigma.Sum instead")
@available(iOS, deprecated: 17.0, message: "Use Enigma.Sum instead")
@available(tvOS, deprecated: 17.0, message: "Use Enigma.Sum instead")
@available(watchOS, deprecated: 10.0, message: "Use Enigma.Sum instead")
@available(visionOS, deprecated, message: "Use Enigma.Sum instead")
extension Enigma.Sum4: Decodable
where A: Decodable, B: Decodable, C: Decodable, D: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    guard let result = (try? Self.a(container.decode(A.self)))
      ?? (try? Self.b(container.decode(B.self)))
      ?? (try? Self.c(container.decode(C.self)))
      ?? (try? Self.d(container.decode(D.self)))
    else {
      throw DecodingError.dataCorrupted(DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Not either \(A.self) nor \(B.self) nor \(C.self) nor \(D.self)"
      ))
    }
    self = result
  }
}

@available(macOS, deprecated: 14.0, message: "Use Enigma.Sum instead")
@available(iOS, deprecated: 17.0, message: "Use Enigma.Sum instead")
@available(tvOS, deprecated: 17.0, message: "Use Enigma.Sum instead")
@available(watchOS, deprecated: 10.0, message: "Use Enigma.Sum instead")
@available(visionOS, deprecated, message: "Use Enigma.Sum instead")
extension Enigma.Sum4: Encodable
where A: Encodable, B: Encodable, C: Encodable, D: Encodable {
  public func encode(to encoder: Encoder) throws {
    switch self {
    case .a(let a): try a.encode(to: encoder)
    case .b(let b): try b.encode(to: encoder)
    case .c(let c): try c.encode(to: encoder)
    case .d(let d): try d.encode(to: encoder)
    }
  }
}

@available(macOS, deprecated: 14.0, message: "Use Enigma.Sum instead")
@available(iOS, deprecated: 17.0, message: "Use Enigma.Sum instead")
@available(tvOS, deprecated: 17.0, message: "Use Enigma.Sum instead")
@available(watchOS, deprecated: 10.0, message: "Use Enigma.Sum instead")
@available(visionOS, deprecated, message: "Use Enigma.Sum instead")
extension Enigma.Sum4: Equatable
where A: Equatable, B: Equatable, C: Equatable, D: Equatable {
  public static func ==(lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.a(let lhs), .a(let rhs)): lhs == rhs
    case (.b(let lhs), .b(let rhs)): lhs == rhs
    case (.c(let lhs), .c(let rhs)): lhs == rhs
    case (.d(let lhs), .d(let rhs)): lhs == rhs
    default: false
    }
  }
}

@available(macOS, deprecated: 14.0, message: "Use Enigma.Sum instead")
@available(iOS, deprecated: 17.0, message: "Use Enigma.Sum instead")
@available(tvOS, deprecated: 17.0, message: "Use Enigma.Sum instead")
@available(watchOS, deprecated: 10.0, message: "Use Enigma.Sum instead")
@available(visionOS, deprecated, message: "Use Enigma.Sum instead")
extension Enigma.Sum4: Hashable
where A: Hashable, B: Hashable, C: Hashable, D: Hashable {
  public func hash(into hasher: inout Hasher) {
    switch self {
    case .a(let value): value.hash(into: &hasher)
    case .b(let value): value.hash(into: &hasher)
    case .c(let value): value.hash(into: &hasher)
    case .d(let value): value.hash(into: &hasher)
    }
  }
}
