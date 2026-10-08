import Foundation

@usableFromInline
final class EnigmaDecoder {
  let userInfo: [CodingUserInfoKey: Any]
  private var path: [Link?] = [nil]

  private init(userInfo: [CodingUserInfoKey : Any]) {
    self.userInfo = userInfo
  }

  func path(pathId: Int) -> [any CodingKey] {
    var result: [any CodingKey] = []
    var link = path[pathId]
    while let current = link {
      result.append(current.key)
      link = path[current.prev]
    }
    result.reverse()
    return result
  }

  func path(pathId: Int, key: any CodingKey) -> [any CodingKey] {
    var result: [any CodingKey] = [key]
    var link = path[pathId]
    while let current = link {
      result.append(current.key)
      link = path[current.prev]
    }
    result.reverse()
    return result
  }

  func nested(pathId: Int, key: any CodingKey) -> Int {
    defer { path.append(Link(prev: pathId, key: key)) }
    return path.count
  }

  @usableFromInline
  static func decoder(enigma: Enigma, userInfo: [CodingUserInfoKey : Any]) -> Single {
    Single(state: EnigmaDecoder(userInfo: userInfo), value: enigma, pathId: 0)
  }

  struct Link {
    let prev: Int
    let key: any CodingKey
  }
}
