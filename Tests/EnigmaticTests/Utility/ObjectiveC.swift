#if !os(anyAppleOS)
@inline(__always)
func autoreleasepool<T>(_ body: () throws -> T) rethrows -> T {
  return try body()
}
#endif
