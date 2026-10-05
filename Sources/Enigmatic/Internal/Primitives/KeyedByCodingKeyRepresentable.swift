@available(macOS 12.3, iOS 15.4, watchOS 8.5, tvOS 15.4, *)
protocol KeyedByCodingKeyRepresentable {
  func convert(keyed: inout [Enigma.Pin]) throws(DecodingError) -> Enigma
}

@available(macOS 12.3, iOS 15.4, watchOS 8.5, tvOS 15.4, *)
extension Dictionary: KeyedByCodingKeyRepresentable where Key: CodingKeyRepresentable {
  func convert(keyed pins: inout [Enigma.Pin]) throws(DecodingError) -> Enigma {
    var result: [String: Enigma] = [:]
    result.reserveCapacity(count)
    for (key, value) in self {
      let key = key.codingKey.stringValue
      let enigma: Enigma
      do {
        pins.append(Enigma.Pin.str(key))
        defer { pins.removeLast() }
        enigma = try Enigma.make(pins: &pins, value: value)
      }
      guard result.updateValue(enigma, forKey: key) == nil else {
        throw DecodingError.dataCorrupted(DecodingError.Context(
          codingPath: pins,
          debugDescription: "Collision for key \(key)"
        ))
      }
    }
    return .dictionary(result)
  }
}
