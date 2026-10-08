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
let paths = tree.allPaths            // [name], [scores], [scores, 0], [scores, 1]
```

A missing path returns `nil`; a stored null is `Enigma.null`. Assigning `nil`
deletes a child, while assigning `.null` stores a null. Array deletion shifts
later indices. An empty path reads/replaces the root; deleting the root is a
no-op. Missing dictionary children and an array element at `count` can be created;
negative indices, skipped indices, and incompatible existing parents are no-ops.
The `or:` fallback is evaluated only for a missing value.

`allPaths` includes every descendant, including empty containers, and excludes the
root. Its depth-first order uses sorted dictionary keys and ascending indices.

## Merge partial models

```swift
let original: Enigma = ["settings": ["enabled": false, "retries": 2]]
let patch: Enigma = ["settings": ["enabled": true]]
let merged = original.merging(patch, replace: true)
// ["settings": ["enabled": true, "retries": 2]]
```

Only dictionaries merge recursively. Arrays and scalars go to the conflict
resolver as whole values. `replace: true` chooses the incoming value, `skipEqual: true`
accepts equal values and throws otherwise, and `skipEqual: false` rejects every conflict.
A custom resolver receives the path and both values. A throwing mutating merge
leaves the original tree unchanged. Dictionary conflict visitation order is not
specified.

## Coding strategies

```swift
import Enigmatic
import Foundation

struct Payload: Codable {
  @Codec.Box<Codec.Base64Data> var bytes: Data
  @Codec.Box<Codec.StringURL?> var link: URL?
}

