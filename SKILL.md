---
name: enigmatic-project
description: Navigate, explain, modify, and test the Enigmatic Swift package using its architecture, task-to-file map, and behavioral contracts. Use for work in this repository.
---

# Enigmatic project guide

## Start here; load details only as needed

Use this file as the initial repository context. All paths below are relative to
the project root. Choose the relevant map row, read its implementation and tests,
and expand to adjacent components only when the change crosses that boundary.
Do not reload the whole source tree, README, or DocC catalog for routine tasks.

- Find a symbol within its mapped directory with `rg -n 'symbol' <directory>`.
- Discover related files with `rg --files <directory>`; read bounded ranges with
  `sed -n 'start,endp' <file>` for large files.
- Ignore `.build/` and `.swiftpm/` during source exploration. They contain generated
  build/editor state. `.gitignore` also excludes Python caches and `.DS_Store`.
- Treat source and focused tests as the implementation evidence; workflows define
  CI requirements. Documentation may lag. Recheck the affected symbols before
  relying on this map, and update this file when architecture or routing changes.

## Package and architecture

`Package.swift` defines one library product/target, `Enigmatic`, and one XCTest
target, `EnigmaticTests`. There are no external package dependencies or executable
targets. Runtime code uses Swift, Foundation, CoreFoundation, and conditional Apple
`System` APIs. `Public/` and `Internal/` organize one module; Swift access modifiers
determine visibility.

The two public namespaces are:

- **`Enigma`**: a `Sendable`, `Equatable`, `Codable` enum representing a typed value
  tree. Cases retain numeric widths/signs, Bool, String, null, arrays, string-keyed
  dictionaries, native Data/Date, and wrapped Int128/UInt128. Tree paths are
  `[Enigma.Pin]`; each pin is `.str(key)` or `.int(index)` and is also a `CodingKey`.
- **`Codec`**: a namespace for representation strategies, wrappers, alternatives,
  and products. `Strategy.BoxedValue` is the user's value; `DecodeStrategy` and
  `EncodeStrategy` choose its representation. This layer works with arbitrary
  Swift encoders/decoders, including Enigma's adapters.

```text
Encodable model -> Enigma.init(encode:) -> EnigmaEncoder -> Enigma tree
Any?/Foundation object -> Enigma.init(cast:) -> Reducer + conversion helpers -> tree
tree -> subscripts / allPaths / merge -> edited tree
tree -> Enigma.decode(T.self) -> EnigmaDecoder -> Decodable model
tree -> asSwiftAny / asJsonObject / asPlistObject -> native/serialization objects
tree <-> Enigma's Codable conformances <-> external encoders/decoders

@Codec.Box<S> -> S.encode / S.decode -> the selected encoder/decoder
```

**Encoder internals:** `EnigmaEncoder` owns an arena of nodes, separate keyed and
unkeyed child tables, and parent/failure links. Container structs share this state
through `Ref(nodeId, failId)`. Writes build nodes; `materialize` constructs the final
tree iteratively in reverse allocation order once encoding succeeds. Path links
retain the original CodingKey, including both stringValue and intValue.
Incompatible container requests return a failure reference because the protocol
request cannot throw; a subsequent write throws
with the accumulated path. `Single` implements both `Encoder` and its single-value
container. `encodeSpecial` captures direct Data/Date values as native tree cases.
`Enigma.init(encode:)` returns an existing Enigma value directly instead of passing
it through the adapter.

**Decoder internals:** `EnigmaDecoder` owns userInfo and parent-linked coding paths
that retain the original CodingKey.
`Single` implements both `Decoder` and its single-value container; keyed/unkeyed
containers hold tree values and a path ID. Primitive decoding uses `Enigma.as*`
accessors; generic decoding special-cases native Data/Date, otherwise invokes
`T.init(from:)`. Unkeyed containers own their current index.

**Conversion/tree helpers:** `Internal/Enigma+Utility.swift` implements traversal,
mutation, recursive merge, Foundation casting, and JSON/plist export. `Reducer`
shares conversion path state through scoped pointers; it is noncopyable. NSNumber
casting distinguishes CFBoolean from numeric values and dispatches by ObjC type.
128-bit wrapper structs store high/low UInt64 halves so the enum itself can exist
on older Apple runtimes.

## Task-to-file and test map

In this table, `E` = `Sources/Enigmatic/Public/Enigma`,
`C` = `Sources/Enigmatic/Public/Codec`, `I` = `Sources/Enigmatic/Internal`,
and test names refer to `Tests/EnigmaticTests/<name>.swift`.

