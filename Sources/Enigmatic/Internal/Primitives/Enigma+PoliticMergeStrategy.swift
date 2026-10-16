extension Enigma {
  struct PoliteMergeStrategy: ~Copyable, Enigma.MergeStrategy {
    let policy: Enigma.MergePolicy

    var handleArrays: Bool {
      true
    }

    mutating func push(pin: @autoclosure () -> Pin) {}
    mutating func popPin() {}

    mutating func resolve(
      old: consuming Enigma,
      new: consuming Enigma
    ) -> Result<Enigma, Never> {
      .success(policy.replaceValue ? new : old)
    }

    mutating func resolve(
      old: consuming [Enigma],
      new: consuming [Enigma]
    ) -> Result<Enigma, Never> {
      switch policy.arrayAction {
      case .zip:
        if old.count < new.count {
          var index = old.count
          while let old = old.popLast() {
            index -= 1
            mergeIntoNew(old: consume old, new: &new[index], handleArrays: true)
          }
          _ = consume old
          return .success(.array(consume new))
        } else {
          var index = new.count
          while let new = new.popLast() {
            index -= 1
            mergeIntoOld(old: &old[index], new: consume new, handleArrays: true)
          }
          _ = consume new
          return .success(.array(consume old))
        }
      case .append:
        old.append(contentsOf: consume new)
        return .success(.array(consume old))
      case .prepend:
        new.append(contentsOf: consume old)
        return .success(.array(consume new))
      case .selectOriginal:
        _ = consume new
        return .success(.array(consume old))
      case .selectOther:
        _ = consume old
        return .success(.array(consume new))
      }
    }
  }
}
