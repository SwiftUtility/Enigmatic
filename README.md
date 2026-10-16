# Enigmatic

[![Checks](https://github.com/SwiftUtility/Enigmatic/actions/workflows/checks.yml/badge.svg?branch=main&event=push)](https://github.com/SwiftUtility/Enigmatic/actions/workflows/checks.yml)
[![Release](https://img.shields.io/github/v/release/SwiftUtility/Enigmatic)](https://github.com/SwiftUtility/Enigmatic/releases/latest)
[![Swift](https://img.shields.io/badge/Swift-6.3%2B-orange?logo=swift)](Package.swift)
[![SwiftPM](https://img.shields.io/badge/Swift_Package_Manager-compatible-brightgreen)](#install)
[![License](https://img.shields.io/github/license/SwiftUtility/Enigmatic)](LICENSE)
[![Coverage](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftutility.github.io%2FEnigmatic%2Fcoverage-badge.json)](https://github.com/SwiftUtility/Enigmatic/actions/workflows/release.yml)
[![Documentation](https://img.shields.io/badge/Documentation-DocC-blue)](https://swiftutility.github.io/Enigmatic/documentation/enigmatic/)
[![Tested platforms](https://img.shields.io/badge/tested_on-macOS%20%7C%20Linux-blue)](https://swiftutility.github.io/Enigmatic/documentation/enigmatic/development/)

Turn `Codable` values into a tree you can inspect, edit, merge, and decode again.
Use `@Codec.Box` to choose how individual properties are encoded.

## Install

Requires Swift 6.3 or newer. Add
[SwiftUtility/Enigmatic](https://github.com/SwiftUtility/Enigmatic) in Xcode and
link the **Enigmatic** product to your target. For SwiftPM targets, use
`.product(name: "Enigmatic", package: "Enigmatic")`.

Some APIs require newer Apple runtimes; see the
[compatibility notes](https://swiftutility.github.io/Enigmatic/documentation/enigmatic/#Compatibility).

## Edit a model

```swift
import Enigmatic

struct User: Codable {
  var name: String
  var scores: [Int]
}

var tree = try Enigma(encode: User(name: "Ada", scores: [10]))
tree["name"] = "Grace"
tree["scores", 1] = 20
let user = try tree.decode(User.self) // Grace, [10, 20]
```

String keys and array indices form a path. Missing values return `nil`;
assigning `nil` deletes a child, while `.null` stores a null. Array writes append
at `count`; indices outside `0...count` leave the tree unchanged.

## Merge a patch

```swift
let original: Enigma = ["settings": ["enabled": false, "retries": 2]]
let patch: Enigma = ["settings": ["enabled": true]]
let merged = original.merging(patch, policy: .replace)
// ["settings": ["enabled": true, "retries": 2]]
```

Dictionaries merge recursively. `.replace` takes incoming values; `.skip` keeps
existing ones. A policy can also zip, append, or prepend arrays.

## Choose a representation

```swift
import Foundation
import Enigmatic

struct Payload: Codable {
  @Codec.Box<Codec.Base64Data> var bytes: Data
  @Codec.Box<Codec.StringURL?> var link: URL?
}

let payload = Payload(bytes: Data([1, 2, 3]), link: nil)
let tree = try Enigma(encode: payload) // ["bytes": "AQID"]
let restored = try tree.decode(Payload.self)
```

Strategies compose with arrays, dictionaries, optionals, and sets. Optional box
properties omit nil keys and decode missing or null keys as nil. `Codec.Either`
tries Right first; `Codec.Each` combines disjoint keyed models.

## Serialization limitations

> **Warning:** Foundation's type-specific serialization strategies are not a
> portable representation contract for an Enigma tree. Choose representations
> with `Codec.Box` on the model before building the tree.

- `Data` and `Date` stay native in memory, but serializing a tree bypasses
  `JSONEncoder.dataEncodingStrategy`, `JSONEncoder.dateEncodingStrategy`, and
  PropertyListEncoder's native handling. Data becomes a byte array; Date becomes
  seconds since 2001-01-01. Use `@Codec.Box<Codec.Base64Data>` for Base64 and
  `@Codec.Box<Codec.PlistDate>` for explicit reference-date seconds, or
  `Codec.UnixDate<0>` for Unix seconds on supported runtimes.
- `Float` and `Double` can retain `NaN` and positive/negative infinity in memory,
  but these values are not JSON numbers. Default JSON encoding and
  `asJsonObject` reject them. External JSONEncoder/JSONDecoder instances can use
  matching `nonConformingFloatEncodingStrategy`/`nonConformingFloatDecodingStrategy`
  settings. Enigma's own model/tree conversions expose no such settings; use
  `Codec.Box` with a custom string strategy for an explicit representation.

See [explicit serialization strategies](https://swiftutility.github.io/Enigmatic/documentation/enigmatic/codingstrategies/#Explicit-portable-representations)
for a complete Data/Date/Float/Double example. `Codec.CanonicalFloat` changes
finite Float representation; it does not make `NaN` or infinity JSON-compatible.

[API reference](https://swiftutility.github.io/Enigmatic/documentation/enigmatic/) ·
[Tree operations](https://swiftutility.github.io/Enigmatic/documentation/enigmatic/treeoperations/) ·
[Coding strategies](https://swiftutility.github.io/Enigmatic/documentation/enigmatic/codingstrategies/) ·
[Serialization](https://swiftutility.github.io/Enigmatic/documentation/enigmatic/serialization/) ·
[Development](https://swiftutility.github.io/Enigmatic/documentation/enigmatic/development/)

Apache 2.0. See [LICENSE](LICENSE).
