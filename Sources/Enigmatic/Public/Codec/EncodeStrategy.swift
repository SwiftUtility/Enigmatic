public protocol EncodeStrategy: CodecStrategy where CodecKey: Encodable {
  static func encode(value: CodecValue) throws -> CodecKey
}

extension Optional: EncodeStrategy where Wrapped: EncodeStrategy {
  public static func encode(value: CodecValue) throws -> CodecKey {
    guard let value else { return nil }
    return try Wrapped.encode(value: value)
  }
}

extension Array: EncodeStrategy where Element: EncodeStrategy {
  public static func encode(value: CodecValue) throws -> CodecKey {
    try value.map(Element.encode(value:))
  }
}

extension Dictionary: EncodeStrategy where Key: Encodable, Value: EncodeStrategy {
  public static func encode(value: CodecValue) throws -> CodecKey {
    try value.mapValues(Value.encode(value:))
  }
}
