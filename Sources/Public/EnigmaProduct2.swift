import Foundation

extension Enigma {
  /// Product type by merging A and B
  public struct Product2<A, B> {
    public var a: A
    public var b: B

    public init(a: A, b: B) {
      self.a = a
      self.b = b
    }
  }
}

extension Enigma.Product2: Decodable
where A: Decodable, B: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.a = try container.decode(A.self)
    self.b = try container.decode(B.self)
  } 
}

extension Enigma.Product2: Encodable
where A: Encodable, B: Encodable {
  public func encode(to encoder: Encoder) throws {
    try a.encode(to: encoder)
    try b.encode(to: encoder)
  }
}

extension Enigma.Product2: Equatable
where A: Equatable, B: Equatable {
  public static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.a == rhs.a && lhs.b == rhs.b
  }
}

extension Enigma.Product2: Hashable
where A: Hashable, B: Hashable {
  public func hash(into hasher: inout Hasher) {
    a.hash(into: &hasher)
    b.hash(into: &hasher)
  }
}
