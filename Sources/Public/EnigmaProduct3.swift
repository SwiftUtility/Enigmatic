import Foundation

extension Enigma {
  /// Product type by merging A, B and C
  public struct Product3<A, B, C> {
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

extension Enigma.Product3: Decodable
where A: Decodable, B: Decodable, C: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.a = try container.decode(A.self)
    self.b = try container.decode(B.self)
    self.c = try container.decode(C.self)
  }
}

extension Enigma.Product3: Encodable
where A: Encodable, B: Encodable, C: Encodable {
  public func encode(to encoder: Encoder) throws {
    try a.encode(to: encoder)
    try b.encode(to: encoder)
    try c.encode(to: encoder)
  }
}

extension Enigma.Product3: Equatable
where A: Equatable, B: Equatable, C: Equatable {
  public static func ==(lhs: Self, rhs: Self) -> Bool {
    return lhs.a == rhs.a && lhs.b == rhs.b && lhs.c == rhs.c
  }
}

extension Enigma.Product3: Hashable
where A: Hashable, B: Hashable, C: Hashable {
  public func hash(into hasher: inout Hasher) {
    a.hash(into: &hasher)
    b.hash(into: &hasher)
    c.hash(into: &hasher)
  }
}
