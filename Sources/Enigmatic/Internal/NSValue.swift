import Foundation

extension NSValue {
  @inline(__always)
  func extract<T>(seed: consuming T) -> T {
    withUnsafeMutablePointer(to: &seed) { pointer in
#if os(anyAppleOS) || os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
      getValue(pointer, size: MemoryLayout<T>.size)
#else
      getValue(pointer)
#endif
    }
    return seed
  }
}
