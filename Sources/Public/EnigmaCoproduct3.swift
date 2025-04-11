import Foundation

extension Enigma {
  /// Sum type that is either A, B or C
  public enum Coproduct3<A, B, C> {
    case a(A)
    case b(B)
    case c(C)

    public var a: A? { if case .a(let a) = self { a } else { nil } }
    public var b: B? { if case .b(let b) = self { b } else { nil } }
    public var c: C? { if case .c(let c) = self { c } else { nil } }
  }
}

extension Enigma.Coproduct3: Decodable
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

extension Enigma.Coproduct3: Encodable
where A: Encodable, B: Encodable, C: Encodable {
  public func encode(to encoder: Encoder) throws {
    switch self {
    case .a(let one): try one.encode(to: encoder)
    case .b(let two): try two.encode(to: encoder)
    case .c(let three): try three.encode(to: encoder)
    }
  }
}

extension Enigma.Coproduct3: Equatable
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

extension Enigma.Coproduct3: Hashable
where A: Hashable, B: Hashable, C: Hashable {
  public func hash(into hasher: inout Hasher) {
    switch self {
    case .a(let value): value.hash(into: &hasher)
    case .b(let value): value.hash(into: &hasher)
    case .c(let value): value.hash(into: &hasher)
    }
  }
}
