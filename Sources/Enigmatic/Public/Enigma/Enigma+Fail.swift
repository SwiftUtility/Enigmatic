extension Enigma {
  public struct CompositeError: Error {
    public var errors: [any Error] = []

    @inlinable
    public init(errors: [any Error] = []) {
      self.errors = errors
    }

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
