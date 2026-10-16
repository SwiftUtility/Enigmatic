// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if compiler(>=6.3) && compiler(<6.4)
let swiftSettings: [SwiftSetting] = [.enableExperimentalFeature("AnyAppleOSAvailability")]
#else
let swiftSettings: [SwiftSetting] = []
#endif

let package = Package(
  name: "Enigmatic",
  products: [
    .library(name: "Enigmatic", targets: ["Enigmatic"]),
  ],
  targets: [
    .target(name: "Enigmatic", swiftSettings: swiftSettings),
    .testTarget(
      name: "EnigmaticTests",
      dependencies: ["Enigmatic"],
      swiftSettings: swiftSettings
    ),
  ]
)
