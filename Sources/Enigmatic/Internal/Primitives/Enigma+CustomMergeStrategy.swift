extension Enigma {
  struct CustomMergeStrategy<Fail: Error>: ~Copyable, Enigma.MergeStrategy {
    let block: ([Enigma.Pin], Enigma, Enigma) throws(Fail) -> Enigma
    var pins: [Pin] = []

    mutating func resolve(old: Enigma, new: Enigma) throws(Fail) -> Enigma {
      try block(pins, old, new)
    }
  }
}
