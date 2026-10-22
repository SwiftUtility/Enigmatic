extension Codec {
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
    /// - Complexity: Defined by the conforming strategy and its input representation.
    static func decode(decoder: some Decoder) throws -> BoxedValue
  }

  /// Decodes the non-null payload of an optional strategy.
  public protocol DecodeOptionalStrategy: DecodeStrategy, OptionalStrategy {
    /// Reads the wrapped value after the decoder has selected a present value.
    /// - Complexity: Defined by the conforming strategy and its wrapped representation.
    static func decodePresent(decoder: some Decoder) throws -> WrappedBoxedValue
  }

  /// Lets keyed decoding initialize an optional wrapper for a missing or null key.
  public protocol OptionalDecoder: Decodable {
    /// Creates a wrapper with a present payload or nil.
    /// - Complexity: Defined by the conforming wrapper.
    init(wrappedValue: Strategy.WrappedBoxedValue?)
    /// The strategy used to decode a present payload.
    associatedtype Strategy: DecodeOptionalStrategy
  }

  /// Writes a value to an encoder using a chosen representation.
  public protocol EncodeStrategy: Strategy {
    /// Encodes one boxed value using this strategy's representation.
    /// - Complexity: Defined by the conforming strategy and boxed value.
    static func encode(value: BoxedValue, encoder: some Encoder) throws
  }

  /// Encodes the non-null payload of an optional strategy.
  public protocol EncodeOptionalStrategy: EncodeStrategy, OptionalStrategy {
    /// Writes the wrapped value after the caller has selected a present value.
    /// - Complexity: Defined by the conforming strategy and wrapped value.
    static func encodePresent(value: WrappedBoxedValue, encoder: some Encoder) throws
  }

  /// Lets keyed encoding omit a nil optional wrapper and encode a present payload.
  public protocol OptionalEncoder: Encodable {
    /// The optional payload; nil causes keyed encoding to omit its key.
    /// - Complexity: Defined by the conforming wrapper.
    var wrappedValue: Strategy.WrappedBoxedValue? { get }
    /// The strategy used to encode a present payload.
    associatedtype Strategy: EncodeOptionalStrategy
  }
}
