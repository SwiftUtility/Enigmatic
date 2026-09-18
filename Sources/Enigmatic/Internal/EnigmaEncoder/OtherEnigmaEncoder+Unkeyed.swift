import Foundation

extension OtherEnigmaEncoder {
  struct Unkeyed: UnkeyedEncodingContainer {
    let state: State
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
      try state.store(.float(value), ref: state.nestedRef(ref: ref, key: nil))
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

    private mutating func append(_ value: Enigma) throws {
      try state.store(value, ref: state.nestedRef(ref: ref, key: nil))
    }
  }
}
