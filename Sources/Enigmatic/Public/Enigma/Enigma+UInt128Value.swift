import Foundation

extension Enigma {
  /// Stores an unsigned 128-bit integer in an `Enigma` tree.
  @frozen
  public struct UInt128Value: Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    @usableFromInline
    let low: UInt64
    @usableFromInline
    let high: UInt64

    /// Wraps a native `UInt128` for storage in an Enigma tree.
    @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
    @inlinable
    public init(_ value: UInt128) {
      self.high = UInt64(value >> 64)
      self.low = UInt64(truncatingIfNeeded: value)
    }

    /// The wrapped native integer.
    @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
    @inlinable
    public var value: UInt128 {
      return (UInt128(high) << 64) | UInt128(low)
    }

    /// The decimal representation, or an availability marker on older systems.
    public var description: String {
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        return String(describing: value)
      } else {
        return "<UInt128 unavailable>"
      }
    }

    /// A debug representation, or an availability marker on older systems.
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
