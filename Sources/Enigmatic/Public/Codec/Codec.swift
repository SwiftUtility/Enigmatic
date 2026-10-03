/// Composable strategies for choosing a Codable representation.
public enum Codec {
  /// Associates a coding strategy with its unwrapped Swift value.
  public protocol Strategy {
    /// The value stored by a property wrapper using this strategy.
    associatedtype BoxedValue
  }

  /// A strategy whose boxed value can be absent.
  public protocol OptionalStrategy: Strategy {
    /// The non-optional value handled when the optional is present.
    associatedtype WrappedBoxedValue where BoxedValue == WrappedBoxedValue?
  }

  /// Reads a value from a decoder using a chosen representation.
  public protocol DecodeStrategy: Strategy {
    /// Decodes one value using this strategy's representation.
    static func decode(decoder: some Decoder) throws -> BoxedValue
  }

  /// Decodes the non-null payload of an optional strategy.
  public protocol DecodeOptionalStrategy: DecodeStrategy, OptionalStrategy {
    /// Reads the wrapped value after the decoder has selected a present value.
    static func decodePresent(decoder: some Decoder) throws -> WrappedBoxedValue
  }

  /// Writes a value to an encoder using a chosen representation.
  public protocol EncodeStrategy: Strategy {
    /// Encodes one boxed value using this strategy's representation.
    static func encode(value: BoxedValue, encoder: some Encoder) throws
  }

  /// Encodes the non-null payload of an optional strategy.
  public protocol EncodeOptionalStrategy: EncodeStrategy, OptionalStrategy {
    /// Writes the wrapped value after the caller has selected a present value.
    static func encodePresent(value: WrappedBoxedValue, encoder: some Encoder) throws
  }
}
