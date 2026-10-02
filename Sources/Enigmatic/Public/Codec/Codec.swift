/// Composable strategies for choosing a Codable representation.
public enum Codec {
  /// Associates a coding strategy with its unwrapped Swift value.
  public protocol Strategy {
    /// The value stored by a property wrapper using this strategy.
    associatedtype BoxedValue
  }

  /// Reads a value from a decoder using a chosen representation.
  public protocol DecodeStrategy: Strategy {
    static func decode(decoder: some Decoder) throws -> BoxedValue
  }

  /// Writes a value to an encoder using a chosen representation.
  public protocol EncodeStrategy: Strategy {
    static func encode(value: BoxedValue, encoder: some Encoder) throws
  }
}
