extension Enigma {
  struct CustomMergeStrategy<Fail: Error>: ~Copyable, Enigma.MergeStrategy {
    let block: ([Enigma.Pin], Enigma, Enigma) throws(Fail) -> Enigma
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
    ) -> Result<Enigma, Fail> {
      do {
        return try .success(block(pins, consume old, consume new))
      } catch {
        return .failure(error)
      }
    }
    
    mutating func resolve(
      old: consuming [Enigma],
      new: consuming [Enigma]
    ) -> Result<Enigma, Fail> {
      resolve(old: .array(consume old), new: .array(consume new))
    }
  }
}
