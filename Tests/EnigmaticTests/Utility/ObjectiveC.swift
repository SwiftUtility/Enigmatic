#if !(os(anyAppleOS) || os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS))
@inline(__always)
func autoreleasepool<T>(_ body: () throws -> T) rethrows -> T {
  return try body()
}
#endif
