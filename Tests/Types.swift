@testable import Enigmatic
import Foundation

struct Ninja: Codable, Equatable {
  init() {}
  init(from decoder: Decoder) throws { self = Self() }
  func encode(to encoder: Encoder) throws {}
  static func ==(lhs: Self, rhs: Self) -> Bool { true }
}

struct True: Codable, Equatable {
  var bool = true
}

struct False: Codable, Equatable {
  var bool = false
}

struct A: Codable, Equatable {
  var int1: Int = 1
  var string1: String = "a"
}

struct B: Codable, Equatable {
  var int2: Int = 2
  var string2: String = "b"
}

struct C: Codable, Equatable {
  var int3: Int = 3
  var string3: String = "c"
}

struct D: Codable, Equatable {
  var int4: Int = 4
  var string4: String = "d"
}

struct Complex: Codable, Equatable {
  var maxInts = MaxInts()
  var minInts = MinInts()
  var optInts = OptInts()
  var nilInts = NilInts()
  var maxUInts = MaxUInts()
  var optUInts = OptUInts()
  var nilUInts = NilUInts()
  var floats = Floats()
  var custom = Custom()
  var optCustom = OptCustom()
  var nilCustom = NilCustom()
  var arrays = Arrays()
  var dicts = Dicts()
  var boolKeyDict: [Bool: String?] = [true: "", false: nil]
  var floatKeyDict: [Float: String?] = [0.1: "", 0.0001: nil]
  var doubleKeyDict: [Double: String?] = [0.1: "", 0.0001: nil]
  var optKeyDict: [String?: String?] = ["": nil, nil: "nil"]
  var enigmaNullKeyDict: [Enigma: String] = [nil: "nil"]
  var enigmaBoolKeyDict: [Enigma: String] = [
    true: "bool", -1: "int", 0: "uint",
    0.1: "double", .float(0.5): "float",
    "string": "string\nval", [nil]: "[null]", [:]: "[:]",
  ]
  var enigmaIntKeyDict: [Enigma: String] = [1: "int"]
  var enigmaUIntKeyDict: [Enigma: String] = [0: "uint"]
  var enigmaDoubleKeyDict: [Enigma: String] = [0.1: "double"]
  var enigmaFloatKeyDict: [Enigma: String] = [.float(0.5): "float"]
  var enigmaStringKeyDict: [Enigma: String] = ["string": "string\n\"val\""]
  var enigmaArrayKeyDict: [Enigma: String] = [[]: "[]"]
  var enigmaDictionaryKeyDict: [Enigma: String] = [[:]: "[:]"]
}

struct MaxInts: Codable, Equatable {
  var int: Int = .max
  var int64: Int64 = .max
  var int32: Int32 = .max
  var int16: Int16 = .max
  var int8: Int8 = .max
}

struct MinInts: Codable, Equatable {
  var int: Int = .min
  var int64: Int64 = .min
  var int32: Int32 = .min
  var int16: Int16 = .min
  var int8: Int8 = .min
}

struct OptInts: Codable, Equatable {
  var pint: Int? = 42
  var pint64: Int64? = 42
  var pint32: Int32? = 42
  var pint16: Int16? = 42
  var pint8: Int8? = 42
  var nint: Int? = -42
  var nint64: Int64? = -42
  var nint32: Int32? = -42
  var nint16: Int16? = -42
  var nint8: Int8? = -42
}

struct NilInts: Codable, Equatable {
  var int: Int? = nil
  var int64: Int64? = nil
  var int32: Int32? = nil
  var int16: Int16? = nil
  var int8: Int8? = nil
}

struct MaxUInts: Codable, Equatable {
  var int: UInt = .max
  var int64: UInt64 = .max
  var int32: UInt32 = .max
  var int16: UInt16 = .max
  var int8: UInt8 = .max
}

struct OptUInts: Codable, Equatable {
  var int: UInt? = 42
  var int64: UInt64? = 42
  var int32: UInt32? = 42
  var int16: UInt16? = 42
  var int8: UInt8? = 42
}

struct NilUInts: Codable, Equatable {
  var int: UInt? = nil
  var int64: UInt64? = nil
  var int32: UInt32? = nil
  var int16: UInt16? = nil
  var int8: UInt8? = nil
}

struct Floats: Codable, Equatable {
  var maxFloat = Float.infinity
  var minFloat = -Float.infinity
  var maxDouble = Double.infinity
  var minDouble = -Double.infinity
  var pbigDouble = 1.111111111111111e307 as Double
  var pbigFloat = 1.1111111e38 as Float
  var nbigDouble = -1.111111111111111e307 as Double
  var nbigFloat = -1.1111111e38 as Float
  var pSemiFloatDouble = 1.1111111e38 as Double
}

struct Custom: Codable, Equatable {
  var url = URL(string: "net://net:net@net.net/net?net=net&net=net#net")!
  var date = Date(timeIntervalSinceReferenceDate: 1)
  var data = Data("Hello Data".utf8)
  var bool = true
  var string = ""
}

