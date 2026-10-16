import Enigmatic

extension Enigma {
  /// Models Float input using Enigma's current widened-Double representation.
  static func float(_ value: Float) -> Self {
    .double(Double(value))
  }
}
