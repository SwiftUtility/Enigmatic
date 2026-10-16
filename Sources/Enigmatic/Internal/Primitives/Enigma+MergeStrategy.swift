extension Enigma {
  protocol MergeStrategy<Fail>: ~Copyable {
    var handleArrays: Bool { get }
    mutating func push(pin: @autoclosure () -> Pin)
    mutating func popPin()
    mutating func resolve(old: consuming Enigma, new: consuming Enigma) -> Result<Enigma, Fail>
    mutating func resolve(old: consuming [Enigma], new: consuming [Enigma]) -> Result<Enigma, Fail>
    associatedtype Fail: Error
  }
}

extension Enigma.MergeStrategy where Self: ~Copyable {
  mutating func mergeIntoOld(
    old: inout Enigma,
    new: consuming Enigma,
    handleArrays: Bool
  ) -> Fail? {
    let new = consume new
    if case .dictionary(var result) = old, case .dictionary(let values) = new {
      _ = consume old
      _ = consume new
      var fail: Fail?
      for (key, value) in values {
        if var old = result.removeValue(forKey: key) {
          push(pin: .str(key))
          defer { popPin() }
          fail = mergeIntoOld(old: &old, new: consume value, handleArrays: handleArrays)
          result[key] = consume old
          guard fail == nil else { break }
        } else {
          result[key] = consume value
        }
      }
      old = .dictionary(consume result)
      return fail
    } else if handleArrays, case .array(let result) = old, case .array(let values) = new {
      _ = consume old
      _ = consume new
      switch resolve(old: consume result, new: consume values) {
      case .success(let value):
        old = consume value
        return nil
      case .failure(let fail):
        old = .null
        return fail
      }
    } else {
      switch resolve(old: consume old, new: consume new) {
      case .success(let value):
        old = consume value
        return nil
      case .failure(let fail):
        old = .null
        return fail
      }
    }
  }

  mutating func mergeIntoNew(
    old: consuming Enigma,
    new: inout Enigma,
    handleArrays: Bool
  ) -> Fail? {
    let old = consume old
    if case .dictionary(let values) = old, case .dictionary(var result) = new {
      _ = consume old
      _ = consume new
      var fail: Fail?
      for (key, value) in values {
        if var new = result.removeValue(forKey: key) {
          push(pin: .str(key))
          defer { popPin() }
          fail = mergeIntoNew(old: consume value, new: &new, handleArrays: handleArrays)
          result[key] = consume new
          guard fail == nil else { break }
        } else {
          result[key] = consume value
        }
      }
      new = .dictionary(consume result)
      return fail
    } else if handleArrays, case .array(let values) = old, case .array(let result) = new {
      _ = consume old
      _ = consume new
      switch resolve(old: consume values, new: consume result) {
      case .success(let value):
        new = consume value
        return nil
      case .failure(let fail):
        new = .null
        return fail
      }
    } else {
      switch resolve(old: consume old, new: consume new) {
      case .success(let value):
        new = consume value
        return nil
      case .failure(let fail):
        new = .null
        return fail
      }
    }
  }

  consuming func atomicMerge(old: inout Enigma, new: inout Enigma) -> Fail? {
    if let fail = mergeIntoNew(old: old, new: &new, handleArrays: handleArrays) {
      return fail
    } else {
      old = consume new
      new = .null
      return nil
    }
  }

  consuming func inplaceMerge(old: inout Enigma, new: inout Enigma) -> Fail? {
    if let fail = mergeIntoOld(old: &old, new: consume new, handleArrays: handleArrays) {
      new = .null
      return fail
    } else {
      new = .null
      return nil
    }
  }
}
