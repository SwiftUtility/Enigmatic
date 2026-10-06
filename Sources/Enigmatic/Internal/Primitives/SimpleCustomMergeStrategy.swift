struct SimpleCustomMergeStrategy<Fail: Error>: ~Copyable, Enigma.MergeStrategy {
  let block: ([Enigma.Pin], Enigma, Enigma) throws(Fail) -> Enigma

  mutating func resolve(
    ctx: inout Enigma.MergeContext,
    old: Enigma,
    new: Enigma
  ) -> Result<Enigma, Fail> {
    do {
      return try .success(block(ctx.pins, old, new))
    } catch {
      return .failure(error)
    }
  }
}
