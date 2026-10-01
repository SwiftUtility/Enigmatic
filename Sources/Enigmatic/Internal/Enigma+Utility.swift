import Foundation
import CoreFoundation

extension Enigma {
  func collectPins(
    into pins: inout [[Pin]],
    current: inout [Pin]
  ) {
    if !pins.isEmpty { pins.append(current) }
    switch self {
    case .array(let value):
      for (index, element) in value.enumerated() {
        current.append(.int(index))
        defer { current.removeLast() }
        element.collectPins(into: &pins, current: &current)
      }
    case .dictionary(let value):
      for (key, element) in value {
        current.append(.str(key))
        defer { current.removeLast() }
        element.collectPins(into: &pins, current: &current)
      }
    case .null, .bool, .data, .date, .string, .double, .float,
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

  mutating func setValue(
    _ value: Self,
    pins: inout ArraySlice<Pin>,
  ) {
    guard let pin = pins.first else { return self = value }
    pins = pins.dropFirst()
    lazy var enigma = switch pins.first {
    case .int?: Enigma.array([])
    case .str?: Enigma.dictionary([:])
    case .none: Enigma.null
    }
    switch pin {
    case .int(let index):
      guard case .array(var array) = self else { return }
      self = .null
      defer { self = .array(array) }
      guard !array.indices.contains(index) else { return array[index].setValue(value, pins: &pins) }
      guard index == array.count else { return }
      enigma.setValue(value, pins: &pins)
      array.append(enigma)
    case .str(let key):
      guard case .dictionary(var dictionary) = self else { return }
      self = .null
      defer { self = .dictionary(dictionary) }
      dictionary[key, default: enigma].setValue(value, pins: &pins)
    }
  }

  func merge<E: Error>(
    _ other: Self,
    pins: inout [Pin],
    resolve: ([Pin], Self, Self) throws(E) -> Self
  ) throws(E) -> Self {
    guard case (.dictionary(var this), .dictionary(let other)) = (self, other) else {
      return try resolve(pins, self, other)
    }
    for (key, value) in other {
      pins.append(.str(key))
      defer { pins.removeLast() }
      this[key] = try this[key]?.merge(value, pins: &pins, resolve: resolve) ?? value
    }
    return .dictionary(this)
  }

  static func make(anyObject reducer: inout Reducer<[Pin], Any?>) throws(DecodingError) -> Self {
    if reducer.value == nil || reducer.value is NSNull {
      return .null
    } else if let value = reducer.value as? String {
      return .string(value)
    } else if let value = reducer.value as? NSNumber {
      if CFGetTypeID(value) == CFBooleanGetTypeID() {
        return .bool(value.boolValue)
      } else {
        switch value.objCType.pointee {
        case ObjCType.signedLong: return .int(value.intValue)
        case ObjCType.unsignedLong: return .uint(value.uintValue)
        case ObjCType.double: return .double(value.doubleValue)
        case ObjCType.float: return .float(value.floatValue)
        case ObjCType.bool: return .bool(value.boolValue)
        case ObjCType.signedChar: return .int8(value.int8Value)
        case ObjCType.unsignedChar: return .uint8(value.uint8Value)
        case ObjCType.signedShort: return .int16(value.int16Value)
        case ObjCType.unsignedShort: return .uint16(value.uint16Value)
        case ObjCType.signedInt: return .int32(value.int32Value)
        case ObjCType.unsignedInt: return .uint32(value.uint32Value)
        case ObjCType.signedLongLong: return .int64(value.int64Value)
        case ObjCType.unsignedLongLong: return .uint64(value.uint64Value)
        default:
          throw DecodingError.dataCorrupted(DecodingError.Context(
            codingPath: reducer.store,
            debugDescription: "NSNumber type not determined objCType=\(value.objCType.pointee)"
          ))
        }
      }
    } else if let value = reducer.value as? NSValue {
#if os(anyAppleOS) || os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        switch value.objCType.pointee {
        case ObjCType.int128:
          var result = Int128Value(0)
          withUnsafeMutablePointer(to: &result) { pointer in
            value.getValue(pointer, size: MemoryLayout<Int128Value>.size)
          }
          return .int128(result)
        case ObjCType.uint128:
          var result = UInt128Value(0)
          withUnsafeMutablePointer(to: &result) { pointer in
            value.getValue(pointer, size: MemoryLayout<UInt128Value>.size)
          }
          return .uint128(result)
        default: break
        }
      }
#else
      switch value.objCType.pointee {
      case ObjCType.int128:
        var result = Int128(0)
        withUnsafeMutablePointer(to: &result) { pointer in
          value.getValue(pointer, size: MemoryLayout<Int128>.size)
        }
        return .int128(result)
      case ObjCType.uint128:
        var result = UInt128(0)
        withUnsafeMutablePointer(to: &result) { pointer in
          value.getValue(pointer, size: MemoryLayout<UInt128>.size)
        }
        return .uint128(result)
      default: break
      }
#endif
      throw DecodingError.dataCorrupted(DecodingError.Context(
        codingPath: reducer.store,
        debugDescription: "NSValue type not determined objCType=\(value.objCType.pointee)"
      ))
    } else if let value = reducer.value as? [AnyHashable: Any?] {
      var dictionary: [String: Enigma] = [:]
      dictionary.reserveCapacity(value.count)
      for (key, value) in value {
        let key = key.description
        guard !dictionary.keys.contains(key) else {
          throw DecodingError.dataCorrupted(DecodingError.Context(
            codingPath: reducer.store,
            debugDescription: "Collision during dictionary conversion for key \(key)"
          ))
        }
        reducer.store.append(.str(key))
        defer { reducer.store.removeLast() }
        try dictionary[key] = reducer.reduce(next: value, make(anyObject:))
      }
      return .dictionary(dictionary)
    } else if let value = reducer.value as? [Any?] {
      var array: [Self] = []
      array.reserveCapacity(value.count)
      for (index, value) in value.enumerated() {
        reducer.store.append(.int(index))
        defer { reducer.store.removeLast() }
        try array.append(reducer.reduce(next: value, make(anyObject:)))
      }
      return .array(array)
    } else if let value = reducer.value as? Data {
      return .data(value)
    } else if let value = reducer.value as? Date {
      return .date(value)
    } else {
      throw DecodingError.dataCorrupted(DecodingError.Context(
        codingPath: reducer.store,
        debugDescription: "Neither value nor array nor dictionary"
      ))
    }
  }

