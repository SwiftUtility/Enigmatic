import Foundation

protocol EnigmaConvertible {
  func convert(pins: inout [Enigma.Pin]) throws(DecodingError) -> Enigma?
}

extension Enigma: EnigmaConvertible {
  func convert(pins _: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    self
  }

  static func make(pins: inout [Pin], value: Any) throws(DecodingError) -> Self {
    if type(of: value) is AnyClass {
      if let value = try (value as? any EnigmaConvertibleObject)?.convert(pins: &pins) {
        return value
      }
    } else {
      if let value = try (value as? any EnigmaConvertible)?.convert(pins: &pins) {
        return value
      }
    }
    throw DecodingError.dataCorrupted(DecodingError.Context(
      codingPath: pins,
      debugDescription: "Not supported value type: \(type(of: value))"
    ))
  }
}

extension Bool: EnigmaConvertible {
  func convert(pins _: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    .bool(self)
  }
}

extension Int: EnigmaConvertible {
  func convert(pins _: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    .int(self)
  }
}

extension Int8: EnigmaConvertible {
  func convert(pins _: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    .int8(self)
  }
}

extension Int16: EnigmaConvertible {
  func convert(pins _: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    .int16(self)
  }
}

extension Int32: EnigmaConvertible {
  func convert(pins _: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    .int32(self)
  }
}

extension Int64: EnigmaConvertible {
  func convert(pins _: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    .int64(self)
  }
}

@available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
extension Int128: EnigmaConvertible {
  func convert(pins _: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    .int128(Enigma.Int128Value(self))
  }
}

extension UInt: EnigmaConvertible {
  func convert(pins _: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    .uint(self)
  }
}

extension UInt8: EnigmaConvertible {
  func convert(pins _: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    .uint8(self)
  }
}

extension UInt16: EnigmaConvertible {
  func convert(pins _: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    .uint16(self)
  }
}

extension UInt32: EnigmaConvertible {
  func convert(pins _: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    .uint32(self)
  }
}

extension UInt64: EnigmaConvertible {
  func convert(pins _: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    .uint64(self)
  }
}

@available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
extension UInt128: EnigmaConvertible {
  func convert(pins _: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    .uint128(Enigma.UInt128Value(self))
  }
}

extension Float: EnigmaConvertible {
  func convert(pins _: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    .float(self)
  }
}

extension Double: EnigmaConvertible {
  func convert(pins _: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    .double(self)
  }
}

extension String: EnigmaConvertible {
  func convert(pins _: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    .string(self)
  }
}

extension Data: EnigmaConvertible {
  func convert(pins _: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    .data(self)
  }
}

extension Date: EnigmaConvertible {
  func convert(pins _: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    .date(self)
  }
}

extension AnyHashable: EnigmaConvertible {
  func convert(pins: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    try (base as? EnigmaConvertible)?.convert(pins: &pins)
  }
}

extension Array: EnigmaConvertible {
  func convert(pins: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    var result: [Enigma] = []
    result.reserveCapacity(count)
    for item in enumerated() {
      pins.append(Enigma.Pin.int(item.offset))
      defer { pins.removeLast() }
      try result.append(Enigma.make(pins: &pins, value: item.element))
    }
    return .array(result)
  }
}

extension Set: EnigmaConvertible {
  func convert(pins: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    var result: [Enigma] = []
    result.reserveCapacity(count)
    for item in enumerated() {
      pins.append(Enigma.Pin.int(item.offset))
      defer { pins.removeLast() }
      try result.append(Enigma.make(pins: &pins, value: item.element))
    }
    return .array(result)
  }
}

extension Dictionary: EnigmaConvertible {
  func convert(pins: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    if Key.self == String.self, let values = self as? [String: Value] {
      var result: [String: Enigma] = [:]
      result.reserveCapacity(count)
      for (key, value) in values {
        let enigma: Enigma
        do {
          pins.append(Enigma.Pin.str(key))
          defer { pins.removeLast() }
          enigma = try Enigma.make(pins: &pins, value: value)
        }
        guard result.updateValue(enigma, forKey: key) == nil else {
          throw DecodingError.dataCorrupted(DecodingError.Context(
            codingPath: pins,
            debugDescription: "Collision for key \(key)"
          ))
        }
      }
      return .dictionary(result)
    } else if Key.self == Int.self, let values = self as? [Int: Value] {
      var result: [String: Enigma] = [:]
      result.reserveCapacity(count)
      for (key, value) in values {
        let key = String(key)
        let enigma: Enigma
        do {
          pins.append(Enigma.Pin.str(key))
          defer { pins.removeLast() }
          enigma = try Enigma.make(pins: &pins, value: value)
        }
        guard result.updateValue(enigma, forKey: key) == nil else {
          throw DecodingError.dataCorrupted(DecodingError.Context(
            codingPath: pins,
            debugDescription: "Collision for key \(key)"
          ))
        }
      }
      return .dictionary(result)
    } else if Key.self == AnyHashable.self {
      var result: [String: Enigma] = [:]
      result.reserveCapacity(count)
      for (key, value) in self as [AnyHashable: Value] {
        guard let key = (key.base as? any StringKeyConvertible)?.asStringKey else {
          throw DecodingError.dataCorrupted(DecodingError.Context(
            codingPath: pins,
            debugDescription: "Not supported AnyHashable base value type: \(type(of: key.base))"
          ))
        }
        let enigma: Enigma
        do {
          pins.append(Enigma.Pin.str(key))
          defer { pins.removeLast() }
          enigma = try Enigma.make(pins: &pins, value: value)
        }
        guard result.updateValue(enigma, forKey: key) == nil else {
          throw DecodingError.dataCorrupted(DecodingError.Context(
            codingPath: pins,
            debugDescription: "Collision for key \(key)"
          ))
        }
      }
      return .dictionary(result)
    } else if
      #available(macOS 12.3, iOS 15.4, watchOS 8.5, tvOS 15.4, *),
      let values = self as? KeyedByCodingKeyRepresentable
    {
      return try values.convert(keyed: &pins)
    }
    throw DecodingError.dataCorrupted(DecodingError.Context(
      codingPath: pins,
      debugDescription: "Not supported dictionary key type \(Key.self)"
    ))
  }
}
