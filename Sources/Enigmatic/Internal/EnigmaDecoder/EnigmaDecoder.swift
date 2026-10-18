import Foundation

@usableFromInline
final class EnigmaDecoder {
  let userInfo: [CodingUserInfoKey: Any]
  private var path: [Link] = []

  private init(userInfo: [CodingUserInfoKey : Any]) {
    self.userInfo = userInfo
  }

  func path(pathId: consuming Int) -> [any CodingKey] {
    var result: [any CodingKey] = []
    while pathId < Int.max {
      result.append(path[pathId].key)
      pathId = path[pathId].prev
    }
    result.reverse()
    return result
  }

  func path(pathId: consuming Int, key: any CodingKey) -> [any CodingKey] {
    var result: [any CodingKey] = [key]
    while pathId < Int.max {
      result.append(path[pathId].key)
      pathId = path[pathId].prev
    }
    result.reverse()
    return result
  }

  func nested(pathId: consuming Int, key: any CodingKey) -> Int {
    defer { path.append(Link(prev: pathId, key: key)) }
    return path.count
  }

  @usableFromInline
  static func decoder(enigma: Enigma, userInfo: [CodingUserInfoKey : Any]) -> Single {
    Single(state: EnigmaDecoder(userInfo: userInfo), value: enigma, pathId: .max)
  }

  struct Link {
    let prev: Int
    let key: any CodingKey
  }
}
