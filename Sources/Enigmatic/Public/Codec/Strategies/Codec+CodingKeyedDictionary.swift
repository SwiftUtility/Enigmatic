@available(macOS 12.3, iOS 15.4, watchOS 8.5, tvOS 15.4, *)
extension Codec {
  /// Streams dictionary entries through a keyed container using each value's strategy.
  /// Keys need not be Codable. Decoding rejects invalid keys and aliases of an existing key.
  public enum CodingKeyedDictionary<Key, Value>: Codec.Strategy
  where Key: Hashable & CodingKeyRepresentable, Value: Codec.Strategy {
    /// The dictionary of unboxed values.
    public typealias BoxedValue = [Key: Value.BoxedValue]
  }
}

@available(macOS 12.3, iOS 15.4, watchOS 8.5, tvOS 15.4, *)
extension Codec.CodingKeyedDictionary: Codec.DecodeStrategy where Value: Codec.DecodeStrategy {
  /// Decodes keyed entries and rejects key conversion failures or collisions.
  @inlinable
  public static func decode(decoder: some Decoder) throws -> BoxedValue {
    let container = try decoder.container(keyedBy: Enigma.Pin.self)
    let pins = container.allKeys
    var result: BoxedValue = [:]
    result.reserveCapacity(pins.count)
    for pin in pins {
      guard let key = Key(codingKey: pin) else {
        throw DecodingError.dataCorrupted(DecodingError.Context(
          codingPath: decoder.codingPath + [pin],
          debugDescription: "failed to create \(Key.self) from \(pin)"
        ))
      }
      guard result[key] == nil else {
        throw DecodingError.dataCorrupted(DecodingError.Context(
          codingPath: decoder.codingPath + [key.codingKey],
          debugDescription: "collision detected"
        ))
      }
      result[key] = try container.decode(Codec.Box<Value>.self, forKey: pin).wrappedValue
    }
    return result
  }
}

@available(macOS 12.3, iOS 15.4, watchOS 8.5, tvOS 15.4, *)
extension Codec.CodingKeyedDictionary: Codec.EncodeStrategy where Value: Codec.EncodeStrategy {
  /// Encodes entries using the string representation of each key's coding key.
  @inlinable
  public static func encode(value: BoxedValue, encoder: some Encoder) throws {
    var container = encoder.container(keyedBy: Enigma.Pin.self)
    for (key, value) in value {
      let pin = Enigma.Pin.str(key.codingKey.stringValue)
      try container.encode(Codec.Box<Value>(wrappedValue: value), forKey: pin)
    }
  }
}
