import Foundation

extension Enigma {
  /// Stores a signed 128-bit integer in an `Enigma` tree.
  @frozen
  public struct Int128Box: Sendable {
    @usableFromInline
    var low: UInt64
    @usableFromInline
    var high: UInt64

    /// Wraps a native `Int128` for storage in an Enigma tree.
    /// - Complexity: O(1) for this fixed-width value.
    @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
    @inlinable
    public init(_ value: Int128) {
      let bits = UInt128(bitPattern: value)
      self.high = UInt64(bits >> 64)
      self.low = UInt64(truncatingIfNeeded: bits)
    }

    /// The wrapped native integer.
    /// - Complexity: O(1) for this fixed-width value.
    @available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *)
    @inlinable
    public var value: Int128 {
      get { Int128(bitPattern: (UInt128(high) << 64) | UInt128(low)) }
      set { self = Self(newValue) }
    }

    @inlinable
    public var asFloat: Float? {
#warning("check")
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        value.asFloat
      } else {
        NumberComponents(self).asFloat
      }
    }

    @inlinable
    public var asDouble: Double? {
#warning("check")
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        value.asDouble
      } else {
        NumberComponents(self).asDouble
      }
    }

    public func asInteger<T: FixedWidthInteger>(_: T.Type = T.self) -> T? {
      #warning("check")
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        T(exactly: value)
      } else if high == 0 {
        T(exactly: low)
      } else if high == .max, low.leadingZeroBitCount == 0 {
        T(exactly: Int64(bitPattern: low))
      } else {
        nil
      }
    }
  }
}

extension Enigma.Int128Box: CustomStringConvertible {
  /// The decimal representation, or an availability marker on older systems.
  /// - Complexity: O(1) for this fixed-width value.
  public var description: String {
    if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
      String(describing: value)
    } else {
#warning("make Ryu based")
      "<Int128 unavailable>"
    }
  }
}

extension Enigma.Int128Box: CustomDebugStringConvertible {
  /// A debug representation, or an availability marker on older systems.
  /// - Complexity: O(1) for this fixed-width value.
  public var debugDescription: String {
    if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
      String(reflecting: value)
    } else {
#warning("make Ryu based")
      "<Int128 unavailable>"
    }
  }
}
