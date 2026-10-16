extension Enigma {
  struct InteruptMergeStrategy: ~Copyable, Enigma.MergeStrategy {
    let skipEqual: Bool
    var pins: [Pin] = []

    var handleArrays: Bool { false }

    mutating func push(pin: @autoclosure () -> Pin) {
      pins.append(pin())
    }

    mutating func popPin() {
      pins.removeLast()
    }

    mutating func resolve(
      old: consuming Enigma,
      new: consuming Enigma
    ) -> Result<Enigma, EncodingError> {
      if skipEqual, old == new {
        _ = consume new
        return .success(consume old)
      } else {
        _ = consume old
        return .failure(EncodingError.invalidValue(consume new, EncodingError.Context(
          codingPath: pins,
          debugDescription: "merge failed"
        )))
      }
    }

    mutating func resolve(
      old: consuming [Enigma],
      new: consuming [Enigma]
    ) -> Result<Enigma, EncodingError> {
      resolve(old: .array(consume old), new: .array(consume new))
    }
  }
}
