import Foundation

extension Enigma {
  /// Product type by merging A, B, C and D
  public struct Product4<A, B, C, D> {
    public var a: A
    public var b: B
    public var c: C
    public var d: D

    public init(a: A, b: B, c: C, d: D) {
      self.a = a
      self.b = b
      self.c = c
      self.d = d
    }
  }
}

extension Enigma.Product4: Decodable
where A: Decodable, B: Decodable, C: Decodable, D: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    try self.a = container.decode(A.self)
    try self.b = container.decode(B.self)
    try self.c = container.decode(C.self)
    try self.d = container.decode(D.self)
  }
}

extension Enigma.Product4: Encodable
where A: Encodable, B: Encodable, C: Encodable, D: Encodable {
  public func encode(to encoder: Encoder) throws {
    try a.encode(to: encoder)
    try b.encode(to: encoder)
    try c.encode(to: encoder)
    try d.encode(to: encoder)
  }
}

extension Enigma.Product4: Equatable
where A: Equatable, B: Equatable, C: Equatable, D: Equatable {
  public static func ==(lhs: Self, rhs: Self) -> Bool {
    return lhs.a == rhs.a && lhs.b == rhs.b && lhs.c == rhs.c && lhs.d == rhs.d
  }
}

extension Enigma.Product4: Hashable
where A: Hashable, B: Hashable, C: Hashable, D: Hashable {
  public func hash(into hasher: inout Hasher) {
    a.hash(into: &hasher)
    b.hash(into: &hasher)
    c.hash(into: &hasher)
    d.hash(into: &hasher)
  }
}
