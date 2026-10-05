extension Enigma {
  public protocol MergeStrategy<Fail>: ~Copyable {
    mutating func merge(ctx: inout MergeContext, old: Enigma, new: Enigma) -> Result<Enigma, Fail>
    mutating func resolve(ctx: inout MergeContext, old: Enigma, new: Enigma) -> Result<Enigma, Fail>

    associatedtype Fail: Error
  }
}

extension Enigma.MergeStrategy where Self: ~Copyable {
  public mutating func merge(
    ctx: inout Enigma.MergeContext,
    old: Enigma,
    new: Enigma
  ) -> Result<Enigma, Fail> {
    guard case (.dictionary(var result), .dictionary(let new)) = (old, new) else {
      return resolve(ctx: &ctx, old: old, new: new)
    }
    for (key, value) in new {
      if let old = result[key] {
        switch ctx.recurse(&self, pin: .str(key), old: old, new: value) {
        case .success(let value): result[key] = value
        case .failure(let error): return .failure(error)
        }
      } else {
        result[key] = value
      }
    }
    return .success(.dictionary(result))
  }
}
