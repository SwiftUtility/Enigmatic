class ParentUnkeyed: Codable {
  var ints: [Int]

  init(ints: [Int]) {
    self.ints = ints
  }

  required init(from decoder: Decoder) throws {
    self.ints = try decoder.singleValueContainer().decode([Int].self)
  }

  func encode(to encoder: Encoder) throws {
    try ints.encode(to: encoder)
  }

  final class DefaultKeyedChild: ParentUnkeyed, Equatable {
    var string: String

    override init(ints: [Int]) {
      self.string = "DefaultKeyedChild"
      super.init(ints: ints)
    }

    required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: Keys.self)
      self.string = try container.decode(String.self, forKey: Keys.string)
      try super.init(from: container.superDecoder())
    }

    override func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: Keys.self)
      try container.encode(string, forKey: Keys.string)
      try super.encode(to: container.superEncoder())
    }

    static func ==(lhs: DefaultKeyedChild, rhs: DefaultKeyedChild) -> Bool {
      lhs.string == rhs.string && lhs.ints == rhs.ints
    }

    enum Keys: String, CodingKey {
      case string
    }
  }

  final class CustomKeyedChild: ParentUnkeyed, Equatable {
    var string: String

    override init(ints: [Int]) {
      self.string = "CustomKeyedChild"
      super.init(ints: ints)
    }

    required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: Keys.self)
      self.string = try container.decode(String.self, forKey: Keys.string)
      try super.init(from: container.superDecoder(forKey: Keys.parent))
    }

    override func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: Keys.self)
      try container.encode(string, forKey: Keys.string)
      try super.encode(to: container.superEncoder(forKey: Keys.parent))
    }

    static func ==(lhs: CustomKeyedChild, rhs: CustomKeyedChild) -> Bool {
      lhs.string == rhs.string && lhs.ints == rhs.ints
    }

    enum Keys: String, CodingKey {
      case string
      case parent
    }
  }

  final class ValueUnkeyedChild: ParentUnkeyed, Equatable {
    var string: String

    override init(ints: [Int]) {
      self.string = "UnkeyedChild"
      super.init(ints: ints)
    }

    required init(from decoder: Decoder) throws {
      var container = try decoder.unkeyedContainer()
      self.string = try container.decode(String.self)
      try super.init(from: container.superDecoder())
    }

    override func encode(to encoder: Encoder) throws {
      var container = encoder.unkeyedContainer()
      try container.encode(string)
      try super.encode(to: container.superEncoder())
    }

    static func ==(lhs: ValueUnkeyedChild, rhs: ValueUnkeyedChild) -> Bool {
      lhs.string == rhs.string && lhs.ints == rhs.ints
    }
  }

  final class ArrayUnkeyedChild: ParentUnkeyed, Equatable {
    var strings: [String]

    override init(ints: [Int]) {
      self.strings = ["one", "two"]
      super.init(ints: ints)
    }

    required init(from decoder: Decoder) throws {
      var container = try decoder.unkeyedContainer()
      self.strings = []
      while let string = try? container.decode(String.self) {
        strings.append(string)
      }
      try super.init(from: container.superDecoder())
    }

    override func encode(to encoder: Encoder) throws {
      var container = encoder.unkeyedContainer()
      for string in strings {
        try container.encode(string)
      }
      try super.encode(to: container.superEncoder())
    }

    static func ==(lhs: ArrayUnkeyedChild, rhs: ArrayUnkeyedChild) -> Bool {
      lhs.strings == rhs.strings && lhs.ints == rhs.ints
    }
  }
}
