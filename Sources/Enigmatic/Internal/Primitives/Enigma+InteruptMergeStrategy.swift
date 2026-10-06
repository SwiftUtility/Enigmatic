extension Enigma {
  struct InteruptMergeStrategy: Enigma.MergeStrategy {
    let skipEqual: Bool
    var pins: [Pin] = []

    mutating func resolve(old: Enigma, new: Enigma) throws(EncodingError) -> Enigma {
      guard !skipEqual || old != new else { return old }
      throw EncodingError.invalidValue(new, EncodingError.Context(
        codingPath: pins,
        debugDescription: "attempt to replace \(old)"
      ))
    }
  }
}
