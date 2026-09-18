import Foundation

struct UnkeyedDecoder: UnkeyedDecodingContainer {
  let values: [Enigma]
  let path: CodingPathNode?

  var currentIndex = 0

  var codingPath: [CodingKey] {
    makeCodingPath(path)
  }

  var count: Int? {
    values.count
  }

  var isAtEnd: Bool {
    currentIndex >= values.count
  }

  mutating func decodeNil() throws -> Bool {
    guard !isAtEnd else {
      return false
    }

    guard values[currentIndex].isNull else {
      return false
    }

    currentIndex += 1
    return true
  }

  mutating func decode(_ type: Bool.Type) throws -> Bool {
    try scalar(type, extract: \.asBool)
  }

  mutating func decode(_ type: String.Type) throws -> String {
    try scalar(type, extract: \.asString)
  }

  mutating func decode(_ type: Double.Type) throws -> Double {
    try scalar(type, extract: \.asDouble)
  }

  mutating func decode(_ type: Float.Type) throws -> Float {
    try scalar(type, extract: \.asFloat)
  }

  mutating func decode(_ type: Int.Type) throws -> Int {
    try scalar(type, extract: \.asInt)
  }

  mutating func decode(_ type: Int8.Type) throws -> Int8 {
    try scalar(type, extract: \.asInt8)
  }

  mutating func decode(_ type: Int16.Type) throws -> Int16 {
    try scalar(type, extract: \.asInt16)
  }

  mutating func decode(_ type: Int32.Type) throws -> Int32 {
    try scalar(type, extract: \.asInt32)
  }

  mutating func decode(_ type: Int64.Type) throws -> Int64 {
    try scalar(type, extract: \.asInt64)
  }

  mutating func decode(_ type: UInt.Type) throws -> UInt {
    try scalar(type, extract: \.asUInt)
  }

  mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
    try scalar(type, extract: \.asUInt8)
  }

  mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
    try scalar(type, extract: \.asUInt16)
  }

  mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
    try scalar(type, extract: \.asUInt32)
  }

  mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
    try scalar(type, extract: \.asUInt64)
  }

  mutating func decode<T: Decodable>(
    _ type: T.Type
  ) throws -> T {
    let (index, value) = try next(type)

    if type == Data.self, let result = value.asData as? T {
      return result
    } else if type == Date.self, let result = value.asDate as? T {
      return result
    } else {
      return try T(from: ValueDecoder(value: value, path: CodingPathNode(parent: path, key: Enigma.Pin.int(index))))
    }
  }

  mutating func nestedContainer<NestedKey: CodingKey>(
    keyedBy _: NestedKey.Type
  ) throws -> KeyedDecodingContainer<NestedKey> {
    let index = currentIndex
    let value = try nextValue([String: Enigma].self)

    guard let values = value.asDictionary else {
      throw DecodingError.typeMismatch(
        [String: Enigma].self,
        .init(
          codingPath: makeCodingPath(
            path,
            appending: Enigma.Pin.int(index)
          ),
          debugDescription: "Expected dictionary"
        )
      )
    }

    return KeyedDecodingContainer(
      KeyedDecoder<NestedKey>(
        values: values,
        path: CodingPathNode(
          parent: path,
          key: Enigma.Pin.int(index)
        )
      )
    )
  }

  mutating func nestedUnkeyedContainer()
    throws -> UnkeyedDecodingContainer
  {
    let index = currentIndex
    let value = try nextValue([Enigma].self)

    guard let values = value.asArray else {
      throw DecodingError.typeMismatch(
        [Enigma].self,
        .init(
          codingPath: makeCodingPath(
            path,
            appending: Enigma.Pin.int(index)
          ),
          debugDescription: "Expected array"
        )
      )
    }

    return UnkeyedDecoder(
      values: values,
      path: CodingPathNode(
        parent: path,
        key: Enigma.Pin.int(index)
      )
    )
  }

  mutating func superDecoder() throws -> Decoder {
    let (index, value) = try next(Enigma.self)

    return ValueDecoder(
      value: value,
      path: CodingPathNode(
        parent: path,
        key: Enigma.Pin.int(index)
      )
    )
  }

  @inline(__always)
  private mutating func scalar<T>(
    _ type: T.Type,
    extract: KeyPath<Enigma, T?>
  ) throws -> T {
    let index = currentIndex

    guard index < values.count else {
      throw valueNotFound(type)
    }

    let value = values[index]

    if let result = value[keyPath: extract] {
      currentIndex = index + 1
      return result
    }

    throw DecodingError.typeMismatch(
      type,
      .init(
        codingPath: makeCodingPath(
          path,
          appending: Enigma.Pin.int(index)
        ),
        debugDescription: "Expected \(type)"
      )
    )
  }

  @inline(__always)
  private mutating func next<T>(
    _ type: T.Type
  ) throws -> (Int, Enigma) {
    let index = currentIndex

    guard index < values.count else {
      throw valueNotFound(type)
    }

    currentIndex = index + 1
    return (index, values[index])
  }

  @inline(__always)
  private mutating func nextValue<T>(
    _ type: T.Type
  ) throws -> Enigma {
    let index = currentIndex

    guard index < values.count else {
      throw valueNotFound(type)
    }

    currentIndex = index + 1
    return values[index]
  }

  private func valueNotFound<T>(
    _ type: T.Type
  ) -> DecodingError {
    .valueNotFound(
      type,
      .init(
        codingPath: codingPath,
        debugDescription: "Unkeyed container is at end"
      )
    )
  }
}
