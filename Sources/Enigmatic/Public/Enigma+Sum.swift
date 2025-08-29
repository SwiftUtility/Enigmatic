@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Enigma {
  public struct Sum<each Value> {
    public var values: (repeat Optional<each Value>)
  }
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Enigma.Sum: Sendable where repeat each Value: Sendable {}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Enigma.Sum: Decodable where repeat each Value: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.values = (repeat try? container.decode((each Value).self))
  }
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Enigma.Sum: Encodable where repeat each Value: Encodable {
  public func encode(to encoder: Encoder) throws {
    for value in repeat each values {
      guard let value else { continue }
      try value.encode(to: encoder)
    }
  }
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Enigma.Sum: Equatable where repeat each Value: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    for (lhs, rhs) in repeat (each lhs.values, each rhs.values) {
      guard lhs == rhs else { return false }
    }
    return true
  }
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension Enigma.Sum: Hashable where repeat each Value: Hashable {
  public func hash(into hasher: inout Hasher) {
    for value in repeat each values {
      value.hash(into: &hasher)
    }
  }
}
