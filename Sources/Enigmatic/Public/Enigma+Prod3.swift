@available(macOS, deprecated: 14.0, message: "Use Enigma.Prod instead")
@available(iOS, deprecated: 17.0, message: "Use Enigma.Prod instead")
@available(tvOS, deprecated: 17.0, message: "Use Enigma.Prod instead")
@available(watchOS, deprecated: 10.0, message: "Use Enigma.Prod instead")
@available(visionOS, deprecated, message: "Use Enigma.Prod instead")
extension Enigma {
  /// Product type by merging A, B and C
  public struct Prod3<A, B, C> {
    public var a: A
    public var b: B
    public var c: C

    public init(a: A, b: B, c: C) {
      self.a = a
      self.b = b
      self.c = c
    }
  }
}

extension Enigma.Prod3: Sendable
where A: Sendable, B: Sendable, C: Sendable {}

extension Enigma.Prod3: Decodable
where A: Decodable, B: Decodable, C: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.a = try container.decode(A.self)
    self.b = try container.decode(B.self)
    self.c = try container.decode(C.self)
  }
}

extension Enigma.Prod3: Encodable
where A: Encodable, B: Encodable, C: Encodable {
  public func encode(to encoder: Encoder) throws {
    try a.encode(to: encoder)
    try b.encode(to: encoder)
    try c.encode(to: encoder)
  }
}

extension Enigma.Prod3: Equatable
where A: Equatable, B: Equatable, C: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.a == rhs.a && lhs.b == rhs.b && lhs.c == rhs.c
  }
}

extension Enigma.Prod3: Hashable
where A: Hashable, B: Hashable, C: Hashable {
  public func hash(into hasher: inout Hasher) {
    a.hash(into: &hasher)
    b.hash(into: &hasher)
    c.hash(into: &hasher)
  }
}
