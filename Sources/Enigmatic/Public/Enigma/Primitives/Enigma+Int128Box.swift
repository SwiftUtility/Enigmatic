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

    /// Converts to Float when the canonical decimal representation is preserved.
    /// Returns nil when the value overflows or its canonical representation changes.
    /// - Returns: The converted Float, or nil when conversion cannot preserve the value.
    /// - Complexity: O(1), with a bounded decimal-component conversion.
    @inlinable
    public var asFloat: Float? {
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        value.asFloat
      } else {
        asFloatFallback()
      }
    }

    /// Converts to Double when the canonical decimal representation is preserved.
    /// Returns nil when the value overflows or its canonical representation changes.
    /// - Returns: The converted Double, or nil when conversion cannot preserve the value.
    /// - Complexity: O(1), with a bounded decimal-component conversion.
    @inlinable
    public var asDouble: Double? {
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        value.asDouble
      } else {
        asDoubleFallback()
      }
    }

    /// Converts to a fixed-width integer when the canonical value is integral and fits.
    /// Pass the target metatype to infer the requested integer type.
    /// - Returns: The exact integer value, or nil for overflow.
    /// - Complexity: O(1) for a fixed-width target.
    @inlinable
    public func asInteger<T: FixedWidthInteger>(_: T.Type = T.self) -> T? {
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        T(exactly: value)
      } else {
        asIntegerFallback()
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
