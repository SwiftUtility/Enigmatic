struct SelectOneMergeStrategy: Enigma.MergeStrategy {
  var selectNew: Bool

  mutating func resolve(
    ctx: inout Enigma.MergeContext,
    old: Enigma,
    new: Enigma
  ) -> Result<Enigma, Never> {
    if selectNew { .success(new) } else { .success(old) }
  }
}