| Work area | Read/edit first | Relevant tests |
| --- | --- | --- |
| Tree cases and path keys | `E/Enigma.swift`, `E/Primitives/Enigma+Pin.swift` | `TreeContractTests`, `SerializationContractTests` |
| Paths, read/write/delete, container access | `E/Enigma+Properties.swift`, `E/Capabilities/Enigma+Modification.swift`; helpers in `I/Enigma+Utility.swift` | `TreeContractTests`, `OperationsTests` |
| Merge and resolvers | `E/Enigma+Merge.swift`; `merge` helper in `I/Enigma+Utility.swift` | `TreeContractTests`, `OperationsTests` |
| Typed accessors, model entry points, Any/JSON/plist conversion | `E/Capabilities/Enigma+Casting.swift`, `I/Enigma+Utility.swift`, `I/Primitives/Reducer.swift` | `NumericContractTests`, `SerializationContractTests`, `CodableTests` |
| Numeric equality and floating conversion | `E/Conformances/Enigma+Equatable.swift`, casting accessors, `I/Extensions/Double.swift` | `EquatableTests`, `NumericContractTests` |
| 128-bit storage and Foundation bridging | `E/Primitives/Enigma+{Int128Value,UInt128Value}.swift`, `I/Primitives/ObjCType.swift`, `I/Extensions/NSValue.swift`, utility helpers | `NumericContractTests`, `SerializationContractTests` |
| Literals and diagnostic text | `E/Conformances/Enigma+ExpressibleBy*.swift`, `Enigma+Custom{DebugString,String}Convertible.swift` in the same directory | `NumericContractTests`, `EquatableTests` |
| Model -> tree encoding; conflicts/nested/super containers | `I/EnigmaEncoder/EnigmaEncoder.swift` plus `EnigmaEncoder+{Single,Keyed,Unkeyed}.swift` | `ContainerContractTests`, `NumericContractTests`, `CodableTests`, `StrategyContractTests` |
| Tree -> model decoding; missing/type/end errors | `I/EnigmaDecoder/EnigmaDecoder.swift` plus `EnigmaDecoder+{Single,Keyed,Unkeyed}.swift` | `ContainerContractTests`, `NumericContractTests`, `CodableTests` |
| Tree's own external Codable representation | `E/Conformances/Enigma+{Encodable,Decodable}.swift` | `SerializationContractTests`, `CodableTests` |
| Strategy protocols and wrappers | `C/Codec+Strategies.swift`, `C/Codec+{Box,OptionalBox}.swift` | `StrategyContractTests` |
| Optional wrapper/key behavior | Above plus `I/Codec/Codec+{OptionalEncoder,OptionalDecoder}.swift`, `C/Strategies/Swift/Optional+Codec.swift` | `StrategyContractTests`, `DocumentationExamplesTests` |
| Array/dictionary/set/Result strategy composition | `C/Strategies/Swift/{Array,Dictionary,Set,Result}+Codec.swift` | `StrategyContractTests` |
| Alternative decoding and aggregated causes | `C/Codec+Either.swift`, `E/Primitives/Enigma+CompositeError.swift` | `StrategyContractTests`, `ProductTests` |
| Products sharing a container | `C/Codec+Each.swift`, compatibility variants `Codec+Each{2,3,4}.swift` | `StrategyContractTests`, `ProductTests` (XCTest class is **ContainersTests**) |
| Identity, Base64, URL representations | `C/Strategies/Codec+{Id,Base64Data,StringURL,PathURL}.swift` | `StrategyContractTests`, `CodableTests` |
| Dates, scale factors, truncation/overflow | `C/Strategies/Codec+{PlistDate,UnixDate,UnixIntDate}.swift`; named seconds/milliseconds variants in the same directory | `StrategyContractTests`, `CodableTests` |
| Performance | `PerformanceTests`; encoder arenas, path links, utility recursion as applicable | `PerformanceTests` in Release, without coverage |
| User/API documentation | `README.md`, `Sources/Enigmatic/Enigmatic.docc/` | `DocumentationExamplesTests`; DocC build |
| Toolchain, CI, release, coverage | `Package.swift`, `.github/workflows/{ci,release}.yml`, `Scripts/check-coverage.py` | `Scripts/tests/test_coverage.py`; CI matrix |

Test utilities: `Utility/ValueTypes.swift` supplies model fixtures;
`Utility/{Checker,Coder}.swift` exercises tree, JSON, XML/binary plist, and
Foundation serialization routes. `Utility/Parent{Keyed,Unkeyed,Value}.swift`
exercises superclass containers; `Utility/ObjectiveC.swift` supplies a Linux
autoreleasepool shim. Reuse the fixtures/helper relevant to the task.

