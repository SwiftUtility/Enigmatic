# Enigmatic

[![Checks](https://github.com/SwiftUtility/Enigmatic/actions/workflows/checks.yml/badge.svg?branch=main&event=push)](https://github.com/SwiftUtility/Enigmatic/actions/workflows/checks.yml)
[![Release](https://img.shields.io/github/v/release/SwiftUtility/Enigmatic)](https://github.com/SwiftUtility/Enigmatic/releases/latest)
[![Swift](https://img.shields.io/badge/Swift-6.1%2B-orange?logo=swift)](Package.swift)
[![SwiftPM](https://img.shields.io/badge/Swift_Package_Manager-compatible-brightgreen)](#install)
[![License](https://img.shields.io/github/license/SwiftUtility/Enigmatic)](LICENSE)
[![Coverage](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftutility.github.io%2FEnigmatic%2Fcoverage-badge.json)](https://github.com/SwiftUtility/Enigmatic/actions/workflows/release.yml)
[![Documentation](https://img.shields.io/badge/Documentation-DocC-blue)](https://swiftutility.github.io/Enigmatic/documentation/enigmatic/)
[![Tested platforms](https://img.shields.io/badge/tested_on-macOS%20%7C%20Linux%20%7C%20Windows-blue)](https://swiftutility.github.io/Enigmatic/documentation/enigmatic/development/)

Turn `Codable` values into a tree you can inspect, edit, merge, and decode again.
Use `@Codec.Box` to choose how individual properties are encoded.

## Choosing a library

Choose Enigmatic when you need to edit or merge a `Codable` model as a tree, then
decode it again without a JSON round trip. Its reusable property strategies also
work on their own.

| Alternative | When it may fit better |
| --- | --- |
| Native `Codable` | You only read or write known models with `JSONEncoder` and `JSONDecoder`. Custom `Codable` code can handle property formats too, without another library or tree. |
| [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) | You want JSON getters with defaults, edits, and simple merges. Enigmatic adds more merge rules and direct model/tree conversion. |
| [AnyCodable](https://github.com/Flight-School/AnyCodable) | You only need mixed value types in `Codable` arrays or dictionaries. |
| [PotentCodables](https://github.com/outfoxx/PotentCodables) | You need dedicated parsers, YAML or CBOR support, or more native value types. Enigmatic has no parser of its own. |
| [CodableWrappers](https://github.com/GottaGetSwifty/CodableWrappers) | You want property wrappers or key-renaming macros. Enigmatic has no such macros. |
| [BetterCodable](https://github.com/marksands/BetterCodable) | You want ready-made defaults or collections that skip invalid values. |

The [competitor benchmarks](https://swiftutility.github.io/Enigmatic/documentation/enigmatic/competitorbenchmarks/)
compare shared samples and roundtrip contracts. Results distinguish native parsers,
Foundation bridges, and model wrappers, including the cost of required conversions.

## Install

Requires Swift 6.1 or newer. Add
[SwiftUtility/Enigmatic](https://github.com/SwiftUtility/Enigmatic) in Xcode and
link the **Enigmatic** product to your target. For SwiftPM targets, use
`.product(name: "Enigmatic", package: "Enigmatic")`.

The generic Unix date strategies require Swift 6.2.3 or newer; use the named
seconds/milliseconds strategies with older compilers. Some APIs also require
newer Apple OS versions; see the
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

String keys and array indices form a path. Reading a missing value returns `nil`.
Assigning `nil` deletes a child; `.null` stores a null value. Writing at an array's
`count` appends a value. An index outside `0...count` leaves the tree unchanged.

## Merge a patch

```swift
let original: Enigma = ["settings": ["enabled": false, "retries": 2]]
let patch: Enigma = ["settings": ["enabled": true]]
let merged = original.merging(patch, policy: .replace)
// ["settings": ["enabled": true, "retries": 2]]
```

Nested dictionaries are merged too. `.replace` takes incoming values; `.skip`
keeps existing ones. For arrays, you can merge elements by index, append, or
prepend.

## Choose how a property is encoded

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

Strategies also work with arrays, dictionaries, optionals, and sets. An optional
`Codec.Box` leaves out the key when its value is `nil`. Missing or null keys
decode as `nil`. `Codec.Either` tries `Right` before `Left`. `Codec.Each` combines
models that encode as dictionaries with no overlapping keys.

## Serialization limitations

> **Warning:** When you encode an Enigma tree, Foundation's date and data settings
> do not choose how those values are written. Use `Codec.Box` on the model to
> choose the format before building the tree.

- `Data` and `Date` keep their original types in memory. Encoding a tree bypasses
  `JSONEncoder.dataEncodingStrategy`, `JSONEncoder.dateEncodingStrategy`, and
  the usual date/data handling in `PropertyListEncoder`. Data becomes a byte
  array; Date becomes seconds since 2001-01-01. Use `@Codec.Box<Codec.Base64Data>`
  for Base64 and `@Codec.Box<Codec.PlistDate>` for seconds since 2001-01-01, or
  `Codec.UnixSecondsDate` for Unix seconds. With Swift 6.2.3 or newer, prefer
  `Codec.UnixDate<0>` on supported OS versions.
- `Float` and `Double` can store `NaN` and positive or negative infinity in memory.
  These values are not valid JSON numbers. Default JSON encoding and
  `asJsonObject` reject them. When encoding or decoding the tree with your own
  `JSONEncoder` and `JSONDecoder`, you can use matching
  `nonConformingFloatEncodingStrategy` and `nonConformingFloatDecodingStrategy`
  settings. Enigma's model/tree conversions do not have these settings. Use a
  custom `Codec.Box` strategy to store these values as strings.

See [explicit serialization strategies](https://swiftutility.github.io/Enigmatic/documentation/enigmatic/codingstrategies/#Explicit-portable-representations)
for a complete Data/Date/Float/Double example. `Codec.CanonicalFloat` changes how
finite floats are stored; it does not make `NaN` or infinity valid JSON.

[API reference](https://swiftutility.github.io/Enigmatic/documentation/enigmatic/) ·
[Tree operations](https://swiftutility.github.io/Enigmatic/documentation/enigmatic/treeoperations/) ·
[Coding strategies](https://swiftutility.github.io/Enigmatic/documentation/enigmatic/codingstrategies/) ·
[Serialization](https://swiftutility.github.io/Enigmatic/documentation/enigmatic/serialization/) ·
[Development](https://swiftutility.github.io/Enigmatic/documentation/enigmatic/development/)

Performance comparisons live in the independent `Benchmarks` package. Run
`./Benchmarks/Run.command` to regenerate the
[competitor report](https://swiftutility.github.io/Enigmatic/documentation/enigmatic/competitorbenchmarks/).
The main package's `swift test` runs functional tests only.

Apache 2.0. See [LICENSE](LICENSE).
