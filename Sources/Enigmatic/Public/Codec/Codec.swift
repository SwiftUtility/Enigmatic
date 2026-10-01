public enum Codec {
  public protocol Strategy {
    associatedtype BoxedValue
  }

  public protocol DecodeStrategy: Strategy {
    static func decode(decoder: some Decoder) throws -> BoxedValue
  }

  public protocol EncodeStrategy: Strategy {
    static func encode(value: BoxedValue, encoder: some Encoder) throws
  }
}