struct OptCustom: Codable, Equatable {
  var url: URL? = URL(string: "net://net:net@net.net/net?net=net&net=net#net")
  var date: Date? = Date(timeIntervalSince1970: 1)
  var data: Data? = Data("Hello Data".utf8)
  var bool: Bool? = false
  var string: String? = "Hello\nString"
}

struct NilCustom: Codable, Equatable {
  var url: URL? = nil
  var date: Date? = nil
  var data: Data? = nil
  var bool: Bool? = nil
  var string: String? = nil
}

struct Arrays: Codable, Equatable {
  var array: [Int] = [1, 2]
  var empArray: [Int] = []
  var optArray: [Int]? = [1, 2]
  var nilArray: [Int]? = nil
  var dictsArray: [[Int: Int?]?] = [[1: 1, 2: nil], [3: 3], [:], nil]
}

struct Dicts: Codable, Equatable {
  var dict: [String: Int] = ["": 0, "one": 1, "two": 2]
  var empDict: [String: Int] = [:]
  var optDict: [String: Int]? = ["": 0, "one": 1, "two": 2]
  var nilDict: [String: Int]? = nil
  var intDict: [Int: Int] = [1: 1, 2: 2]
  var intKeyDict: [IntKeys: Int?] = [.zero: nil, .one: 1, .two: 2]
  var strKeyDict: [StringKeys: Bool?] = [.zero: nil, .one: true, .two: false]
}

enum StringKeys: String, Codable, Equatable {
  case zero
  case one
  case two
}

enum IntKeys: Int, Codable, Equatable {
  case zero
  case one
  case two
}

class KeyedParent: Codable {
  var int: Int?

  init(int: Int?) {
    self.int = int
  }

  final class DefaultKeyedChild: KeyedParent, Equatable {
    var string: String

    override init(int: Int?) {
      self.string = "DefaultKeyedChild"
      super.init(int: int)
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
      lhs.string == rhs.string && lhs.int == rhs.int
    }

    enum Keys: String, CodingKey {
      case string
    }
  }

  final class CustomKeyedChild: KeyedParent, Equatable {
    var string: String

    override init(int: Int?) {
      self.string = "CustomKeyedChild"
      super.init(int: int)
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
      lhs.string == rhs.string && lhs.int == rhs.int
    }

    enum Keys: String, CodingKey {
      case string
      case parent
    }
  }

  final class ValueUnkeyedChild: KeyedParent, Equatable {
    var string: String

    override init(int: Int?) {
      self.string = "UnkeyedChild"
      super.init(int: int)
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
      lhs.string == rhs.string && lhs.int == rhs.int
    }
  }

  final class ArrayUnkeyedChild: KeyedParent, Equatable {
    var strings: [String]

    override init(int: Int?) {
      self.strings = ["one", "two"]
      super.init(int: int)
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
      lhs.strings == rhs.strings && lhs.int == rhs.int
    }
  }
}

class UnkeyedParent: Codable {
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

  final class DefaultKeyedChild: UnkeyedParent, Equatable {
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

  final class CustomKeyedChild: UnkeyedParent, Equatable {
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

  final class ValueUnkeyedChild: UnkeyedParent, Equatable {
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

  final class ArrayUnkeyedChild: UnkeyedParent, Equatable {
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

class ValueParent: Codable {
  var int: Int?

  init(int: Int?) {
    self.int = int
  }

  required init(from decoder: Decoder) throws {
    self.int = try decoder.singleValueContainer().decode(Int?.self)
  }

  func encode(to encoder: Encoder) throws {
    try int.encode(to: encoder)
  }

  final class DefaultKeyedChild: ValueParent, Equatable {
    var string: String

    override init(int: Int?) {
      self.string = "DefaultKeyedChild"
      super.init(int: int)
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
      lhs.string == rhs.string && lhs.int == rhs.int
    }

    enum Keys: String, CodingKey {
      case string
    }
  }

  final class CustomKeyedChild: ValueParent, Equatable {
    var string: String

    override init(int: Int?) {
      self.string = "CustomKeyedChild"
      super.init(int: int)
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
      lhs.string == rhs.string && lhs.int == rhs.int
    }

    enum Keys: String, CodingKey {
      case string
      case parent
    }
  }

  final class ValueUnkeyedChild: ValueParent, Equatable {
    var string: String

    override init(int: Int?) {
      self.string = "UnkeyedChild"
      super.init(int: int)
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
      lhs.string == rhs.string && lhs.int == rhs.int
    }
  }

  final class ArrayUnkeyedChild: ValueParent, Equatable {
    var strings: [String]

    override init(int: Int?) {
      self.strings = ["one", "two"]
      super.init(int: int)
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
      lhs.strings == rhs.strings && lhs.int == rhs.int
    }
  }
}
