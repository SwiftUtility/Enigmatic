import Foundation
import CoreFoundation

extension Enigma {
  func collectPins(
    into pins: inout [[Pin]],
    current: inout [Pin]
  ) {
    if !current.isEmpty { pins.append(current) }
    switch self {
    case .array(let value):
      for (index, element) in value.enumerated() {
        current.append(.int(index))
        defer { current.removeLast() }
        element.collectPins(into: &pins, current: &current)
      }
    case .dictionary(let value):
      for key in value.keys.sorted() {
        guard let element = value[key] else { continue }
        current.append(.str(key))
        defer { current.removeLast() }
        element.collectPins(into: &pins, current: &current)
      }
    case .null, .bool, .data, .date, .string, .double,
        .int, .int8, .int16, .int32, .int64, .int128,
        .uint, .uint8, .uint16, .uint32, .uint64, .uint128:
      break
    }
  }

  func getValue(
    pins: [Pin]
  ) -> Self? {
    var result = self
    for pin in pins {
      switch pin {
      case .int(let int):
        guard let array = result.asArray, array.indices.contains(int) else { return nil }
        result = array[int]
      case .str(let str):
        guard let dictionary = result.asDictionary, let value = dictionary[str] else { return nil }
        result = value
      }
    }
    return result
  }

  mutating func delValue(pins: inout ArraySlice<Pin>) {
    guard let pin = pins.first else { return }
    pins = pins.dropFirst()
    switch pin {
    case .int(let int):
      guard case .array(var array) = self, array.indices.contains(int) else { return }
      self = .null
      defer { self = .array(array) }
      if pins.isEmpty {
        array.remove(at: int)
      } else {
        array[int].delValue(pins: &pins)
      }
    case .str(let key):
      guard case .dictionary(var dictionary) = self else { return }
      self = .null
      defer { self = .dictionary(dictionary) }
      if pins.isEmpty {
        dictionary.removeValue(forKey: key)
      } else {
        dictionary[key]?.delValue(pins: &pins)
      }
    }
  }

  @usableFromInline
  func makePlistObject(pins: inout [Pin]) throws(EncodingError) -> NSObject {
    switch self {
    case .null:
      throw EncodingError.invalidValue(NSNull(), EncodingError.Context(
        codingPath: pins,
        debugDescription: "Can not convert null to PropertyListSerialization compatible NSObject"
      ))
    case .bool(let value):
      return value as NSNumber
    case .int(let value):
      return value as NSNumber
    case .int64(let value):
      return value as NSNumber
    case .int32(let value):
      return value as NSNumber
    case .int16(let value):
      return value as NSNumber
    case .int8(let value):
      return value as NSNumber
    case .uint(let value):
      return value as NSNumber
    case .uint64(let value):
      return value as NSNumber
    case .uint32(let value):
      return value as NSNumber
    case .uint16(let value):
      return value as NSNumber
    case .uint8(let value):
      return value as NSNumber
    case .double(let value):
      return value as NSNumber
    case .string(let value):
      return value as NSString
    case .array(let value):
      var array: [NSObject] = []
      array.reserveCapacity(value.count)
      for (index, value) in value.enumerated() {
        pins.append(.int(index))
        defer { pins.removeLast() }
        try array.append(value.makePlistObject(pins: &pins))
      }
      return NSArray(array: array)
    case .dictionary(let value):
      var dictionary: [AnyHashable: Any] = [:]
      dictionary.reserveCapacity(value.count)
      for (key, value) in value {
        pins.append(.str(key))
        defer { pins.removeLast() }
        try dictionary[key] = value.makePlistObject(pins: &pins)
      }
      return NSDictionary(dictionary: dictionary)
    case .data(let value):
      return value as NSData
    case .date(let value):
      return value as NSDate
    case .int128:
      throw EncodingError.invalidValue(Int128Box.self, EncodingError.Context(
        codingPath: pins,
        debugDescription: "Can not convert Int128 to NSObject"
      ))
    case .uint128:
      throw EncodingError.invalidValue(UInt128Box.self, EncodingError.Context(
        codingPath: pins,
        debugDescription: "Can not convert UInt128 to NSObject"
      ))
    }
  }

