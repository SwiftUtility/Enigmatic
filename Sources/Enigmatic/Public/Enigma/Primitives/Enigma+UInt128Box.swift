import Foundation

extension Enigma {
  /// Stores an unsigned 128-bit integer in an `Enigma` tree.
  @frozen
  public struct UInt128Box: Sendable {
    @usableFromInline
    var low: UInt64
    @usableFromInline
    var high: UInt64

    /// Wraps a native `UInt128` for storage in an Enigma tree.
    /// - Complexity: O(1) for this fixed-width value.
    @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
    @inlinable
    public init(_ value: UInt128) {
      self.low = UInt64(truncatingIfNeeded: value)
      self.high = UInt64(value >> 64)
    }

    /// The wrapped native integer.
    /// - Complexity: O(1) for this fixed-width value.
    @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
    @inlinable
    public var value: UInt128 {
      get { (UInt128(high) << 64) | UInt128(low) }
      set { self = Self(newValue) }
    }
  }
}

extension Enigma.UInt128Box: CustomStringConvertible {
  /// The decimal representation, or an availability marker on older systems.
  /// - Complexity: O(1) for this fixed-width value.
  public var description: String {
    if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
      return String(describing: value)
    } else {
      return "<UInt128 unavailable>"
    }
  }
}

extension Enigma.UInt128Box: CustomDebugStringConvertible {
  /// A debug representation, or an availability marker on older systems.
  /// - Complexity: O(1) for this fixed-width value.
  public var debugDescription: String {
    if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
      return String(reflecting: value)
    } else {
      return "<UInt128 unavailable>"
    }
  }
}
