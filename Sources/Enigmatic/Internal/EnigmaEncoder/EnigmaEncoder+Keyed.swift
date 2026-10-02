import Foundation

extension EnigmaEncoder {
  struct Keyed<Key: CodingKey>: KeyedEncodingContainerProtocol {
    let state: EnigmaEncoder
    let ref: Ref

    var codingPath: [CodingKey] {
      state.codingPath(ref: ref)
    }

    mutating func encodeNil(forKey key: Key) throws {
      try state.store(.null, ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: Bool, forKey key: Key) throws {
      try state.store(.bool(value), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: String, forKey key: Key) throws {
      try state.store(.string(value), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: Double, forKey key: Key) throws {
      try state.store(.double(value), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: Float, forKey key: Key) throws {
      try state.store(.float(value), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: Int, forKey key: Key) throws {
      try state.store(.int(value), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: Int8, forKey key: Key) throws {
      try state.store(.int8(value), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: Int16, forKey key: Key) throws {
      try state.store(.int16(value), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: Int32, forKey key: Key) throws {
      try state.store(.int32(value), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: Int64, forKey key: Key) throws {
      try state.store(.int64(value), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: UInt, forKey key: Key) throws {
      try state.store(.uint(value), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: UInt8, forKey key: Key) throws {
      try state.store(.uint8(value), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: UInt16, forKey key: Key) throws {
      try state.store(.uint16(value), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: UInt32, forKey key: Key) throws {
      try state.store(.uint32(value), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode(_ value: UInt64, forKey key: Key) throws {
      try state.store(.uint64(value), ref: state.nestedRef(ref: ref, key: key))
    }

    @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
    mutating func encode(_ value: Int128, forKey key: Key) throws {
      try state.store(.int128(Enigma.Int128Value(value)), ref: state.nestedRef(ref: ref, key: key))
    }

    @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
    mutating func encode(_ value: UInt128, forKey key: Key) throws {
      try state.store(.uint128(Enigma.UInt128Value(value)), ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
      let ref = state.nestedRef(ref: ref, key: key)
      guard try !state.encodeSpecial(value, ref: ref) else { return }
      try value.encode(to: Single(state: state, ref: ref))
    }

    mutating func nestedContainer<NestedKey: CodingKey>(
      keyedBy _: NestedKey.Type,
      forKey key: Key
    ) -> KeyedEncodingContainer<NestedKey> {
      KeyedEncodingContainer(state.asKeyed(ref: state.nestedRef(ref: ref, key: key)))
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
      state.asUnkeyed(ref: state.nestedRef(ref: ref, key: key))
    }

    mutating func superEncoder() -> Encoder {
      Single(state: state, ref: state.nestedRef(ref: ref, key: Enigma.Pin.super))
    }

    mutating func superEncoder(forKey key: Key) -> Encoder {
      Single(state: state, ref: state.nestedRef(ref: ref, key: key))
    }
  }
}
