import Foundation

extension EnigmaEncoder {
  struct Unkeyed: UnkeyedEncodingContainer {
    let state: EnigmaEncoder
    let ref: Ref

    var codingPath: [CodingKey] {
      state.codingPath(ref: ref)
    }

    var count: Int {
      state.count(ref: ref)
    }

    mutating func encodeNil() throws {
      try state.store(.null, ref: state.nestedRef(ref: ref, key: nil))
    }

    mutating func encode(_ value: Bool) throws {
      try state.store(.bool(value), ref: state.nestedRef(ref: ref, key: nil))
    }

    mutating func encode(_ value: String) throws {
      try state.store(.string(value), ref: state.nestedRef(ref: ref, key: nil))
    }

    mutating func encode(_ value: Double) throws {
      try state.store(.double(value), ref: state.nestedRef(ref: ref, key: nil))
    }

    mutating func encode(_ value: Float) throws {
      try state.store(.double(Double(value)), ref: state.nestedRef(ref: ref, key: nil))
    }

    mutating func encode(_ value: Int) throws {
      try state.store(.int(value), ref: state.nestedRef(ref: ref, key: nil))
    }

    mutating func encode(_ value: Int8) throws {
      try state.store(.int8(value), ref: state.nestedRef(ref: ref, key: nil))
    }

    mutating func encode(_ value: Int16) throws {
      try state.store(.int16(value), ref: state.nestedRef(ref: ref, key: nil))
    }

    mutating func encode(_ value: Int32) throws {
      try state.store(.int32(value), ref: state.nestedRef(ref: ref, key: nil))
    }

    mutating func encode(_ value: Int64) throws {
      try state.store(.int64(value), ref: state.nestedRef(ref: ref, key: nil))
    }

    mutating func encode(_ value: UInt) throws {
      try state.store(.uint(value), ref: state.nestedRef(ref: ref, key: nil))
    }

    mutating func encode(_ value: UInt8) throws {
      try state.store(.uint8(value), ref: state.nestedRef(ref: ref, key: nil))
    }

    mutating func encode(_ value: UInt16) throws {
      try state.store(.uint16(value), ref: state.nestedRef(ref: ref, key: nil))
    }

    mutating func encode(_ value: UInt32) throws {
      try state.store(.uint32(value), ref: state.nestedRef(ref: ref, key: nil))
    }

    mutating func encode(_ value: UInt64) throws {
      try state.store(.uint64(value), ref: state.nestedRef(ref: ref, key: nil))
    }

    @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
    mutating func encode(_ value: Int128) throws {
      try state.store(.int128(Enigma.Int128Box(value)), ref: state.nestedRef(ref: ref, key: nil))
    }

    @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
    mutating func encode(_ value: UInt128) throws {
      try state.store(.uint128(Enigma.UInt128Box(value)), ref: state.nestedRef(ref: ref, key: nil))
    }

    mutating func encode<T: Encodable>(_ value: T) throws {
      let ref = state.nestedRef(ref: ref, key: nil)
      guard try !state.encodeSpecial(value, ref: ref) else { return }
      try value.encode(to: Single(state: state, ref: ref))
    }

    mutating func nestedContainer<Key: CodingKey>(
      keyedBy _: Key.Type
    ) -> KeyedEncodingContainer<Key> {
      KeyedEncodingContainer(state.asKeyed(ref: state.nestedRef(ref: ref, key: nil)))
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
      state.asUnkeyed(ref: state.nestedRef(ref: ref, key: nil))
    }

    mutating func superEncoder() -> Encoder {
      Single(state: state, ref: state.nestedRef(ref: ref, key: nil))
    }
  }
}
