import Foundation

extension OtherEnigmaEncoder {
  struct Single: Encoder, SingleValueEncodingContainer {
    let state: State
    let ref: Ref

    var codingPath: [any CodingKey] {
      state.codingPath(ref: ref)
    }

    var userInfo: [CodingUserInfoKey: Any] {
      state.userInfo
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
      self
    }

    func container<Key: CodingKey>(keyedBy _: Key.Type) -> KeyedEncodingContainer<Key> {
      KeyedEncodingContainer(state.asKeyed(ref: ref))
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
      state.asUnkeyed(ref: ref)
    }

    mutating func encodeNil() throws {
      try state.store(.null, ref: ref)
    }

    mutating func encode(_ value: Bool) throws {
      try state.store(.bool(value), ref: ref)
    }

    mutating func encode(_ value: String) throws {
      try state.store(.string(value), ref: ref)
    }

    mutating func encode(_ value: Double) throws {
      try state.store(.double(value), ref: ref)
    }

    mutating func encode(_ value: Float) throws {
      try state.store(.float(value), ref: ref)
    }

    mutating func encode(_ value: Int) throws {
      try state.store(.int(value), ref: ref)
    }

    mutating func encode(_ value: Int8) throws {
      try state.store(.int8(value), ref: ref)
    }

    mutating func encode(_ value: Int16) throws {
      try state.store(.int16(value), ref: ref)
    }

    mutating func encode(_ value: Int32) throws {
      try state.store(.int32(value), ref: ref)
    }

    mutating func encode(_ value: Int64) throws {
      try state.store(.int64(value), ref: ref)
    }

    mutating func encode(_ value: UInt) throws {
      try state.store(.uint(value), ref: ref)
    }

    mutating func encode(_ value: UInt8) throws {
      try state.store(.uint8(value), ref: ref)
    }

    mutating func encode(_ value: UInt16) throws {
      try state.store(.uint16(value), ref: ref)
    }

    mutating func encode(_ value: UInt32) throws {
      try state.store(.uint32(value), ref: ref)
    }

    mutating func encode(_ value: UInt64) throws {
      try state.store(.uint64(value), ref: ref)
    }

    mutating func encode<T: Encodable>(_ value: T) throws {
      guard try !state.encodeSpecial(value, ref: ref) else { return }
      try value.encode(to: self)
    }
  }
}
