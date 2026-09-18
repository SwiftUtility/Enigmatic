@available(macOS, deprecated: 14.0, message: "Use Enigma.Prod instead")
@available(iOS, deprecated: 17.0, message: "Use Enigma.Prod instead")
@available(tvOS, deprecated: 17.0, message: "Use Enigma.Prod instead")
@available(watchOS, deprecated: 10.0, message: "Use Enigma.Prod instead")
@available(visionOS, deprecated, message: "Use Enigma.Prod instead")
extension Enigma {
  /// Product type by merging A and B
  public struct Prod2<A, B> {
    public var a: A
    public var b: B

    public init(a: A, b: B) {
      self.a = a
      self.b = b
    }
  }
}

extension Enigma.Prod2: Sendable
where A: Sendable, B: Sendable {}

extension Enigma.Prod2: Decodable
where A: Decodable, B: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.a = try container.decode(A.self)
    self.b = try container.decode(B.self)
  }
}

extension Enigma.Prod2: Encodable
where A: Encodable, B: Encodable {
  public func encode(to encoder: Encoder) throws {
    try a.encode(to: encoder)
    try b.encode(to: encoder)
  }
}

extension Enigma.Prod2: Equatable
where A: Equatable, B: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.a == rhs.a && lhs.b == rhs.b
  }
}

extension Enigma.Prod2: Hashable
where A: Hashable, B: Hashable {
  public func hash(into hasher: inout Hasher) {
    a.hash(into: &hasher)
    b.hash(into: &hasher)
  }
}
