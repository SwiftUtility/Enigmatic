// swift-tools-version:6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension SwiftSetting {
#if compiler(<6.4)
  static let anyAppleOSAvailability: [Self] = [.enableExperimentalFeature("AnyAppleOSAvailability")]
#else
  static let anyAppleOSAvailability: [Self] = []
#endif
  static let allSettings: [Self] = anyAppleOSAvailability
}

let package = Package(
  name: "Enigmatic",
  products: [
    .library(name: "Enigmatic", targets: ["Enigmatic"]),
  ],
  targets: [
    .target(
      name: "Enigmatic",
      swiftSettings: SwiftSetting.allSettings
    ),
    .testTarget(
      name: "EnigmaticTests",
      dependencies: ["Enigmatic"],
      swiftSettings: SwiftSetting.allSettings
    ),
  ]
)
