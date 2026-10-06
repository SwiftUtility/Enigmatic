struct InteruptMergeStrategy: Enigma.MergeStrategy {
  var skipEqual: Bool

  mutating func resolve(
    ctx: inout Enigma.MergeContext,
    old: Enigma,
    new: Enigma
  ) -> Result<Enigma, EncodingError> {
    guard !skipEqual || old != new else { return .success(old) }
    return .failure(ctx.error(new, info: "attempt to replace \(old)"))
  }
}