  @usableFromInline
  func makeJsonObject(pins: inout [Pin]) throws(EncodingError) -> NSObject {
    switch self {
    case .null: return NSNull()
    case .bool(let value): return value as NSNumber
    case .int(let value): return value as NSNumber
    case .int64(let value): return value as NSNumber
    case .int32(let value): return value as NSNumber
    case .int16(let value): return value as NSNumber
    case .int8(let value): return value as NSNumber
    case .uint(let value): return value as NSNumber
    case .uint64(let value): return value as NSNumber
    case .uint32(let value): return value as NSNumber
    case .uint16(let value): return value as NSNumber
    case .uint8(let value): return value as NSNumber
    case .double(let value):
      guard !value.isFinite else { return value as NSNumber }
      throw EncodingError.invalidValue(Double.self, EncodingError.Context(
        codingPath: pins,
        debugDescription: "Can not convert \(value) to JSONSerialization compatible NSObject"
      ))
    case .string(let value): return value as NSString
    case .array(let value):
      var array: [NSObject] = []
      array.reserveCapacity(value.count)
      for (index, value) in value.enumerated() {
        pins.append(.int(index))
        defer { pins.removeLast() }
        try array.append(value.makeJsonObject(pins: &pins))
      }
      return NSArray(array: array)
    case .dictionary(let value):
      var dictionary: [AnyHashable: Any] = [:]
      dictionary.reserveCapacity(value.count)
      for (key, value) in value {
        pins.append(.str(key))
        defer { pins.removeLast() }
        try dictionary[AnyHashable(key)] = value.makeJsonObject(pins: &pins)
      }
      return NSDictionary(dictionary: dictionary)
    case .data(let value):
      throw EncodingError.invalidValue(value, EncodingError.Context(
        codingPath: pins,
        debugDescription: "Can not convert Data to JSONSerialization compatible NSObject"
      ))
    case .date(let value):
      throw EncodingError.invalidValue(value, EncodingError.Context(
        codingPath: pins,
        debugDescription: "Can not convert Date to JSONSerialization compatible NSObject"
      ))
    case .int128:
      throw EncodingError.invalidValue(Int128Box.self, EncodingError.Context(
        codingPath: pins,
        debugDescription: "Can not convert Int128 to NSObject"
      ))
    case .uint128:
      throw EncodingError.invalidValue(UInt128Box.self, EncodingError.Context(
        codingPath: pins,
        debugDescription: "Can not convert UInt128 to NSObject"
      ))
    }
  }

  static func setValue(
    _ value: Self,
    pins: inout ArraySlice<Pin>,
    original: inout Self
  ) -> Bool {
    guard let pin = pins.first else {
      original = value
      return true
    }
    pins = pins.dropFirst()
    switch pin {
    case .int(let index):
      var backup: Self?
      var result: [Self]
      if case .array(let array) = original {
        backup = nil
        result = array
      } else {
        backup = original
        result = []
      }
      _ = consume original
      if result.indices.contains(index) {
        if Self.setValue(value, pins: &pins, original: &result[index]) {
          original = .array(result)
          return true
        } else {
          original = backup ?? .array(result)
          return false
        }
      } else if index == result.count {
        var enigma = switch pins.first {
        case .int?: Enigma.array([])
        case .str?: Enigma.dictionary([:])
        case .none: Enigma.null
        }
        if Self.setValue(value, pins: &pins, original: &enigma) {
          result.append(enigma)
          original = .array(result)
          return true
        } else {
          original = backup ?? .array(result)
          return false
        }
      } else {
        original = backup ?? .array(result)
        return false
      }
    case .str(let key):
      var backup: Self?
      var result: [String: Self] = [:]
      if case .dictionary(let dictionary) = original {
        result = dictionary
      } else {
        backup = original
      }
      _ = consume original
      if var item = result.removeValue(forKey: key) {
        if Self.setValue(value, pins: &pins, original: &item) {
          result[key] = item
          original = .dictionary(result)
          return true
        } else {
          result[key] = item
          original = backup ?? .dictionary(result)
          return false
        }
      } else {
        var enigma = switch pins.first {
        case .int?: Enigma.array([])
        case .str?: Enigma.dictionary([:])
        case .none: Enigma.null
        }
        if Self.setValue(value, pins: &pins, original: &enigma) {
          result[key] = enigma
          original = .dictionary(result)
          return true
        } else {
          original = backup ?? .dictionary(result)
          return false
        }
      }
    }
  }
}
