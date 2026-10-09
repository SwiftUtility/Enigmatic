import Foundation

protocol EnigmaConvertibleObject: EnigmaConvertible, AnyObject {}

extension EnigmaConvertibleObject {
  func convert(pins: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    nil
  }
}

extension NSNull: EnigmaConvertibleObject {
  func convert(pins _: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    .null
  }
}

extension NSString: EnigmaConvertibleObject {
  func convert(pins _: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    .string(self as String)
  }
}

extension NSValue: EnigmaConvertibleObject {
  func convert(pins: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    if let number = self as? NSNumber {
      if let enigma = number.asEnigma { return enigma }
    } else if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
      switch objCType.pointee {
      case ObjCType.signedBitInt128: return .int128(Enigma.Int128Box(extract(seed: 0)))
      case ObjCType.unsignedBitInt128: return .uint128(Enigma.UInt128Box(extract(seed: 0)))
      default: break
      }
    }
    throw DecodingError.dataCorrupted(DecodingError.Context(
      codingPath: pins,
      debugDescription: "\(Self.self) value not recognized objCType: \(String(cString: objCType))"
    ))
  }
}

extension NSNumber {
  var asEnigma: Enigma? {
    guard CFGetTypeID(self) != CFBooleanGetTypeID() else { return .bool(boolValue) }
    return switch objCType.pointee {
    case ObjCType.signedLong: .int(intValue)
    case ObjCType.unsignedLong: .uint(uintValue)
    case ObjCType.float, ObjCType.double: .double(doubleValue)
    case ObjCType.bool: .bool(boolValue)
    case ObjCType.signedChar: .int8(int8Value)
    case ObjCType.unsignedChar: .uint8(uint8Value)
    case ObjCType.signedShort: .int16(int16Value)
    case ObjCType.unsignedShort: .uint16(uint16Value)
    case ObjCType.signedInt: .int32(int32Value)
    case ObjCType.unsignedInt: .uint32(uint32Value)
    case ObjCType.signedLongLong: .int64(int64Value)
    case ObjCType.unsignedLongLong: .uint64(uint64Value)
    default: nil
    }
  }
}

extension NSData: EnigmaConvertibleObject {
  func convert(pins _: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    .data(self as Data)
  }
}

extension NSDate: EnigmaConvertibleObject {
  func convert(pins _: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    .date(self as Date)
  }
}

extension NSArray: EnigmaConvertibleObject {
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

extension NSSet: EnigmaConvertibleObject {
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

extension NSDictionary: EnigmaConvertibleObject {
  func convert(pins: inout [Enigma.Pin]) throws(DecodingError) -> Enigma? {
    var result: [String: Enigma] = [:]
    result.reserveCapacity(count)
    for (key, value) in self {
      guard let key = key as? String else {
        throw DecodingError.dataCorrupted(DecodingError.Context(
          codingPath: pins,
          debugDescription: "Not supperted dictionary key type: \(type(of: key))"
        ))
      }
      pins.append(Enigma.Pin.str(key))
      defer { pins.removeLast() }
      guard try result.updateValue(Enigma.make(pins: &pins, value: value), forKey: key) == nil else {
        throw DecodingError.dataCorrupted(DecodingError.Context(
          codingPath: pins,
          debugDescription: "Collision for key \(key)"
        ))
      }
    }
    return .dictionary(result)
  }
}
