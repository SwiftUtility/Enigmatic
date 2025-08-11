// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Enigmatic",
  products: [
    .library(name: "Enigmatic", targets: ["Enigmatic"]),
  ],
  targets: [
    .target(name: "Enigmatic"),
    .testTarget(name: "EnigmaticTests", dependencies: ["Enigmatic"]),
  ]
)
