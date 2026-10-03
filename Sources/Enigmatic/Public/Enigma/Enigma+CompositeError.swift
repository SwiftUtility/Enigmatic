extension Enigma {
  /// Ordered errors from multiple decoding attempts.
  public struct CompositeError: Error {
    /// Errors in the order they were recorded.
    public var errors: [any Error]

    /// Creates an error list, optionally seeded with existing causes.
    /// - Parameter errors: The initial ordered errors.
    @inlinable
    public init(errors: [any Error] = []) {
      self.errors = errors
    }

    /// Returns the successful result, or records the thrown error and returns nil.
    /// - Parameter block: The autoclosure to evaluate.
    /// - Returns: The block result, or nil after appending its error.
    @inlinable
    public mutating func report<T>(_ block: @autoclosure () throws -> T) -> T? {
      do {
        return try block()
      } catch {
        errors.append(error)
        return nil
      }
    }
  }
}