DocC has four pages: `Enigmatic.md` is the symbol/topic index; `TreeOperations.md`,
`CodingStrategies.md`, and `Serialization.md` explain their respective domains.
`LICENSE` is Apache 2.0. There is no separate app, database, service, or deployment.

## Behaviors to preserve or verify at the boundary

- **Tree editing:** missing path is nil; stored null is `.null`. Assigning nil
  deletes a child, shifting array indices; `.null` stores a value. Empty path
  reads/replaces the root; root deletion is a no-op. Missing children can acquire
  containers, and index `count` appends. Negative/skipped indices and incompatible
  existing parents cannot be traversed. `or:` evaluates its fallback only if absent.
  `allPaths` excludes the root, includes empty containers, and traverses depth first
  with sorted dictionary keys and ascending array indices.
- **Merge:** only dictionary/dictionary pairs recurse. Other pairs reach the
  resolver as whole values with their path. `skip` keeps the existing value,
  `replace` takes incoming, `skipEqual` accepts equality, `fail` throws. Mutating
  merge assigns only after success, preserving the original on failure. Dictionary
  conflict order is unspecified.
- **Numbers (product contract):** Enigma serves intermediate encoding and untyped
  access, especially JSON. Numeric equality compares normalized shortest decimal
  representations across every numeric case, ignoring widths and equivalent
  coefficient/exponent spellings. `.float(0.1) == .double(0.1)`, but both differ
  from `.double(Double(Float(0.1)))`. Similarly `.float(1e12)` equals integer
  `1_000_000_000_000`, not its exact binary integer value `999_999_995_904`.
  Preserve reflexivity, symmetry, and transitivity in leaves and nested trees;
  `skipEqual` uses this equality and retains the existing representation.
  Do not replace this policy with exact binary equality, approximate tolerance,
  or pair-dependent rounding without an explicit product requirement.
  Equality is independent of typed conversions: integer conversions and
  integer-to-Float/Double require exact representability. Double-to-Float permits
  rounding/underflow but rejects finite overflow. NaNs compare equal, including
  Date timestamps; signed zeros compare equal. Non-finite numbers are an explicit
  extension beyond JSON. Equality does not promise equal bits or successful exact
  typed conversion, and arbitrary encoders may use different number formatting.
  External tree decoding tries all supported integer types before floating-point
  types to preserve large integers. Floating downscaling and literals must retain
  both exact binary values and decimal equality; signed zero may become integer
  zero. Same-case 128-bit equality compares stored halves without requiring native
  Int128/UInt128 availability; cross-case access needs native availability.
  Test conversion/precision with native integers and bit patterns, and semantic
  equality with independent trees, equality-law matrices, `skipEqual`, and actual
  JSONEncoder/JSONDecoder round trips. Use deterministic generated samples as well
  as boundary examples; passing legacy tests does not establish the contract.
  Adding a case affects accessors, all three adapter containers, tree Codable
  switches, conversions, equality, literals/descriptions, and tests.
- **Serialization:** `asSwiftAny` exports Swift/Foundation values. JSON export
  rejects Date, Data, non-finite numbers, and 128-bit integers; scalar JSON roots
  need `.fragmentsAllowed`. Plist export rejects null and 128-bit integers; use
  container document roots. Cast dictionary keys use their descriptions and reject
  collisions. Conversion errors retain the offending path. Diagnostic strings
  are not machine formats.
- **Date/Data:** direct model-to-tree encoding retains native cases at root and
  nested positions. Encoding an existing tree through an external encoder is a
  separate path in `Enigma+Encodable.swift`. Keeping native Date allows plist
  storage with Foundation's 2001 reference epoch; this is an intentional contract.
  Native Date/Data nodes call
  Foundation `encode(to:)` at root, array, and keyed positions. With JSONEncoder,
  this yields seconds since 2001 and byte arrays, bypassing its date/data encoding
  strategies. Apply explicit Codec strategies to model values before building
  the tree to select another wire representation.
  External tree decoding probes containers/types and downscales numbers; it does
  not promise to retain the original enum case.
  A root Enigma passed to `Enigma(encode:)` is returned directly. Enigma values
  embedded in models use their Codable conformance, so native Date/Data nodes
  become reference-date seconds/byte arrays even with the internal adapter.
