extension Enigma {
  struct SelectOneMergeStrategy: Enigma.MergeStrategy {
    let selectNew: Bool
    var pins: [Pin] = []

    mutating func resolve(
      old: Enigma,
      new: Enigma
    ) -> Enigma {
      if selectNew { new } else { old }
    }
  }
}