  static func makePlistObject(reducer: inout Reducer<[Pin], Self>) throws(EncodingError) -> NSObject {
    switch reducer.value {
    case .null:
      throw EncodingError.invalidValue(NSNull(), EncodingError.Context(
        codingPath: reducer.store,
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
    case .float(let value):
      return value as NSNumber
    case .string(let value):
      return value as NSString
    case .array(let value):
      var array: [NSObject] = []
      array.reserveCapacity(value.count)
      for (index, value) in value.enumerated() {
        reducer.store.append(.int(index))
        defer { reducer.store.removeLast() }
        try array.append(reducer.reduce(next: value, Self.makePlistObject(reducer:)))
      }
      return NSArray(array: array)
    case .dictionary(let value):
      var dictionary: [AnyHashable: NSObject] = [:]
      dictionary.reserveCapacity(value.count)
      for (key, value) in value {
        reducer.store.append(.str(key))
        defer { reducer.store.removeLast() }
        try dictionary[key] = reducer.reduce(next: value, Self.makePlistObject(reducer:))
      }
      return NSDictionary(dictionary: dictionary)
    case .data(let value):
      return value as NSData
    case .date(let value):
      return value as NSDate
    case .int128:
      throw EncodingError.invalidValue(NSNull(), EncodingError.Context(
        codingPath: reducer.store,
        debugDescription: "Can not convert Int128 to NSObject"
      ))
    case .uint128:
      throw EncodingError.invalidValue(NSNull(), EncodingError.Context(
        codingPath: reducer.store,
        debugDescription: "Can not convert UInt128 to NSObject"
      ))
    }
  }

  static func makeJsonObject(reducer: inout Reducer<[Pin], Self>) throws(EncodingError) -> NSObject {
    switch reducer.value {
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
      return try chechJson(value: value, object: value as NSNumber, pins: reducer.store)
    case .float(let value):
      return try chechJson(value: value, object: value as NSNumber, pins: reducer.store)
    case .string(let value): return value as NSString
    case .array(let value):
      var array: [NSObject] = []
      array.reserveCapacity(value.count)
      for (index, value) in value.enumerated() {
        reducer.store.append(.int(index))
        defer { reducer.store.removeLast() }
        try array.append(reducer.reduce(next: value, Self.makeJsonObject(reducer:)))
      }
      return NSArray(array: array)
    case .dictionary(let value):
      var dictionary: [AnyHashable: NSObject] = [:]
      dictionary.reserveCapacity(value.count)
      for (key, value) in value {
        reducer.store.append(.str(key))
        defer { reducer.store.removeLast() }
        try dictionary[key] = reducer.reduce(next: value, Self.makeJsonObject(reducer:))
      }
      return NSDictionary(dictionary: dictionary)
    case .data(let value):
      throw EncodingError.invalidValue(value, EncodingError.Context(
        codingPath: reducer.store,
        debugDescription: "Can not convert Data to JSONSerialization compatible NSObject"
      ))
    case .date(let value):
      throw EncodingError.invalidValue(value, EncodingError.Context(
        codingPath: reducer.store,
        debugDescription: "Can not convert Date to JSONSerialization compatible NSObject"
      ))
    case .int128:
      throw EncodingError.invalidValue(NSNull(), EncodingError.Context(
        codingPath: reducer.store,
        debugDescription: "Can not convert Int128 to NSObject"
      ))
    case .uint128:
      throw EncodingError.invalidValue(NSNull(), EncodingError.Context(
        codingPath: reducer.store,
        debugDescription: "Can not convert UInt128 to NSObject"
      ))
    }
  }

  static func chechJson(
    value: some BinaryFloatingPoint,
    object: NSObject,
    pins: borrowing [Pin]
  ) throws(EncodingError) -> NSObject {
    guard !value.isFinite else { return object }
    throw EncodingError.invalidValue(value, EncodingError.Context(
      codingPath: pins,
      debugDescription: "Can not convert infinite or nan to JSONSerialization compatible NSObject"
    ))
  }
}

enum ObjCType {
  static let signedChar = CChar(UnicodeScalar("c").value)
  static let signedShort = CChar(UnicodeScalar("s").value)
  static let signedInt = CChar(UnicodeScalar("i").value)
  static let signedLong = CChar(UnicodeScalar("l").value)
  static let signedLongLong = CChar(UnicodeScalar("q").value)
  static let unsignedChar = CChar(UnicodeScalar("C").value)
  static let unsignedShort = CChar(UnicodeScalar("S").value)
  static let unsignedInt = CChar(UnicodeScalar("I").value)
  static let unsignedLong = CChar(UnicodeScalar("L").value)
  static let unsignedLongLong = CChar(UnicodeScalar("Q").value)
  static let float = CChar(UnicodeScalar("f").value)
  static let double = CChar(UnicodeScalar("d").value)
  static let bool = CChar(UnicodeScalar("B").value)
  static let int128 = CChar(UnicodeScalar("j").value)
  static let uint128 = CChar(UnicodeScalar("J").value)
}