- **Containers/errors:** userInfo propagates through nested/super adapters.
  Reopened containers share storage. Generic keyed writes can compose disjoint
  dictionary children or append arrays under an existing key; competing leaf
  writes and incompatible writes throw. No-output roots throw; unwritten child
  slots become empty dictionaries. Encoding is not transactional: a caught failure
  can leave a reserved array element or partially written child in the output.
  Missing keyed `decodeNil` throws `keyNotFound`. Decoding a null primitive throws
  `valueNotFound`; incompatible non-null values throw `typeMismatch`. These correct
  the former missing-key false return and null typeMismatch behavior.
  Super decoders intentionally accept null for nullable scalar superclass values;
  a successful unkeyed superDecoder advances even when its value is null.
  Failed unkeyed decodes leave the index unchanged; `decodeNil` advances only for
  null. End errors identify the container, type mismatches the element. Preserve
  error kinds, coding paths, and underlying causes; message text is diagnostic.
  Materialization and conflict diagnostics do not recursively traverse the arena;
  consumer Codable implementations and other tree operations can still recurse.
- **Strategies:** `Either<Right, Left>` tries Right first, retaining both failures
  in `CompositeError`. `Each`/Each2/3/4 share one input/output, rather than encode a
  tuple array; competing leaf writes conflict, but disjoint children can share a
  container key. Sets deduplicate with unspecified encoded order.
  `Result<S, any Error>` captures decode errors; encoding a failure
  throws with its cause. Optional strategies distinguish a whole optional value
  from its present payload via `OptionalBox`; missing/null/omitted keyed behavior
  differs by access context. The keyed overloads in `I/Codec` and their helper
  protocols are internal: `@testable import Enigmatic` models can omit nil keys
  and decode missing keys as nil. Consumer models using `import Enigmatic` encode
  nil as null, decode explicit null as nil, and throw `keyNotFound` for missing
  keys. `StrategyContractTests` exercises the internal behavior;
  `DocumentationExamplesTests` exercises the public behavior. Verify consumer
  synthesis when changing access control or these overloads.
- **Dates/platforms:** PlistDate uses the 2001 Foundation epoch; Unix strategies
  use 1970. Scaled variants use `10^scale`; integer variants truncate toward zero.
  Retain finite/scale/overflow checks and Apple/Linux conditional branches.

## Toolchain and verification

Swift tools **6.3+**; CI pins **6.3.3** on macOS 26 and Ubuntu 24.04, Debug and
Release. The manifest enables experimental `AnyAppleOSAvailability` for compilers
below 6.4. It declares no raised package deployment target. Individual APIs gate
`Each` at macOS 14/iOS 17/tvOS 17/watchOS 10, native 128-bit access at macOS 15/
iOS 18/tvOS 18/watchOS 11/visionOS 2, and generic scaled Unix dates at Apple OS 26.
Fixed-arity Each and named Unix date strategies remain compatibility APIs.
Each2/3/4 are deprecated on Apple platforms where Each is available; the named
Unix strategies are deprecated on Apple OS 26.

Use the mapped XCTest **class** for a focused check, then the functional suite for
runtime changes. A documentation-only map update needs path/symbol validation;
running benchmarks or the runtime suite adds no verification of prose.

```sh
swift test --filter TreeContractTests                  # substitute mapped class
swift test --skip PerformanceTests
swift test -c release --skip PerformanceTests
python3 -m unittest discover -s Scripts/tests          # coverage script changes
swift test --enable-code-coverage --skip PerformanceTests
python3 Scripts/check-coverage.py "$(swift test --show-codecov-path)" --minimum 100
swift test -c release --filter PerformanceTests        # performance work only
```

CI and tag releases enforce **100% executable line coverage** under
`Sources/Enigmatic`; the script's default is 90%, so pass `--minimum 100` explicitly.
Coverage excludes test sources and fails on an empty library report. Manual CI runs
benchmarks separately and uploads timings; there is no timing threshold. Tag
pushes matching `v*` validate the matrix and then create a GitHub release.

For API/DocC changes, use the macOS documentation commands from
`.github/workflows/ci.yml`: `swift package dump-symbol-graph` followed by
`xcrun docc convert` with the symbolgraph directory and `--warnings-as-errors`.

## Remaining documentation cautions

The README uses the current API and consumer behavior. The DocC catalog still
describes public optional wrappers using outdated behavior. Current accessors are
`allPaths`, `asSwiftAny`, `asJsonObject`,
and `asPlistObject`; there is no public `rawObject` accessor.

Source comments on `Codec.Box` also describe internal optional-key behavior as
though it were public. Check access modifiers and consumer tests before relying
on these comments or DocC. These discrepancies are documentation issues, not
instructions to change runtime behavior.
