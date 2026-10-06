extension Enigma {
  protocol MergeStrategy<Fail>: ~Copyable {
    var pins: [Pin] { get set }
    mutating func resolve(old: Enigma, new: Enigma) throws(Fail) -> Enigma
    associatedtype Fail: Error
  }
}

extension Enigma.MergeStrategy where Self: ~Copyable {
  mutating func recursive(old: Enigma, new: Enigma) throws(Fail) -> Enigma {
    guard case (.dictionary(var result), .dictionary(let new)) = (old, new) else {
      return try resolve(old: old, new: new)
    }
    for (key, value) in new {
      if let old = result[key] {
        pins.append(.str(key))
        defer { pins.removeLast() }
        result[key] = try recursive(old: old, new: value)
      } else {
        result[key] = value
      }
    }
    return .dictionary(result)
  }

  consuming func merge(old: Enigma, new: Enigma) -> Result<Enigma, Fail> {
    do {
      return try .success(recursive(old: old, new: new))
    } catch {
      return .failure(error)
    }
  }
}
