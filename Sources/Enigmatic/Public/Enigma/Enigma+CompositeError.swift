extension Enigma {
  /// Ordered errors from multiple decoding attempts.
  public struct CompositeError: Error {
    public var errors: [any Error]

    @inlinable
    public init(errors: [any Error] = []) {
      self.errors = errors
    }

    /// Returns the successful result, or records the thrown error and returns nil.
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
