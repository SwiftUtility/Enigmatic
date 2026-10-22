// swift-tools-version: 6.1
import PackageDescription

let package = Package(
  name: "EnigmaticBenchmarks",
  platforms: [.macOS(.v15)],
  dependencies: [
    .package(path: ".."),
    .package(url: "https://github.com/outfoxx/PotentCodables.git", exact: "3.5.3"),
    .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", exact: "5.0.2"),
    .package(url: "https://github.com/postmates/PMJSON.git", exact: "4.0.0"),
    .package(url: "https://github.com/GottaGetSwifty/CodableWrappers.git", exact: "3.1.0"),
    .package(url: "https://github.com/marksands/BetterCodable.git", exact: "0.4.0"),
    .package(url: "https://github.com/SwiftyLab/MetaCodable.git", exact: "1.6.1"),
    .package(url: "https://github.com/Flight-School/AnyCodable.git", exact: "0.6.7"),
    .package(url: "https://github.com/orlandos-nl/swift-json.git", exact: "2.5.4"),
  ],
  targets: [
    .executableTarget(name: "Comparison", dependencies: [
      .product(name: "Enigmatic", package: "Enigmatic"),
      .product(name: "PotentCodables", package: "PotentCodables"),
      .product(name: "SwiftyJSON", package: "SwiftyJSON"),
      .product(name: "PMJSON", package: "PMJSON"),
      .product(name: "CodableWrappers", package: "CodableWrappers"),
      .product(name: "BetterCodable", package: "BetterCodable"),
      .product(name: "MetaCodable", package: "MetaCodable"),
      .product(name: "AnyCodable", package: "AnyCodable"),
      .product(name: "IkigaJSON", package: "swift-json"),
    ], swiftSettings: [.swiftLanguageMode(.v5)]),
    .testTarget(name: "ComparisonTests", dependencies: ["Comparison"]),
  ]
)