let payload = Payload(bytes: Data([1, 2, 3]), link: nil)
let tree = try Enigma(encode: payload)
// ["bytes": "AQID", "link": .null]
let restored = try tree.decode(Payload.self)
```

Strategies compose with arrays, dictionaries, optionals and sets:
`[Codec.Base64Data]`, `[String: Codec.Base64Data?]`, or `Set<Codec.Id<Int>>`.
Optional strategy values accept an explicit null. In consumer models using
`import Enigmatic`, synthesized coding of an optional `Codec.Box` property writes
null for a nil value. Decoding an explicit null produces nil; a missing key throws
`DecodingError.keyNotFound`. The library's internal keyed overloads for omitting
nil and accepting missing keys are not public. A `Set` removes duplicates and
does not promise encoded ordering.

`Codec.Either<Right, Left>` tries Right first, then Left. If both fail, a
`DecodingError.dataCorrupted` contains an `Enigma.CompositeError` with both causes.
`Codec.Each` encodes components into the same container and decodes each from the
same input; it is useful for disjoint keyed models. Disjoint children can share a
container key, and arrays written under the same key append. Competing leaf writes
or incompatible container writes throw with Enigma's encoder.
`Result<Strategy, any Error>` captures a decoding error as a value; encoding that
failure throws and preserves its cause.

## Serialization contracts

- Integer conversions use exact representability: fractions and overflow return
  `nil` from accessors and fail typed decoding. Integers must be exactly
  representable when converted to Float/Double. Double-to-Float conversion allows
  rounding and underflow but rejects finite values that round to infinity.
  Equality compares normalized shortest decimal representations across numeric
  cases: `.float(0.1) == .double(0.1)`, but both differ from
  `.double(Double(Float(0.1)))`. This supports JSON-style untyped comparison and
  does not imply equal binary values or successful exact typed conversions.
  NaNs compare equal, including Date timestamps; positive and negative zero compare
  equal. `skipEqual: true` uses this same equality.
- Direct `Date`/`Data` values encoded with `Enigma(encode:)` retain `.date`/`.data`
  at root and nested positions; explicit Codec strategies can select other
  representations.
- `asAny` exports native Swift/Foundation values, using `NSNull` for null.
  It does not promise a JSON/plist-compatible object.
- `asJsonObject` rejects dates, data, non-finite numbers and 128-bit integers.
  Scalars require `.fragmentsAllowed` when passed to `JSONSerialization`.
- `asPlistObject` rejects null and 128-bit integers. Use arrays/dictionaries as
  document roots for portable property-list encoding.
- When encoding an existing Enigma tree through an external `Encoder`, native
  Date/Data nodes invoke Foundation's own `encode(to:)` at root, array, and keyed
  positions. With `JSONEncoder`, dates become seconds since 2001 and data becomes
  an array of bytes, regardless of its date/data encoding strategies. Apply
  explicit `Codec.Box` strategies to model values before building the tree when
  a different wire representation is required.
  A root Enigma passed to `Enigma(encode:)` is returned directly. Enigma values
  embedded in a model invoke that same Codable representation, so their native
  Date/Data cases become reference-date seconds/byte arrays inside the new tree.
- External Codable decoding probes available containers and value types and
  tries integer types before floating-point types to preserve large integers,
  including 128-bit values on supported systems. It downscales numbers and
  preserves decimal equality when downscaling floats. It does not promise to
  preserve enum cases or the sign of zero, or infer Date/Data from
  their JSON representations.
- JSON does not retain Float/Double width. A Float encoded as decimal `0.1` reads
  into an untyped tree as Double `0.1`; these trees compare equal. Decode through
  the original model's Float type to restore its width. Equality uses Swift's
  shortest decimal number descriptions, not arbitrary encoder output; binary
  plists and Foundation NSNumber bridging can widen Float and change its decimal
  representation. Non-finite numbers extend the equality policy beyond JSON.
- `description` and `debugDescription` are diagnostic text, not JSON.

Container adapters preserve userInfo and both representations of each coding key.
Missing keyed `decodeNil` throws `keyNotFound`; null primitive values throw
`valueNotFound`, and incompatible non-null values throw `typeMismatch`. Failed
unkeyed decodes leave the index unchanged. Super decoders accept null to support
nullable scalar superclass values; successfully obtaining one consumes its array
element. This nullable-super behavior differs from Swift's documented null error.

Encoding is not transactional. If a model catches a child encoding error, a
reserved array element or partially written child can remain in the output.
Unwritten children become empty dictionaries; a root that encodes nothing throws.
Arena materialization is iterative, while consumer Codable implementations and
other tree operations may still recurse.

Date strategies reject non-finite dates and invalid decimal scale factors.
`UnixDate<3>` represents milliseconds; `UnixDate<6>` represents microseconds.
`UnixIntDate` additionally truncates toward zero and rejects integer overflow.
Foundation `Date` uses floating-point storage, so extreme dates and scales may
lose precision even if finite.

See the [DocC catalog](Sources/Enigmatic/Enigmatic.docc/Enigmatic.md) for API
guides and symbol documentation.

## Development

```sh
swift test --skip PerformanceTests
swift test -c release --skip PerformanceTests
python3 -m unittest discover -s Scripts/tests
swift test --enable-code-coverage --skip PerformanceTests
python3 Scripts/check-coverage.py "$(swift test --show-codecov-path)" --minimum 100
swift test -c release --filter PerformanceTests
```

CI and tag releases require 100% executable line coverage under `Sources/Enigmatic`.
The coverage script defaults to 90%, so pass `--minimum 100` to match CI.
Benchmarks are separate, run without coverage, and report relative timings
without noisy CI timing thresholds. The manual CI workflow also
uploads benchmark results. `DocumentationExamplesTests` exercises the editing,
merge, and property-wrapper examples using the public API.

Build DocC with Xcode's documentation compiler:

```sh
swift package dump-symbol-graph --minimum-access-level public
xcrun docc convert Sources/Enigmatic/Enigmatic.docc \
  --additional-symbol-graph-dir "$(dirname "$(swift build --show-bin-path)")/symbolgraph" \
  --output-path .build/Enigmatic.doccarchive --warnings-as-errors
```

CI setup follows the [Swift GitHub Actions guide](https://docs.github.com/en/actions/tutorials/build-and-test-code/swift)
and [setup-swift](https://github.com/swift-actions/setup-swift).

## License

Apache 2.0. See [LICENSE](LICENSE).
