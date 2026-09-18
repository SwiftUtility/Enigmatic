@propertyWrapper
public struct Codec<Strategy: CodecStrategy> {
  public var wrappedValue: Strategy.CodecValue

  public init(wrappedValue: Strategy.CodecValue) {
    self.wrappedValue = wrappedValue
  }
}

extension Codec: Encodable where Strategy: EncodeStrategy {
  public func encode(to encoder: any Encoder) throws {
    let key: Strategy.CodecKey
    do {
      key = try Strategy.encode(value: wrappedValue)
    } catch {
      throw EncodingError.invalidValue(wrappedValue, EncodingError.Context(
        codingPath: encoder.codingPath,
        debugDescription: "Failed to encode mask by \(Strategy.self)",
        underlyingError: error
      ))
    }
    try key.encode(to: encoder)
  }
}

extension Codec: Decodable where Strategy: DecodeStrategy {
  public init(from decoder: any Decoder) throws {
    let key = try Strategy.CodecKey(from: decoder)
    do {
      self.wrappedValue = try Strategy.decode(key: key)
    } catch {
      throw DecodingError.dataCorrupted(DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Failed to decode mask by \(Strategy.self)",
        underlyingError: error
      ))
    }
  }
}

extension Codec: Sendable where Strategy.CodecValue: Sendable {}

extension Codec: Equatable where Strategy.CodecValue: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension Codec: Hashable where Strategy.CodecValue: Hashable {
  public func hash(into hasher: inout Hasher) {
    wrappedValue.hash(into: &hasher)
  }
}

extension Codec: CustomStringConvertible {
  public var description: String {
    String(describing: wrappedValue)
  }
}

extension Codec: CustomDebugStringConvertible {
  public var debugDescription: String {
    String(reflecting: wrappedValue)
  }
}
