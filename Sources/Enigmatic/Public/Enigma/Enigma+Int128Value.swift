import Foundation

#if os(anyAppleOS) || os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
extension Enigma {
  @frozen
  public struct Int128Value: Sendable {
    @usableFromInline
    let low: UInt64
    @usableFromInline
    let high: UInt64

    @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
    @inlinable
    public init(_ value: Int128) {
      let bits = UInt128(bitPattern: value)
      self.high = UInt64(bits >> 64)
      self.low = UInt64(truncatingIfNeeded: bits)
    }

    @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
    @inlinable
    public var value: Int128 {
      let bits = (UInt128(high) << 64) | UInt128(low)
      return Int128(bitPattern: bits)
    }

    var rawObject: NSObject {
      withUnsafePointer(to: self) { bytes in
        withUnsafePointer(to: ObjCType.int128) { objCType in
          NSValue(bytes: bytes, objCType: objCType) as NSObject
        }
      }
    }

    func isSame(enigma: Enigma) -> Bool {
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        value == enigma.asInt128
      } else {
        false
      }
    }
  }
}
#else
extension Int128 {
  var rawObject: NSObject {
    withUnsafePointer(to: self) { bytes in
      withUnsafePointer(to: ObjCType.int128) { objCType in
        NSValue(bytes: bytes, objCType: objCType) as NSObject
      }
    }
  }

  func isSame(enigma: Enigma) -> Bool {
    self == enigma.asInt128
  }
}
#endif
