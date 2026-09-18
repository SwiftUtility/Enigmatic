enum EnigmaDecoder {
  enum Storage {
    case unset
    case value(Enigma)
    case keyedId(Int)
    case unkeyedId(Int)
  }

  struct Node {
    var storage: Storage = .unset
    let link: Link?
  }

  struct Link {
    let prev: Int
    let key: any CodingKey
  }

  struct Ref {
    var nodeId: Int
    var failId: Int?
  }
}
