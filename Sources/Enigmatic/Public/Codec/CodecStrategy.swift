public protocol CodecStrategy {
  associatedtype CodecValue
  associatedtype CodecKey
}

extension Optional: CodecStrategy where Wrapped: CodecStrategy {
  public typealias CodecValue = Wrapped.CodecValue?
  public typealias CodecKey = Wrapped.CodecKey?
}

extension Array: CodecStrategy where Element: CodecStrategy {
  public typealias CodecValue = [Element.CodecValue]
  public typealias CodecKey = [Element.CodecKey]
}

extension Dictionary: CodecStrategy where Value: CodecStrategy {
  public typealias CodecValue = [Key: Value.CodecValue]
  public typealias CodecKey = [Key: Value.CodecKey]
}
