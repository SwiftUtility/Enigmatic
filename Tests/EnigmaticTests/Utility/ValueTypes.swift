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
  var regular = Regular()
  var infinits = InfinitFloats()
  var dataValues = DataValues()
  var dateValues = DateValues()
}

struct Regular: Codable, Equatable {
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
  var pbigDouble = 1.111111111111111e307 as Double
  var plitDouble = 1.111111111111111e-307 as Double
  var pbigFloat = 1.1111111e38 as Float
  var plitFloat = 1e-38 as Float
  var nbigDouble = -1.111111111111111e307 as Double
  var nlitDouble = -1.111111111111111e-307 as Double
  var nbigFloat = -1.1111111e38 as Float
  var nlitFloat = -1e-38 as Float
  var pSemiFloatDouble = 1.1111111e38 as Double
  var halfDouble = 0.5 as Float
  var halfFloat = 0.5 as Float
}

struct InfinitFloats: Codable, Equatable {
  var pinfFloat = Float.infinity
  var ninfFloat = -Float.infinity
  var pinfDouble = Double.infinity
  var ninfDouble = -Double.infinity
}

struct Custom: Codable, Equatable {
  var url = URL(string: "net://net:net@net.net/net?net=net&net=net#net")!
  var bool = true
  var string = ""
}

struct OptCustom: Codable, Equatable {
  var url: URL? = URL(string: "net://net:net@net.net/net?net=net&net=net#net")
  var bool: Bool? = false
  var string: String? = "Hello\nString"
}

struct NilCustom: Codable, Equatable {
  var url: URL? = nil
  var bool: Bool? = nil
  var string: String? = nil
}

struct DateValues: Codable, Equatable {
  var date = Date(timeIntervalSinceReferenceDate: 1)
  var optDate: Date? = Date(timeIntervalSince1970: 1)
  var nilDate: Date? = nil
}

struct DataValues: Codable, Equatable {
  var data = Data("Hello Data".utf8)
  var optData: Data? = Data("Hello Data".utf8)
  var nilData: Data? = nil
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
