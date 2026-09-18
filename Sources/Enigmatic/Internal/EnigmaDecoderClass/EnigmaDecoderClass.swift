enum EnigmaDecoderClass {
  struct Link {
    let prev: any Container
    let key: any CodingKey

    init(prev: some Container, key: some CodingKey) {
      self.prev = prev
      self.key = key
    }
  }

  protocol Container {
    var link: Link? { get }
  }
}

extension EnigmaDecoderClass.Container {
  func path() -> [any CodingKey] {
    var result: [any CodingKey] = []
    var link = link
    while let current = link {
      result.append(current.key)
      link = current.prev.link
    }
    result.reverse()
    return result
  }

  func path(key: any CodingKey) -> [any CodingKey] {
    var result: [any CodingKey] = [key]
    var link = link
    while let current = link {
      result.append(current.key)
      link = current.prev.link
    }
    result.reverse()
    return result
  }
}
