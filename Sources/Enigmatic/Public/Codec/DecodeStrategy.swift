public protocol DecodeStrategy: CodecStrategy where CodecKey: Decodable {
  static func decode(key: CodecKey) throws -> CodecValue
}

extension Optional: DecodeStrategy where Wrapped: DecodeStrategy {
  public static func decode(key: CodecKey) throws -> CodecValue {
    guard let key else { return nil }
    return try Wrapped.decode(key: key)
  }
}

extension Array: DecodeStrategy where Element: DecodeStrategy {
  public static func decode(key: CodecKey) throws -> CodecValue {
    try key.map(Element.decode(key:))
  }
}

extension Dictionary: DecodeStrategy where Key: Decodable, Value: DecodeStrategy {
  public static func decode(key: CodecKey) throws -> CodecValue {
    try key.mapValues(Value.decode(key:))
  }
}
