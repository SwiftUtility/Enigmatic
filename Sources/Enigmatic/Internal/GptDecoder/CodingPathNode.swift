final class CodingPathNode {
  let parent: CodingPathNode?
  let key: any CodingKey

  init(
    parent: CodingPathNode?,
    key: any CodingKey
  ) {
    self.parent = parent
    self.key = key
  }
}

@inline(never)
func makeCodingPath(
  _ path: CodingPathNode?
) -> [CodingKey] {
  var result: [CodingKey] = []
  var current = path

  while let node = current {
    result.append(node.key)
    current = node.parent
  }

  result.reverse()
  return result
}

@inline(never)
func makeCodingPath(
  _ path: CodingPathNode?,
  appending key: any CodingKey
) -> [CodingKey] {
  var result: [CodingKey] = []
  var current = path

  while let node = current {
    result.append(node.key)
    current = node.parent
  }

  result.reverse()
  result.append(key)

  return result
}
