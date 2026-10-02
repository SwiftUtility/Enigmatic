import Foundation

extension Enigma {
  @frozen
  public struct UInt128Value: Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    @usableFromInline
    let low: UInt64
    @usableFromInline
    let high: UInt64

    @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
    @inlinable
    public init(_ value: UInt128) {
      self.high = UInt64(value >> 64)
      self.low = UInt64(truncatingIfNeeded: value)
    }

    @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
    @inlinable
    public var value: UInt128 {
      return (UInt128(high) << 64) | UInt128(low)
    }

    public var description: String {
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        return String(describing: value)
      } else {
        return "<UInt128 unavailable>"
      }
    }

    public var debugDescription: String {
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        return String(reflecting: value)
      } else {
        return "<UInt128 unavailable>"
      }
    }

    func isSame(enigma: Enigma) -> Bool {
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        value == enigma.asUInt128
      } else {
        false
      }
    }
  }
}
