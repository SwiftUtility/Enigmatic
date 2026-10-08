# Enigmatic

Enigmatic is a Swift library for inspecting, editing, merging, and decoding
`Codable` values through an intermediate value tree. It also provides composable
coding strategies through `@Codec.Box`.

## Requirements and installation

Swift **6.3 or newer** is required by the package manifest. CI uses Swift **6.3.3**
on macOS 26 and Ubuntu 24.04, in Debug and Release. The package does not raise
SwiftPM's default deployment targets; individual APIs have availability limits:

- `Codec.Each`: macOS 14 / iOS 17 / tvOS 17 / watchOS 10 or newer.
- Int128/UInt128 access: macOS 15 / iOS 18 / tvOS 18 / watchOS 11 / visionOS 2 or newer.
- `Codec.UnixDate<scale>` and `Codec.UnixIntDate<scale>`: Apple OS 26 or newer.
  Use the named seconds/milliseconds strategies on older Apple systems.
- Linux uses the Swift toolchain runtime and does not have Apple OS availability limits.

Add the package in Xcode, or use this SwiftPM dependency (pin a version for a
reproducible build):

```swift
.package(url: "https://github.com/SwiftUtility/Enigmatic.git", .upToNextMajor(from: "3.0.0"))
```

Add `.product(name: "Enigmatic", package: "Enigmatic")` to your target dependencies.

## Encode, edit, and decode

```swift
import Enigmatic

struct User: Codable, Equatable {
  var name: String
  var scores: [Int]
}

var tree = try Enigma(encode: User(name: "Ada", scores: [10]))
tree["scores", 1] = 20                 // Append at the current array count.
tree["name"] = "Grace"
let user = try tree.decode(User.self) // User(name: "Grace", scores: [10, 20])
let paths = tree.allPaths            // [name], [name, scores], [name, scores, 0], [name, scores, 1]
```

A missing path returns `nil`; a stored null is `Enigma.null`. Assigning `nil`
deletes a child, while assigning `.null` stores a null. Array deletion shifts
later indices. An empty path reads/replaces the root; deleting the root is a
no-op. Missing dictionary children are created, and a node is replaced with an
empty dictionary or array when the next path pin requires that container. An
array index equal to `count` appends; a negative index or an index greater than
`count` makes the entire assignment a no-op, even if earlier path components
would have replaced containers. The `or:` fallback is evaluated only for a
missing value.

`allPaths` includes every descendant, including empty containers, and excludes
the root. Its depth-first order uses sorted dictionary keys and ascending indices.

## Merge partial models

```swift
let original: Enigma = ["settings": ["enabled": false, "retries": 2]]
let patch: Enigma = ["settings": ["enabled": true]]
let merged = original.merging(patch, replace: true)
// ["settings": ["enabled": true, "retries": 2]]
```

Only dictionary pairs merge recursively. Other conflicts are resolved as whole
values. `merging(_:replace:)` chooses the incoming value when true and the
existing value when false. `merging(_:skipEqual:)` accepts equal conflicts when
true and throws `EncodingError.invalidValue` otherwise. A custom resolver
receives the path and both values. A throwing mutating merge leaves the original
tree unchanged. Dictionary conflict visitation order is unspecified.

## Coding strategies

```swift
import Foundation

struct Payload: Codable {
  @Codec.Box<Codec.Base64Data> var bytes: Data
  @Codec.Box<Codec.StringURL?> var link: URL?
}

let payload = Payload(bytes: Data([1, 2, 3]), link: nil)
let tree = try Enigma(encode: payload)
// ["bytes": "AQID"]
let restored = try tree.decode(Payload.self)
```

Strategies compose with arrays, dictionaries, optionals and sets:
`[Codec.Base64Data]`, `[String: Codec.Base64Data?]`, or `Set<Codec.Id<Int>>`.
Optional strategy values accept an explicit null. For an optional `Codec.Box`
property, a nil value is omitted from keyed output, and decoding a missing or
null key produces nil. A `Set` removes duplicates and does not promise encoded
ordering.

`Codec.Either<Right, Left>` tries Right first, then Left. If both fail, a
`DecodingError.dataCorrupted` contains an `Enigma.CompositeError` with both causes.
`Codec.Each` encodes components into the same container and decodes each from the
same input; it is useful for disjoint keyed models. Overlapping keys or competing
scalar writes throw with Enigma's encoder. `Result<Strategy, any Error>` captures
a decoding error as a value; encoding that failure throws and preserves its cause.

