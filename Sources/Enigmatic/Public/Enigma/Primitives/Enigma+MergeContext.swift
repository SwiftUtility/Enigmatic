extension Enigma {
  public struct MergeContext: ~Copyable {
    public private(set) var pins: [Pin] = []

    public func error(_ value: Any, info: String? = nil, other: (any Error)? = nil) -> EncodingError {
      EncodingError.invalidValue(value, EncodingError.Context(
        codingPath: pins,
        debugDescription: info ?? "merge failed",
        underlyingError: other
      ))
    }

    public mutating func recurse<Fail: Error>(
      _ strategy: inout some MergeStrategy<Fail> & ~Copyable,
      pin: Pin,
      old: Enigma,
      new: Enigma
    ) -> Result<Enigma, Fail> {
      pins.append(pin)
      defer { pins.removeLast() }
      return strategy.merge(ctx: &self, old: old, new: new)
    }
  }
}
