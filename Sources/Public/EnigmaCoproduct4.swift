import Foundation

extension Enigma {
  /// Sum type that is either A, B, C or D
  public enum Coproduct4<A, B, C, D> {
    case a(A)
    case b(B)
    case c(C)
    case d(D)

    public var a: A? { if case .a(let a) = self { return a } else { return nil } }
    public var b: B? { if case .b(let b) = self { return b } else { return nil } }
    public var c: C? { if case .c(let c) = self { return c } else { return nil } }
    public var d: D? { if case .d(let d) = self { return d } else { return nil } }
  }
}

extension Enigma.Coproduct4: Decodable
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

extension Enigma.Coproduct4: Encodable
where A: Encodable, B: Encodable, C: Encodable, D: Encodable {
  public func encode(to encoder: Encoder) throws {
    switch self {
    case .a(let one): try one.encode(to: encoder)
    case .b(let two): try two.encode(to: encoder)
    case .c(let three): try three.encode(to: encoder)
    case .d(let four): try four.encode(to: encoder)
    }
  }
}

extension Enigma.Coproduct4: Equatable
where A: Equatable, B: Equatable, C: Equatable, D: Equatable {
  public static func ==(lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.a(let lhs), .a(let rhs)): return lhs == rhs
    case (.b(let lhs), .b(let rhs)): return lhs == rhs
    case (.c(let lhs), .c(let rhs)): return lhs == rhs
    case (.d(let lhs), .d(let rhs)): return lhs == rhs
    default: return false
    }
  }
}

extension Enigma.Coproduct4: Hashable
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