## Serialization contracts

- Numeric equality and conversions use canonical decimal values: shortest
  round-trip components for finite Float/Double values and exact decimal values
  for integers. Conversions succeed only when the canonical value is preserved;
  integer accessors also require an integral value in range. This differs from
  ordinary Float rounding and from equality of IEEE bit patterns. NaN compares
  equal to NaN, and positive and negative zero compare equal.
- Root and nested `Date`/`Data` values retain `.date`/`.data` in an Enigma tree.
- `asAny` converts the tree to nested Swift/Foundation values. It is an in-memory
  bridge, not a promise of JSON/plist compatibility.
- `Enigma(cast:)` supports dictionaries with string or integer keys, `AnyHashable`
  keys whose bases convert to strings, and `CodingKeyRepresentable` keys where
  available. Keys normalize to strings; collisions and unsupported key types
  throw. Arrays and sets convert to arrays; set element order is unspecified.
- `asJsonObject` rejects dates, data, non-finite numbers and 128-bit integers.
  Scalars require `.fragmentsAllowed` when passed to `JSONSerialization`.
- `asPlistObject` rejects null and 128-bit integers. Use arrays/dictionaries as
  document roots for portable property-list encoding.
- Through Codable, `Enigma.encode(to:)` passes a Float case to the supplied
  `Encoder` as `Float`. The legacy `asJsonObject` and `asPlistObject` bridges box
  it as `NSNumber`; JSON and property-list serializers write an ordinary number
  without a Float/Double type tag. A bridged Float may therefore return as a
  Double with different canonical components. Codable encoders targeting an
  untyped format have the same wire-format limitation. Numeric identity survives
  only when the serialized decimal has the same canonical components.
- When encoding Enigma through an external `Encoder`, keyed Date/Data fields use
  that encoder's strategies. Root and array Date/Data nodes invoke Foundation's
  own `encode(to:)` representation. Use explicit `Codec.Box` strategies when a
  stable date/data wire representation is required across positions.
- `description` and `debugDescription` are diagnostic text, not JSON.

Date strategies reject non-finite dates and invalid decimal scale factors.
`UnixDate<3>` represents milliseconds; `UnixDate<6>` represents microseconds.
`UnixIntDate` additionally truncates toward zero and rejects integer overflow.
Foundation `Date` uses floating-point storage, so extreme dates and scales may
lose precision even if finite.

## Complexity

Public API symbol documentation includes a `Complexity` note. Tree path lookup
is expected O(d) for a path of depth d. Mutation also walks the path in expected
O(d), with possible copy-on-write costs proportional to modified collection
sizes when storage is shared. Tree conversion, Codable traversal, and descriptions
are linear in the number of visited values. `allPaths` additionally sorts keys
within each dictionary. Recursive dictionary merge is expected linear in visited
values and dictionary operations, plus custom resolver work.

See the [DocC catalog](Sources/Enigmatic/Enigmatic.docc/Enigmatic.md) for API
guides and symbol documentation.

## Development

```sh
swift test --skip PerformanceTests
swift test -c release --skip PerformanceTests
swift test --enable-code-coverage --skip PerformanceTests
python3 Scripts/check-coverage.py "$(swift test --show-codecov-path)" --minimum 100
swift test -c release --filter PerformanceTests
```

Coverage checks require 100% of executable lines under `Sources/Enigmatic` on
pull requests and release tags. Benchmarks are separate, run without coverage, and report
relative timings without noisy CI timing thresholds. The manual CI workflow also
uploads benchmark results. README examples are exercised in
`DocumentationExamplesTests`.

Build DocC with Xcode's documentation compiler:

```sh
swift package dump-symbol-graph --minimum-access-level public
xcrun docc convert Sources/Enigmatic/Enigmatic.docc \
  --additional-symbol-graph-dir "$(dirname "$(swift build --show-bin-path)")/symbolgraph" \
  --output-path .build/Enigmatic.doccarchive --warnings-as-errors
```

CI setup follows the [Swift GitHub Actions guide](https://docs.github.com/en/actions/tutorials/build-and-test-code/swift)
and [setup-swift](https://github.com/swift-actions/setup-swift).

Pushing a tag whose name starts with `v` runs the release workflow. It tests Debug
and Release builds on macOS 26 and Ubuntu 24.04, enforces 100% library line
coverage on macOS, then creates a GitHub release with generated notes.

## License

Apache 2.0. See [LICENSE](LICENSE).
