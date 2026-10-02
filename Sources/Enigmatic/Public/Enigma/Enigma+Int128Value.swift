import Foundation

extension Enigma {
  @frozen
  public struct Int128Value: Sendable, CustomStringConvertible, CustomDebugStringConvertible {
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

    public var description: String {
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        String(describing: value)
      } else {
        "<Int128 unavailable>"
      }
    }

    public var debugDescription: String {
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        String(reflecting: value)
      } else {
        "<Int128 unavailable>"
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
