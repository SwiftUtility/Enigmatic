extension Enigma {
  /// Ordered errors from multiple decoding attempts.
  public struct CompositeError: Error {
    /// Errors in the order they were recorded.
    /// - Complexity: O(1) to access the copy-on-write array value.
    public var errors: [any Error]

    /// Creates an error list, optionally seeded with existing causes.
    /// - Parameter errors: The initial ordered errors.
    /// - Complexity: O(1) to store the copy-on-write array value.
    @inlinable
    public init(errors: [any Error] = []) {
      self.errors = errors
    }

    /// Returns the successful result, or records the thrown error and returns nil.
    /// - Parameter block: The autoclosure to evaluate.
    /// - Returns: The block result, or nil after appending its error.
    /// - Complexity: O(1) on success; appending a failure is amortized O(1) with
    ///   unique storage and O(n) if copy-on-write must duplicate the error array,
    ///   where n is the number of recorded errors. This excludes autoclosure work.
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
