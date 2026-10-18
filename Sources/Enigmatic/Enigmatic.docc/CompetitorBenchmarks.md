# Competitor benchmarks

Generated: 2026-10-18T11:31:02Z. This is a measured snapshot, not a general ranking.

- Toolchain: `swift-driver version: 1.148.6 Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101); Target: arm64-apple-macosx26.0`
- Machine: `Darwin 25.6.0 arm64; logical CPUs: 16; RAM bytes: 68719476736`
- Enigmatic revision: `v2.0.1-7-g80e4245-dirty` (local working tree is used).
- Build: Release, no coverage; 25 samples, 900 identical records per payload.
- Common fixture: 956633 compact Foundation JSON bytes; strings, Bool, Int, Double,
  arrays, dictionaries, and Optional fields. Special values are isolated in contract probes.

## Dependencies

Latest stable versions selected when this project was created; prereleases excluded.
`Benchmarks/Package.resolved` pins transitive revisions. Update exact versions deliberately before rerunning.
| Package | anycodable | bettercodable | bigint | codablewrappers | float16 | metacodable | pmjson | potentcodables | regex | swift-argument-parser | swift-atomics | swift-collections | swift-json | swift-nio | swift-numerics | swift-syntax | swift-system | swiftyjson |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Version | 0.6.7 | 0.4.0 | 5.7.0 | 3.1.0 | 1.1.1 | 1.6.1 | 4.0.0 | 3.5.3 | 2.1.1 | 1.8.2 | 1.3.1 | 1.7.3 | 2.5.4 | 2.104.0 | 1.1.1 | 600.0.1 | 1.8.1 | 5.0.2 |

## Feature matrix

One column per library, combining its benchmark paths. **API** cells describe capabilities
inspected in the pinned source/documentation linked in the headers; these are not benchmark assertions.
**PASS / PARTIAL / FAIL / REJECTED** cells are computed from the saved probes below.
PARTIAL means only some probes in that cell pass. **Not probed** means this harness has no
applicable result, not that the library lacks the feature. A rejected default JSON infinity is expected.
Layout means serialized key names, nesting/flattening and field representations, not Swift memory layout.
Manual means custom Codable code or explicit tree edits, rather than a dedicated built-in feature.
| Feature | [Foundation](https://developer.apple.com/documentation/foundation/jsonencoder) | [Enigmatic](https://github.com/SwiftUtility/Enigmatic) | [PotentCodables](https://github.com/outfoxx/PotentCodables/tree/3.5.3) | [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON/tree/5.0.2) | [PMJSON](https://github.com/postmates/PMJSON/tree/v4.0.0) | [AnyCodable](https://github.com/Flight-School/AnyCodable/tree/0.6.7) | [swift-json](https://github.com/orlandos-nl/swift-json/tree/2.5.4) | [CodableWrappers](https://github.com/GottaGetSwifty/CodableWrappers/tree/3.1.0) | [BetterCodable](https://github.com/marksands/BetterCodable/tree/0.4.0) | [MetaCodable](https://github.com/SwiftyLab/MetaCodable/tree/v1.6.1) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Own byte parser/writer (API) | JSON, plist | JSON | JSON, YAML, CBOR, ASN.1 | No; Foundation | JSON | No; external coder | JSON | No; external coder | No; external coder | No; generated Codable |
| Dynamic value tree (API) | Any objects | Enigma | AnyValue / format trees | JSON | JSON | Type-erased AnyCodable | JSONObject / JSONArray | No | No | No dedicated tree |
| Direct model ↔ tree without bytes (API) | No generic model bridge | Encoder + decoder | AnyValue / format coders | Needs model bridge | JSON coders | No generic model decoder | Object/array coders | Uses external coder | Uses external coder | Generates model Codable |
| Foundation Codable interoperability (API) | Built in | Codable tree | Codable AnyValue; see measured limits | Uses Foundation model bridge | Codable JSON value | Codable wrappers | Uses own model coders | Codable property wrappers | Codable property wrappers | Generated Codable |
| Foundation object interoperability (API) | JSON / plist objects | init(cast:), asJsonObject, asPlistObject | AnyValue.wrapped / unwrapped | Object initializer / object | init(ns:) / ns | Any-backed values; manual bridge | Use explicit adapter | Model layer; external bridge | Model layer; external bridge | Model layer; external bridge |
| Key renaming (API) | CodingKeys / key strategies | CodingKeys / tree edits | Key strategies / CodingKeys | Tree edits | Key strategies / CodingKeys | Consumer model CodingKeys | Key strategies / CodingKeys | Coding-key macros | Consumer model CodingKeys | CodedAt / CodingKeys macros |
| Nesting / flattening layout (API) | Manual Codable | Codec.Each composition / tree edits | Manual Codable / tree edits | Tree edits | Manual Codable / tree edits | Manual consumer Codable | Manual Codable / object edits | Manual Codable beyond key macros | Manual consumer Codable | CodedAt / CodedIn / composition |
| Per-property representations (API) | Manual Codable; global coder strategies | Composable Codec strategies | Manual Codable; coder strategies | Manual tree edits | Manual Codable; coder strategies | Manual consumer Codable | Manual Codable; coder strategies | Static coders / wrappers | DateValue / LosslessValue | HelperCoder / CodedBy |
| Ready-made defaults / lossy collections (API) | Manual | Custom strategies | Custom Codable | Defaulting getters; not model wrappers | Manual Codable | Manual consumer Codable | Manual Codable | Fallback / lossy wrappers | Default / lossy wrappers | Default / LossySequenceCoder |
| Tree editing / merge (API) | Manual collections | Path mutation / merge policies | Value-tree APIs; manual composition | Subscripts / merge / merged | Mutable JSON; manual composition | Any-backed edits; manual composition | Mutable objects/arrays | Not a tree library | Not a tree library | Not a tree library |
| Macros in library API (API) | No | No | No | No | No | No | No | Key macros + runtime wrappers | No | Codable generation macros |
| Foundation JSON Codable: basic probes | PASS | PASS | REJECTED | PASS | Not probed | PASS | Not probed | PASS | PASS | PASS |
| Foundation plist Codable: basic probes (XML + binary) | PASS | PASS | REJECTED | Not probed | Not probed | PASS | Not probed | PASS | PASS | PASS |
| JSONSerialization bridge: basic probes | PASS | PASS | Not probed | PASS | Not probed | Not probed | Not probed | Not probed | Not probed | Not probed |
| PropertyListSerialization bridge: basic probes (XML + binary) | PASS | PARTIAL (8/10) | Not probed | Not probed | Not probed | Not probed | Not probed | Not probed | Not probed | Not probed |
| Native plist Data type (XML + binary) | Codable: PASS; Serialization: PASS | Codable: FAIL; Serialization: PASS | FAIL | Not probed | Not probed | REJECTED | Not probed | PASS | PASS | PASS |
| Native plist Date type (XML + binary) | Codable: PASS; Serialization: PASS | Codable: FAIL; Serialization: PASS | FAIL | Not probed | Not probed | REJECTED | Not probed | PASS | PASS | PASS |
| Exact native Date roundtrip: binary plist | PASS | PASS | REJECTED | Not probed | Not probed | REJECTED | Not probed | PASS | PASS | PASS |
| Exact native Date roundtrip: XML plist (.125 s fraction) | FAIL | FAIL | REJECTED | Not probed | Not probed | REJECTED | Not probed | FAIL | FAIL | FAIL |
| Native Swift Int128 / UInt128 JSON roundtrip | PASS | PASS | REJECTED | PASS | REJECTED | REJECTED | REJECTED | PASS | PASS | PASS |
| Non-finite Float / Double: default JSON | REJECTED | REJECTED | REJECTED | REJECTED | REJECTED | REJECTED | REJECTED | REJECTED | REJECTED | REJECTED |
| Non-finite Float / Double: binary plist | PASS | PASS | REJECTED | Not probed | Not probed | PASS | Not probed | PASS | PASS | PASS |
| Synthesized Optional nil keeps a JSON null key | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL |
| Explicit encode(Optional.nil) keeps a JSON null key | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Configured library null wrapper (tested adapters) | Not probed | PASS | Not probed | Not probed | Not probed | Not probed | Not probed | PASS | Not probed | Not probed |

Basic probes cover String, Bool, Int32, nested collections and Optional elements; they do not
imply support for every numeric/native type. Wrapper/macro scalar results inherit Foundation behavior.
SwiftyJSON's JSON bridge includes Foundation model coding and JSONSerialization inside SwiftyJSON;
PMJSON's ns bridge and PotentCodables' wrapped/unwrapped bridge are API-listed but not probed here.
Native plist cells show Codable and Serialization separately where both adapters exist.
Exact Date rows choose the Serialization adapter when available, otherwise the Codable adapter.
JSON numeric/null rows use each library's JSON adapter (Enigmatic Codec, PotentJSON, or the named
Foundation-backed wrapper adapter). A Not probed libraryNull cell does not rule out a custom coder.
The tables below identify every individual path and case behind these summaries.

## Interpretation

✅ probe requirements met (exact typed model roundtrip except the two type-only probes);
❌ changed value, missing null key, or non-native plist storage;
⚠️ encoder/decoder rejected the input; 💥 isolated process failed; ⏱ timeout;
— no implemented path or case is not applicable. A rejection of NaN/infinity in default JSON
is expected standards-compliant behavior, not necessarily a library defect.
For finite floating-point values, signed zero and bit patterns are checked; NaN is compared by isNaN.
Integer cases contain minimum/maximum values, with Int64/UInt64 also checking values beyond 2^53.
Int128/UInt128 and Float16 mean the native Swift types, not third-party BigInt or Float16 wrappers.
These are enumerated contract probes, not an exhaustive proof for all possible values.

A typed roundtrip does not imply identical wire representations or compatibility with Foundation default Date/Data policies.
Every serialized check is model → bytes → model. The plist nativeData/nativeDate rows also inspect
the actual PropertyListSerialization result for Data/Date rather than accepting strings or numbers.
plistDataType/plistDateType check only the stored type, independently of roundtrip correctness.
The Date sample has a .125-second fraction, so XML date precision loss remains visible even when
plistDateType passes.
defaultNull tests synthesized Optional nil (omitting a key fails this *presence* requirement);
explicitNull uses an explicit encode of Optional nil; libraryNull uses Enigmatic Nullable or CodableWrappers EncodeNulls.
This distinguishes representation policy from loss of an Optional value.

Foundation Codable means JSONEncoder/Decoder or PropertyListEncoder/Decoder.
Foundation Serialization uses JSONSerialization or PropertyListSerialization *after* the Foundation Codable bridge.
Enigmatic Serialization uses its direct object bridge. Enigmatic Codec uses its own JSON parser/writer.
SwiftyJSON and AnyCodable need Foundation Codable bridges to move between a typed model and their values;
these costs are included. Potent AnyValue uses AnyValueEncoder/Decoder and Foundation for bytes.
The AnyValue + Foundation Codable path can fail the common object-shaped fixture because AnyValue
dictionary Codable representation uses non-String dictionary keys; this does not imply failure of PotentJSON.
JSON-only libraries have no plist adapter and are marked —, rather than measured through an unrelated fallback.

CodableWrappers, BetterCodable, and MetaCodable are model-layer tools, not serializers.
Generic scalar probes in these columns inherit Foundation behavior. Performance uses matching records:
CodableWrappers Immutable on id, BetterCodable LosslessValue on id, and MetaCodable-generated Codable.
Other columns use synthesized Codable. All records have identical values and serialized structure.

## Roundtrips
### In-memory model → tree → model

| Data type / case | Foundation Codable | Foundation Codable + Serialization | Enigmatic + Foundation Codable | Enigmatic Codec JSON | Enigmatic + Foundation Serialization | PotentCodables AnyValue + Foundation | PotentJSON | SwiftyJSON + Foundation Codable | PMJSON | AnyCodable + Foundation Codable | swift-json (IkigaJSON) | CodableWrappers + Foundation | BetterCodable + Foundation | MetaCodable + Foundation |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| string | — | — | ✅ | — | — | ✅ | ✅ | — | ✅ | — | — | — | — | — |
| bool | — | — | ✅ | — | — | ✅ | ✅ | — | ✅ | — | — | — | — | — |
| int | — | — | ✅ | — | — | ✅ | ✅ | — | ✅ | — | — | — | — | — |
| int8 | — | — | ✅ | — | — | ✅ | ✅ | — | ✅ | — | — | — | — | — |
| int16 | — | — | ✅ | — | — | ✅ | ✅ | — | ✅ | — | — | — | — | — |
| int32 | — | — | ✅ | — | — | ✅ | ✅ | — | ✅ | — | — | — | — | — |
| int64 | — | — | ✅ | — | — | ✅ | ✅ | — | ✅ | — | — | — | — | — |
| uint | — | — | ✅ | — | — | ✅ | ✅ | — | ⚠️ | — | — | — | — | — |
| uint8 | — | — | ✅ | — | — | ✅ | ✅ | — | ✅ | — | — | — | — | — |
| uint16 | — | — | ✅ | — | — | ✅ | ✅ | — | ✅ | — | — | — | — | — |
| uint32 | — | — | ✅ | — | — | ✅ | ✅ | — | ✅ | — | — | — | — | — |
| uint64 | — | — | ✅ | — | — | ✅ | ✅ | — | ⚠️ | — | — | — | — | — |
| int128 | — | — | ✅ | — | — | ⚠️ | ⚠️ | — | ⚠️ | — | — | — | — | — |
| uint128 | — | — | ✅ | — | — | ⚠️ | ⚠️ | — | ⚠️ | — | — | — | — | — |
| float16 | — | — | ✅ | — | — | ✅ | ✅ | — | ✅ | — | — | — | — | — |
| float | — | — | ✅ | — | — | ✅ | ✅ | — | ✅ | — | — | — | — | — |
| double | — | — | ✅ | — | — | ✅ | ✅ | — | ✅ | — | — | — | — | — |
| floatInfinity | — | — | ✅ | — | — | ✅ | ⚠️ | — | ✅ | — | — | — | — | — |
| doubleInfinity | — | — | ✅ | — | — | ✅ | ⚠️ | — | ✅ | — | — | — | — | — |
| floatNaN | — | — | ✅ | — | — | ⚠️ | ⚠️ | — | ✅ | — | — | — | — | — |
| doubleNaN | — | — | ✅ | — | — | ⚠️ | ⚠️ | — | ✅ | — | — | — | — | — |
| decimal | — | — | ✅ | — | — | ✅ | ✅ | — | ✅ | — | — | — | — | — |
| cgFloat | — | — | ✅ | — | — | ✅ | ✅ | — | ✅ | — | — | — | — | — |
| data | — | — | ✅ | — | — | ✅ | ✅ | — | ✅ | — | — | — | — | — |
| date | — | — | ✅ | — | — | ✅ | ✅ | — | ✅ | — | — | — | — | — |
| url | — | — | ✅ | — | — | ✅ | ✅ | — | ✅ | — | — | — | — | — |
| uuid | — | — | ✅ | — | — | ✅ | ✅ | — | ✅ | — | — | — | — | — |
| nested | — | — | ✅ | — | — | ✅ | ✅ | — | ✅ | — | — | — | — | — |
| optional | — | — | ✅ | — | — | ✅ | ✅ | — | ✅ | — | — | — | — | — |
| explicitNull | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| defaultNull | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| libraryNull | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| nativeData | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| nativeDate | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| plistDataType | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| plistDateType | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| scalarRoot | — | — | ✅ | — | — | ✅ | ✅ | — | ✅ | — | — | — | — | — |
| arrayRoot | — | — | ✅ | — | — | ✅ | ✅ | — | ✅ | — | — | — | — | — |
| nullRoot | — | — | ✅ | — | — | ⚠️ | ⚠️ | — | ✅ | — | — | — | — | — |

### JSON (default policies)

| Data type / case | Foundation Codable | Foundation Codable + Serialization | Enigmatic + Foundation Codable | Enigmatic Codec JSON | Enigmatic + Foundation Serialization | PotentCodables AnyValue + Foundation | PotentJSON | SwiftyJSON + Foundation Codable | PMJSON | AnyCodable + Foundation Codable | swift-json (IkigaJSON) | CodableWrappers + Foundation | BetterCodable + Foundation | MetaCodable + Foundation |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| string | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ⚠️ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| bool | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| int | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ | ✅ |
| int8 | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| int16 | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| int32 | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| int64 | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ | ✅ |
| uint | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ | ⚠️ | ✅ | ⚠️ | ✅ | ✅ | ✅ |
| uint8 | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| uint16 | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| uint32 | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| uint64 | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ | ⚠️ | ✅ | ⚠️ | ✅ | ✅ | ✅ |
| int128 | ✅ | ✅ | ✅ | ✅ | ⚠️ | ⚠️ | ⚠️ | ✅ | ⚠️ | ⚠️ | ⚠️ | ✅ | ✅ | ✅ |
| uint128 | ✅ | ✅ | ✅ | ✅ | ⚠️ | ⚠️ | ⚠️ | ✅ | ⚠️ | ⚠️ | ⚠️ | ✅ | ✅ | ✅ |
| float16 | ✅ | ❌ | ❌ | ✅ | ❌ | ⚠️ | ✅ | ❌ | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ |
| float | ✅ | ❌ | ❌ | ✅ | ❌ | ⚠️ | ✅ | ❌ | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ |
| double | ✅ | ❌ | ❌ | ✅ | ❌ | ⚠️ | ✅ | ❌ | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ |
| floatInfinity | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ |
| doubleInfinity | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ |
| floatNaN | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ |
| doubleNaN | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ |
| decimal | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ | ⚠️ | ❌ | ❌ | ✅ | ✅ | ✅ |
| cgFloat | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| data | ✅ | ✅ | ✅ | ⚠️ | ⚠️ | ⚠️ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| date | ✅ | ✅ | ✅ | ⚠️ | ⚠️ | ⚠️ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| url | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| uuid | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| nested | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| optional | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| explicitNull | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| defaultNull | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| libraryNull | — | — | ✅ | ✅ | ✅ | — | — | — | — | — | — | ✅ | — | — |
| nativeData | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| nativeDate | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| plistDataType | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| plistDateType | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| scalarRoot | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| arrayRoot | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| nullRoot | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ⚠️ | ⚠️ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

### JSON (non-finite numbers as strings)

| Data type / case | Foundation Codable | Foundation Codable + Serialization | Enigmatic + Foundation Codable | Enigmatic Codec JSON | Enigmatic + Foundation Serialization | PotentCodables AnyValue + Foundation | PotentJSON | SwiftyJSON + Foundation Codable | PMJSON | AnyCodable + Foundation Codable | swift-json (IkigaJSON) | CodableWrappers + Foundation | BetterCodable + Foundation | MetaCodable + Foundation |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| string | ✅ | — | ✅ | — | — | ⚠️ | ⚠️ | — | — | ✅ | — | ✅ | ✅ | ✅ |
| bool | ✅ | — | ✅ | — | — | ⚠️ | ✅ | — | — | ✅ | — | ✅ | ✅ | ✅ |
| int | ✅ | — | ✅ | — | — | ⚠️ | ✅ | — | — | ✅ | — | ✅ | ✅ | ✅ |
| int8 | ✅ | — | ✅ | — | — | ⚠️ | ✅ | — | — | ✅ | — | ✅ | ✅ | ✅ |
| int16 | ✅ | — | ✅ | — | — | ⚠️ | ✅ | — | — | ✅ | — | ✅ | ✅ | ✅ |
| int32 | ✅ | — | ✅ | — | — | ⚠️ | ✅ | — | — | ✅ | — | ✅ | ✅ | ✅ |
| int64 | ✅ | — | ✅ | — | — | ⚠️ | ✅ | — | — | ✅ | — | ✅ | ✅ | ✅ |
| uint | ✅ | — | ✅ | — | — | ⚠️ | ✅ | — | — | ✅ | — | ✅ | ✅ | ✅ |
| uint8 | ✅ | — | ✅ | — | — | ⚠️ | ✅ | — | — | ✅ | — | ✅ | ✅ | ✅ |
| uint16 | ✅ | — | ✅ | — | — | ⚠️ | ✅ | — | — | ✅ | — | ✅ | ✅ | ✅ |
| uint32 | ✅ | — | ✅ | — | — | ⚠️ | ✅ | — | — | ✅ | — | ✅ | ✅ | ✅ |
| uint64 | ✅ | — | ✅ | — | — | ⚠️ | ✅ | — | — | ✅ | — | ✅ | ✅ | ✅ |
| int128 | ✅ | — | ✅ | — | — | ⚠️ | ⚠️ | — | — | ⚠️ | — | ✅ | ✅ | ✅ |
| uint128 | ✅ | — | ✅ | — | — | ⚠️ | ⚠️ | — | — | ⚠️ | — | ✅ | ✅ | ✅ |
| float16 | ✅ | — | ❌ | — | — | ⚠️ | ✅ | — | — | ❌ | — | ✅ | ✅ | ✅ |
| float | ✅ | — | ❌ | — | — | ⚠️ | ✅ | — | — | ❌ | — | ✅ | ✅ | ✅ |
| double | ✅ | — | ❌ | — | — | ⚠️ | ✅ | — | — | ❌ | — | ✅ | ✅ | ✅ |
| floatInfinity | ✅ | — | ✅ | — | — | ⚠️ | ✅ | — | — | ✅ | — | ✅ | ✅ | ✅ |
| doubleInfinity | ✅ | — | ✅ | — | — | ⚠️ | ✅ | — | — | ✅ | — | ✅ | ✅ | ✅ |
| floatNaN | ✅ | — | ✅ | — | — | ⚠️ | ✅ | — | — | ✅ | — | ✅ | ✅ | ✅ |
| doubleNaN | ✅ | — | ✅ | — | — | ⚠️ | ✅ | — | — | ✅ | — | ✅ | ✅ | ✅ |
| decimal | ✅ | — | ✅ | — | — | ⚠️ | ✅ | — | — | ❌ | — | ✅ | ✅ | ✅ |
| cgFloat | ✅ | — | ✅ | — | — | ⚠️ | ✅ | — | — | ✅ | — | ✅ | ✅ | ✅ |
| data | ✅ | — | ✅ | — | — | ⚠️ | ✅ | — | — | ✅ | — | ✅ | ✅ | ✅ |
| date | ✅ | — | ✅ | — | — | ⚠️ | ✅ | — | — | ✅ | — | ✅ | ✅ | ✅ |
| url | ✅ | — | ✅ | — | — | ⚠️ | ✅ | — | — | ✅ | — | ✅ | ✅ | ✅ |
| uuid | ✅ | — | ✅ | — | — | ⚠️ | ✅ | — | — | ✅ | — | ✅ | ✅ | ✅ |
| nested | ✅ | — | ✅ | — | — | ⚠️ | ✅ | — | — | ✅ | — | ✅ | ✅ | ✅ |
| optional | ✅ | — | ✅ | — | — | ⚠️ | ✅ | — | — | ✅ | — | ✅ | ✅ | ✅ |
| explicitNull | ✅ | — | ✅ | — | — | ❌ | ✅ | — | — | ✅ | — | ✅ | ✅ | ✅ |
| defaultNull | ❌ | — | ❌ | — | — | ❌ | ❌ | — | — | ❌ | — | ❌ | ❌ | ❌ |
| libraryNull | — | — | ✅ | — | — | — | — | — | — | — | — | ✅ | — | — |
| nativeData | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| nativeDate | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| plistDataType | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| plistDateType | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| scalarRoot | ✅ | — | ✅ | — | — | ✅ | ✅ | — | — | ✅ | — | ✅ | ✅ | ✅ |
| arrayRoot | ✅ | — | ✅ | — | — | ✅ | ✅ | — | — | ✅ | — | ✅ | ✅ | ✅ |
| nullRoot | ✅ | — | ✅ | — | — | ⚠️ | ⚠️ | — | — | ✅ | — | ✅ | ✅ | ✅ |

### XML plist

| Data type / case | Foundation Codable | Foundation Codable + Serialization | Enigmatic + Foundation Codable | Enigmatic Codec JSON | Enigmatic + Foundation Serialization | PotentCodables AnyValue + Foundation | PotentJSON | SwiftyJSON + Foundation Codable | PMJSON | AnyCodable + Foundation Codable | swift-json (IkigaJSON) | CodableWrappers + Foundation | BetterCodable + Foundation | MetaCodable + Foundation |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| string | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| bool | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| int | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| int8 | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| int16 | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| int32 | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| int64 | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| uint | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| uint8 | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| uint16 | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| uint32 | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| uint64 | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| int128 | ⚠️ | ⚠️ | ⚠️ | — | ⚠️ | ⚠️ | — | — | — | ⚠️ | — | ⚠️ | ⚠️ | ⚠️ |
| uint128 | ⚠️ | ⚠️ | ⚠️ | — | ⚠️ | ⚠️ | — | — | — | ⚠️ | — | ⚠️ | ⚠️ | ⚠️ |
| float16 | ✅ | ❌ | ❌ | — | ❌ | ⚠️ | — | — | — | ❌ | — | ✅ | ✅ | ✅ |
| float | ✅ | ❌ | ❌ | — | ❌ | ⚠️ | — | — | — | ❌ | — | ✅ | ✅ | ✅ |
| double | ✅ | ❌ | ❌ | — | ❌ | ⚠️ | — | — | — | ❌ | — | ✅ | ✅ | ✅ |
| floatInfinity | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| doubleInfinity | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| floatNaN | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| doubleNaN | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| decimal | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| cgFloat | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| data | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ⚠️ | — | ✅ | ✅ | ✅ |
| date | ❌ | ❌ | ✅ | — | ❌ | ⚠️ | — | — | — | ⚠️ | — | ❌ | ❌ | ❌ |
| url | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| uuid | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| nested | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| optional | ✅ | ✅ | ✅ | — | ⚠️ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| explicitNull | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| defaultNull | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| libraryNull | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| nativeData | ✅ | ✅ | ❌ | — | ✅ | ⚠️ | — | — | — | ⚠️ | — | ✅ | ✅ | ✅ |
| nativeDate | ❌ | ❌ | ❌ | — | ❌ | ⚠️ | — | — | — | ⚠️ | — | ❌ | ❌ | ❌ |
| plistDataType | ✅ | ✅ | ❌ | — | ✅ | ❌ | — | — | — | ⚠️ | — | ✅ | ✅ | ✅ |
| plistDateType | ✅ | ✅ | ❌ | — | ✅ | ❌ | — | — | — | ⚠️ | — | ✅ | ✅ | ✅ |
| scalarRoot | ⚠️ | ⚠️ | ⚠️ | — | ✅ | ⚠️ | — | — | — | ⚠️ | — | ⚠️ | ⚠️ | ⚠️ |
| arrayRoot | ✅ | ✅ | ✅ | — | ✅ | ✅ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| nullRoot | ⚠️ | ⚠️ | ⚠️ | — | ⚠️ | ⚠️ | — | — | — | ⚠️ | — | ⚠️ | ⚠️ | ⚠️ |

### Binary plist

| Data type / case | Foundation Codable | Foundation Codable + Serialization | Enigmatic + Foundation Codable | Enigmatic Codec JSON | Enigmatic + Foundation Serialization | PotentCodables AnyValue + Foundation | PotentJSON | SwiftyJSON + Foundation Codable | PMJSON | AnyCodable + Foundation Codable | swift-json (IkigaJSON) | CodableWrappers + Foundation | BetterCodable + Foundation | MetaCodable + Foundation |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| string | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| bool | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| int | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| int8 | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| int16 | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| int32 | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| int64 | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| uint | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| uint8 | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| uint16 | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| uint32 | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| uint64 | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| int128 | ⚠️ | ⚠️ | ⚠️ | — | ⚠️ | ⚠️ | — | — | — | ⚠️ | — | ⚠️ | ⚠️ | ⚠️ |
| uint128 | ⚠️ | ⚠️ | ⚠️ | — | ⚠️ | ⚠️ | — | — | — | ⚠️ | — | ⚠️ | ⚠️ | ⚠️ |
| float16 | ✅ | ✅ | ❌ | — | ✅ | ⚠️ | — | — | — | ❌ | — | ✅ | ✅ | ✅ |
| float | ✅ | ✅ | ❌ | — | ✅ | ⚠️ | — | — | — | ❌ | — | ✅ | ✅ | ✅ |
| double | ✅ | ✅ | ❌ | — | ✅ | ⚠️ | — | — | — | ❌ | — | ✅ | ✅ | ✅ |
| floatInfinity | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| doubleInfinity | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| floatNaN | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| doubleNaN | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| decimal | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| cgFloat | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| data | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ⚠️ | — | ✅ | ✅ | ✅ |
| date | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ⚠️ | — | ✅ | ✅ | ✅ |
| url | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| uuid | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| nested | ✅ | ✅ | ✅ | — | ✅ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| optional | ✅ | ✅ | ✅ | — | ⚠️ | ⚠️ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| explicitNull | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| defaultNull | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| libraryNull | — | — | — | — | — | — | — | — | — | — | — | — | — | — |
| nativeData | ✅ | ✅ | ❌ | — | ✅ | ⚠️ | — | — | — | ⚠️ | — | ✅ | ✅ | ✅ |
| nativeDate | ✅ | ✅ | ❌ | — | ✅ | ⚠️ | — | — | — | ⚠️ | — | ✅ | ✅ | ✅ |
| plistDataType | ✅ | ✅ | ❌ | — | ✅ | ❌ | — | — | — | ⚠️ | — | ✅ | ✅ | ✅ |
| plistDateType | ✅ | ✅ | ❌ | — | ✅ | ❌ | — | — | — | ⚠️ | — | ✅ | ✅ | ✅ |
| scalarRoot | ⚠️ | ⚠️ | ⚠️ | — | ✅ | ⚠️ | — | — | — | ⚠️ | — | ⚠️ | ⚠️ | ⚠️ |
| arrayRoot | ✅ | ✅ | ✅ | — | ✅ | ✅ | — | — | — | ✅ | — | ✅ | ✅ | ✅ |
| nullRoot | ⚠️ | ⚠️ | ⚠️ | — | ⚠️ | ⚠️ | — | — | — | ⚠️ | — | ⚠️ | ⚠️ | ⚠️ |

## Performance

Each operation is measured separately, after validation and warm-up. Execution order rotates per sample.
Decode inputs are the exact same Foundation-produced bytes for every library in a format.
Model/encoder/tree creation required by a path stays inside its measurement; fixture setup and correctness
comparisons stay outside. Encoder and decoder instances are created per operation for every path.
The roundtrip is timed as one operation; its median is not the sum of stage medians.

For paired sample i, rᵢ = library timeᵢ / Foundation Codable timeᵢ.
E[r] = Σrᵢ/n; Var[r] = Σ(rᵢ − E[r])²/n (population variance of observed ratios, dimensionless).
Time % = 100 × E[r]; lower is faster. Factor = E[r]× slower or 1/E[r]× faster.
E[r] is not the ratio of medians. Variance describes this run's dispersion, not a confidence interval.
Raw times and detailed check outcomes are saved beside this report as `CompetitorBenchmarks.json`.
### JSON (default policies): model → Data

| Metric | Foundation Codable | Foundation Codable + Serialization | Enigmatic + Foundation Codable | Enigmatic Codec JSON | Enigmatic + Foundation Serialization | PotentCodables AnyValue + Foundation | PotentJSON | SwiftyJSON + Foundation Codable | PMJSON | AnyCodable + Foundation Codable | swift-json (IkigaJSON) | CodableWrappers + Foundation | BetterCodable + Foundation | MetaCodable + Foundation |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Median ms/op | 8.606708 | 15.290625 | 15.469667 | 25.956417 | 20.176333 | — | 44.624458 | 32.302375 | 12.021666 | 86.254584 | 8.748667 | 8.780250 | 8.872375 | 8.614291 |
| Time % | 100.000% | 177.619% | 179.949% | 304.071% | 234.546% | — | 519.909% | 376.442% | 140.144% | 1004.878% | 101.754% | 102.138% | 103.258% | 100.334% |
| E[r] | 1.000000 | 1.776192 | 1.799495 | 3.040715 | 2.345460 | — | 5.199090 | 3.764424 | 1.401440 | 10.048775 | 1.017543 | 1.021376 | 1.032584 | 1.003345 |
| Var[r] | 0.000000000 | 0.000346142 | 0.000651648 | 0.003045406 | 0.001040697 | — | 0.004403488 | 0.002771886 | 0.000343874 | 0.010613687 | 0.000093893 | 0.000108411 | 0.000099381 | 0.000021112 |
| Factor | baseline | 1.776x slower | 1.799x slower | 3.041x slower | 2.345x slower | — | 5.199x slower | 3.764x slower | 1.401x slower | 10.049x slower | 1.018x slower | 1.021x slower | 1.033x slower | 1.003x slower |

### JSON (default policies): Data → model

| Metric | Foundation Codable | Foundation Codable + Serialization | Enigmatic + Foundation Codable | Enigmatic Codec JSON | Enigmatic + Foundation Serialization | PotentCodables AnyValue + Foundation | PotentJSON | SwiftyJSON + Foundation Codable | PMJSON | AnyCodable + Foundation Codable | swift-json (IkigaJSON) | CodableWrappers + Foundation | BetterCodable + Foundation | MetaCodable + Foundation |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Median ms/op | 11.045208 | 17.805833 | 87.991708 | 11.567041 | 18.092666 | — | 31.560000 | 34.956708 | 20.153959 | 88.996542 | 15.878542 | 11.208958 | 11.201583 | 11.075417 |
| Time % | 100.000% | 161.077% | 796.293% | 104.984% | 163.849% | — | 284.941% | 316.006% | 182.399% | 804.089% | 144.494% | 101.049% | 101.211% | 99.893% |
| E[r] | 1.000000 | 1.610766 | 7.962932 | 1.049844 | 1.638490 | — | 2.849406 | 3.160061 | 1.823992 | 8.040888 | 1.444938 | 1.010489 | 1.012110 | 0.998929 |
| Var[r] | 0.000000000 | 0.000475203 | 0.023962532 | 0.000507671 | 0.001134870 | — | 0.004691451 | 0.003440377 | 0.002228677 | 0.012067098 | 0.001499315 | 0.000078292 | 0.000071974 | 0.000053417 |
| Factor | baseline | 1.611x slower | 7.963x slower | 1.050x slower | 1.638x slower | — | 2.849x slower | 3.160x slower | 1.824x slower | 8.041x slower | 1.445x slower | 1.010x slower | 1.012x slower | 1.001x faster |

### JSON (default policies): model → Data → model

| Metric | Foundation Codable | Foundation Codable + Serialization | Enigmatic + Foundation Codable | Enigmatic Codec JSON | Enigmatic + Foundation Serialization | PotentCodables AnyValue + Foundation | PotentJSON | SwiftyJSON + Foundation Codable | PMJSON | AnyCodable + Foundation Codable | swift-json (IkigaJSON) | CodableWrappers + Foundation | BetterCodable + Foundation | MetaCodable + Foundation |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Median ms/op | 19.666125 | 32.955500 | 104.034541 | 37.913334 | 38.610958 | — | 75.626208 | 67.380958 | 31.916083 | 175.721834 | 24.595166 | 19.952375 | 20.083500 | 19.722375 |
| Time % | 100.000% | 167.512% | 526.714% | 192.592% | 195.630% | — | 384.610% | 342.355% | 161.846% | 888.833% | 125.485% | 101.347% | 102.116% | 100.107% |
| E[r] | 1.000000 | 1.675123 | 5.267144 | 1.925922 | 1.956300 | — | 3.846101 | 3.423549 | 1.618456 | 8.888332 | 1.254853 | 1.013473 | 1.021159 | 1.001072 |
| Var[r] | 0.000000000 | 0.000259961 | 0.002558411 | 0.000454681 | 0.000394348 | — | 0.003543942 | 0.002406365 | 0.000647747 | 0.007931985 | 0.000613268 | 0.000104891 | 0.000172247 | 0.000024772 |
| Factor | baseline | 1.675x slower | 5.267x slower | 1.926x slower | 1.956x slower | — | 3.846x slower | 3.424x slower | 1.618x slower | 8.888x slower | 1.255x slower | 1.013x slower | 1.021x slower | 1.001x slower |

### XML plist: model → Data

| Metric | Foundation Codable | Foundation Codable + Serialization | Enigmatic + Foundation Codable | Enigmatic Codec JSON | Enigmatic + Foundation Serialization | PotentCodables AnyValue + Foundation | PotentJSON | SwiftyJSON + Foundation Codable | PMJSON | AnyCodable + Foundation Codable | swift-json (IkigaJSON) | CodableWrappers + Foundation | BetterCodable + Foundation | MetaCodable + Foundation |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Median ms/op | 7.621917 | 32.752458 | 15.554791 | — | 37.768166 | — | — | — | — | 127.844625 | — | 7.842208 | 7.904708 | 7.646458 |
| Time % | 100.000% | 428.434% | 203.496% | — | 492.817% | — | — | — | — | 1670.695% | — | 102.495% | 103.672% | 100.554% |
| E[r] | 1.000000 | 4.284343 | 2.034955 | — | 4.928168 | — | — | — | — | 16.706946 | — | 1.024945 | 1.036719 | 1.005545 |
| Var[r] | 0.000000000 | 0.001752152 | 0.001108751 | — | 0.008213036 | — | — | — | — | 0.041932000 | — | 0.000166245 | 0.000044996 | 0.000101718 |
| Factor | baseline | 4.284x slower | 2.035x slower | — | 4.928x slower | — | — | — | — | 16.707x slower | — | 1.025x slower | 1.037x slower | 1.006x slower |

### XML plist: Data → model

| Metric | Foundation Codable | Foundation Codable + Serialization | Enigmatic + Foundation Codable | Enigmatic Codec JSON | Enigmatic + Foundation Serialization | PotentCodables AnyValue + Foundation | PotentJSON | SwiftyJSON + Foundation Codable | PMJSON | AnyCodable + Foundation Codable | swift-json (IkigaJSON) | CodableWrappers + Foundation | BetterCodable + Foundation | MetaCodable + Foundation |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Median ms/op | 28.161541 | 53.758167 | 136.570417 | — | 20.091833 | — | — | — | — | 150.643916 | — | 28.841917 | 28.964958 | 28.204083 |
| Time % | 100.000% | 190.170% | 483.922% | — | 71.357% | — | — | — | — | 533.871% | — | 102.261% | 103.333% | 100.253% |
| E[r] | 1.000000 | 1.901696 | 4.839221 | — | 0.713567 | — | — | — | — | 5.338708 | — | 1.022607 | 1.033331 | 1.002528 |
| Var[r] | 0.000000000 | 0.001709773 | 0.015128489 | — | 0.000382808 | — | — | — | — | 0.016819478 | — | 0.000596065 | 0.000486657 | 0.000185431 |
| Factor | baseline | 1.902x slower | 4.839x slower | — | 1.401x faster | — | — | — | — | 5.339x slower | — | 1.023x slower | 1.033x slower | 1.003x slower |

### XML plist: model → Data → model

| Metric | Foundation Codable | Foundation Codable + Serialization | Enigmatic + Foundation Codable | Enigmatic Codec JSON | Enigmatic + Foundation Serialization | PotentCodables AnyValue + Foundation | PotentJSON | SwiftyJSON + Foundation Codable | PMJSON | AnyCodable + Foundation Codable | swift-json (IkigaJSON) | CodableWrappers + Foundation | BetterCodable + Foundation | MetaCodable + Foundation |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Median ms/op | 35.345541 | 85.830250 | 150.546042 | — | 58.222417 | — | — | — | — | 276.498875 | — | 36.128708 | 36.317542 | 35.480791 |
| Time % | 100.000% | 242.480% | 425.051% | — | 164.803% | — | — | — | — | 779.641% | — | 102.468% | 102.851% | 100.333% |
| E[r] | 1.000000 | 2.424795 | 4.250507 | — | 1.648033 | — | — | — | — | 7.796415 | — | 1.024682 | 1.028507 | 1.003326 |
| Var[r] | 0.000000000 | 0.000859521 | 0.005144252 | — | 0.000714289 | — | — | — | — | 0.016220282 | — | 0.000534217 | 0.000382328 | 0.000255180 |
| Factor | baseline | 2.425x slower | 4.251x slower | — | 1.648x slower | — | — | — | — | 7.796x slower | — | 1.025x slower | 1.029x slower | 1.003x slower |

### Binary plist: model → Data

| Metric | Foundation Codable | Foundation Codable + Serialization | Enigmatic + Foundation Codable | Enigmatic Codec JSON | Enigmatic + Foundation Serialization | PotentCodables AnyValue + Foundation | PotentJSON | SwiftyJSON + Foundation Codable | PMJSON | AnyCodable + Foundation Codable | swift-json (IkigaJSON) | CodableWrappers + Foundation | BetterCodable + Foundation | MetaCodable + Foundation |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Median ms/op | 10.491750 | 14.589292 | 17.340416 | — | 19.373167 | — | — | — | — | 132.975542 | — | 10.667834 | 10.708917 | 10.507917 |
| Time % | 100.000% | 139.089% | 166.237% | — | 184.936% | — | — | — | — | 1267.763% | — | 101.944% | 102.134% | 100.067% |
| E[r] | 1.000000 | 1.390888 | 1.662366 | — | 1.849355 | — | — | — | — | 12.677632 | — | 1.019435 | 1.021338 | 1.000667 |
| Var[r] | 0.000000000 | 0.000041105 | 0.002961332 | — | 0.000475851 | — | — | — | — | 0.029437054 | — | 0.000162236 | 0.000075424 | 0.000085943 |
| Factor | baseline | 1.391x slower | 1.662x slower | — | 1.849x slower | — | — | — | — | 12.678x slower | — | 1.019x slower | 1.021x slower | 1.001x slower |

### Binary plist: Data → model

| Metric | Foundation Codable | Foundation Codable + Serialization | Enigmatic + Foundation Codable | Enigmatic Codec JSON | Enigmatic + Foundation Serialization | PotentCodables AnyValue + Foundation | PotentJSON | SwiftyJSON + Foundation Codable | PMJSON | AnyCodable + Foundation Codable | swift-json (IkigaJSON) | CodableWrappers + Foundation | BetterCodable + Foundation | MetaCodable + Foundation |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Median ms/op | 24.903417 | 28.921042 | 134.447875 | — | 16.967500 | — | — | — | — | 146.990167 | — | 25.410917 | 25.488667 | 24.932834 |
| Time % | 100.000% | 115.578% | 536.608% | — | 67.745% | — | — | — | — | 587.134% | — | 101.730% | 101.740% | 99.824% |
| E[r] | 1.000000 | 1.155781 | 5.366078 | — | 0.677449 | — | — | — | — | 5.871344 | — | 1.017301 | 1.017395 | 0.998240 |
| Var[r] | 0.000000000 | 0.000416844 | 0.010188907 | — | 0.000201157 | — | — | — | — | 0.014337941 | — | 0.000526116 | 0.000431780 | 0.000182079 |
| Factor | baseline | 1.156x slower | 5.366x slower | — | 1.476x faster | — | — | — | — | 5.871x slower | — | 1.017x slower | 1.017x slower | 1.002x faster |

### Binary plist: model → Data → model

| Metric | Foundation Codable | Foundation Codable + Serialization | Enigmatic + Foundation Codable | Enigmatic Codec JSON | Enigmatic + Foundation Serialization | PotentCodables AnyValue + Foundation | PotentJSON | SwiftyJSON + Foundation Codable | PMJSON | AnyCodable + Foundation Codable | swift-json (IkigaJSON) | CodableWrappers + Foundation | BetterCodable + Foundation | MetaCodable + Foundation |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Median ms/op | 35.448916 | 43.348166 | 152.707625 | — | 37.531417 | — | — | — | — | 280.766167 | — | 36.312750 | 36.285750 | 35.493416 |
| Time % | 100.000% | 122.947% | 433.334% | — | 105.980% | — | — | — | — | 792.836% | — | 102.783% | 102.933% | 100.441% |
| E[r] | 1.000000 | 1.229475 | 4.333343 | — | 1.059802 | — | — | — | — | 7.928364 | — | 1.027826 | 1.029326 | 1.004406 |
| Var[r] | 0.000000000 | 0.000198142 | 0.003950873 | — | 0.000152715 | — | — | — | — | 0.011666796 | — | 0.000380914 | 0.000341392 | 0.000217489 |
| Factor | baseline | 1.229x slower | 4.333x slower | — | 1.060x slower | — | — | — | — | 7.928x slower | — | 1.028x slower | 1.029x slower | 1.004x slower |

## Observations

- Lowest observed mean decoding ratio for JSON (default policies): **MetaCodable + Foundation**, 99.893% of Foundation.
- Lowest observed mean decoding ratio for XML plist: **Enigmatic + Foundation Serialization**, 71.357% of Foundation.
- Lowest observed mean decoding ratio for Binary plist: **Enigmatic + Foundation Serialization**, 67.745% of Foundation.
- Native Data and Date with exact values in XML plist: no passing adapter.
- Native Data and Date with exact values in binary plist: Foundation Codable; Foundation Codable + Serialization; Enigmatic + Foundation Serialization; CodableWrappers + Foundation; BetterCodable + Foundation; MetaCodable + Foundation.
- Exact Int128 and UInt128 JSON roundtrip: Foundation Codable; Foundation Codable + Serialization; Enigmatic + Foundation Codable; Enigmatic Codec JSON; SwiftyJSON + Foundation Codable; CodableWrappers + Foundation; BetterCodable + Foundation; MetaCodable + Foundation.
- Explicit JSON null with a configured library wrapper: Enigmatic + Foundation Codable; Enigmatic Codec JSON; Enigmatic + Foundation Serialization; CodableWrappers + Foundation.

### Excluded performance paths

- JSON (default policies), model → Data, PotentCodables AnyValue + Foundation: DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- JSON (default policies), Data → model, PotentCodables AnyValue + Foundation: DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- JSON (default policies), model → Data → model, PotentCodables AnyValue + Foundation: DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- XML plist, model → Data, PotentCodables AnyValue + Foundation: DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- XML plist, Data → model, PotentCodables AnyValue + Foundation: DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- XML plist, model → Data → model, PotentCodables AnyValue + Foundation: DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- Binary plist, model → Data, PotentCodables AnyValue + Foundation: DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- Binary plist, Data → model, PotentCodables AnyValue + Foundation: DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- Binary plist, model → Data → model, PotentCodables AnyValue + Foundation: DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.

## Probe diagnostics

### In-memory model → tree → model

- **PotentCodables AnyValue + Foundation / int128** — ⚠️ EncodingError.invalidValue: -170141183460469231731687303715884105728 (Int128). Path: value[0]. Debug description: Encoder has not implemented support for Int128
- **PotentCodables AnyValue + Foundation / uint128** — ⚠️ EncodingError.invalidValue: 0 (UInt128). Path: value[0]. Debug description: Encoder has not implemented support for UInt128
- **PotentCodables AnyValue + Foundation / floatNaN** — ⚠️ DecodingError.typeMismatch: expected value of type Float. Path: value. Debug description: Float value value overflow/underflows Float
- **PotentCodables AnyValue + Foundation / doubleNaN** — ⚠️ DecodingError.typeMismatch: expected value of type Double. Path: value. Debug description: Double value value overflow/underflows Double
- **PotentCodables AnyValue + Foundation / nullRoot** — ⚠️ DecodingError.valueNotFound: Expected value of type Optional<String> but found null instead. Debug description: Value contained null when attempting to decode non-optional type
- **PotentJSON / int128** — ⚠️ EncodingError.invalidValue: -170141183460469231731687303715884105728 (Int128). Path: value[0]. Debug description: Encoder has not implemented support for Int128
- **PotentJSON / uint128** — ⚠️ EncodingError.invalidValue: 0 (UInt128). Path: value[0]. Debug description: Encoder has not implemented support for UInt128
- **PotentJSON / floatInfinity** — ⚠️ EncodingError.invalidValue: inf (Float). Path: value[0]. Debug description: Unable to encode Float.infinity directly in JSON. Use NonConformingFloatEncodingStrategy.convertToString to specify how the value should be encoded.
- **PotentJSON / doubleInfinity** — ⚠️ EncodingError.invalidValue: inf (Double). Path: value[0]. Debug description: Unable to encode Double.infinity directly in JSON. Use NonConformingFloatEncodingStrategy.convertToString to specify how the value should be encoded.
- **PotentJSON / floatNaN** — ⚠️ EncodingError.invalidValue: nan (Float). Path: value. Debug description: Unable to encode Float.nan directly in JSON. Use NonConformingFloatEncodingStrategy.convertToString to specify how the value should be encoded.
- **PotentJSON / doubleNaN** — ⚠️ EncodingError.invalidValue: nan (Double). Path: value. Debug description: Unable to encode Double.nan directly in JSON. Use NonConformingFloatEncodingStrategy.convertToString to specify how the value should be encoded.
- **PotentJSON / nullRoot** — ⚠️ DecodingError.valueNotFound: Expected value of type Optional<String> but found null instead. Debug description: Value contained null when attempting to decode non-optional type
- **PMJSON / uint** — ⚠️ EncodingError.invalidValue: 18446744073709551615 (UInt). Path: value[1]. Debug description: Encoded value is out of range for JSON integer.
- **PMJSON / uint64** — ⚠️ EncodingError.invalidValue: 18446744073709551615 (UInt64). Path: value[2]. Debug description: Encoded value is out of range for JSON integer.
- **PMJSON / int128** — ⚠️ EncodingError.invalidValue: -170141183460469231731687303715884105728 (Int128). Path: value[0]. Debug description: Encoder has not implemented support for Int128
- **PMJSON / uint128** — ⚠️ EncodingError.invalidValue: 0 (UInt128). Path: value[0]. Debug description: Encoder has not implemented support for UInt128

### JSON (default policies)

- **Foundation Codable / floatInfinity** — ⚠️ EncodingError.invalidValue: inf (Float). Path: value[0]. Debug description: Unable to encode Float.inf directly in JSON.
- **Foundation Codable / doubleInfinity** — ⚠️ EncodingError.invalidValue: inf (Double). Path: value[0]. Debug description: Unable to encode Double.inf directly in JSON.
- **Foundation Codable / floatNaN** — ⚠️ EncodingError.invalidValue: nan (Float). Path: value. Debug description: Unable to encode Float.nan directly in JSON.
- **Foundation Codable / doubleNaN** — ⚠️ EncodingError.invalidValue: nan (Double). Path: value. Debug description: Unable to encode Double.nan directly in JSON.
- **Foundation Codable / defaultNull** — ❌ Optional nil key is absent or not JSON null
- **Foundation Codable + Serialization / float16** — ❌ Value or precision changed
- **Foundation Codable + Serialization / float** — ❌ Value or precision changed
- **Foundation Codable + Serialization / double** — ❌ Value or precision changed
- **Foundation Codable + Serialization / floatInfinity** — ⚠️ EncodingError.invalidValue: inf (Float). Path: value[0]. Debug description: Unable to encode Float.inf directly in JSON.
- **Foundation Codable + Serialization / doubleInfinity** — ⚠️ EncodingError.invalidValue: inf (Double). Path: value[0]. Debug description: Unable to encode Double.inf directly in JSON.
- **Foundation Codable + Serialization / floatNaN** — ⚠️ EncodingError.invalidValue: nan (Float). Path: value. Debug description: Unable to encode Float.nan directly in JSON.
- **Foundation Codable + Serialization / doubleNaN** — ⚠️ EncodingError.invalidValue: nan (Double). Path: value. Debug description: Unable to encode Double.nan directly in JSON.
- **Foundation Codable + Serialization / defaultNull** — ❌ Optional nil key is absent or not JSON null
- **Enigmatic + Foundation Codable / float16** — ❌ Value or precision changed
- **Enigmatic + Foundation Codable / float** — ❌ Value or precision changed
- **Enigmatic + Foundation Codable / double** — ❌ Value or precision changed
- **Enigmatic + Foundation Codable / floatInfinity** — ⚠️ EncodingError.invalidValue: inf (Double). Path: [0]. Debug description: Unable to encode Double.inf directly in JSON.
- **Enigmatic + Foundation Codable / doubleInfinity** — ⚠️ EncodingError.invalidValue: inf (Double). Path: [0]. Debug description: Unable to encode Double.inf directly in JSON.
- **Enigmatic + Foundation Codable / floatNaN** — ⚠️ EncodingError.invalidValue: nan (Double). Path: value. Debug description: Unable to encode Double.nan directly in JSON.
- **Enigmatic + Foundation Codable / doubleNaN** — ⚠️ EncodingError.invalidValue: nan (Double). Path: value. Debug description: Unable to encode Double.nan directly in JSON.
- **Enigmatic + Foundation Codable / defaultNull** — ❌ Optional nil key is absent or not JSON null
- **Enigmatic Codec JSON / floatInfinity** — ⚠️ EncodingError.invalidValue: inf (Enigma). Path: value[0]. Debug description: Value is not representable in JSON
- **Enigmatic Codec JSON / doubleInfinity** — ⚠️ EncodingError.invalidValue: inf (Enigma). Path: value[0]. Debug description: Value is not representable in JSON
- **Enigmatic Codec JSON / floatNaN** — ⚠️ EncodingError.invalidValue: nan (Enigma). Path: value. Debug description: Value is not representable in JSON
- **Enigmatic Codec JSON / doubleNaN** — ⚠️ EncodingError.invalidValue: nan (Enigma). Path: value. Debug description: Value is not representable in JSON
- **Enigmatic Codec JSON / data** — ⚠️ EncodingError.invalidValue: 5 bytes (Enigma). Path: value. Debug description: Value is not representable in JSON
- **Enigmatic Codec JSON / date** — ⚠️ EncodingError.invalidValue: 2004-11-29 21:33:09 +0000 (Enigma). Path: value. Debug description: Value is not representable in JSON
- **Enigmatic Codec JSON / defaultNull** — ❌ Optional nil key is absent or not JSON null
- **Enigmatic + Foundation Serialization / int128** — ⚠️ EncodingError.invalidValue: Enigmatic.Enigma.Int128Box (Int128Box.Type). Path: value[0]. Debug description: Can not convert Int128 to NSObject
- **Enigmatic + Foundation Serialization / uint128** — ⚠️ EncodingError.invalidValue: Enigmatic.Enigma.UInt128Box (UInt128Box.Type). Path: value[0]. Debug description: Can not convert UInt128 to NSObject
- **Enigmatic + Foundation Serialization / float16** — ❌ Value or precision changed
- **Enigmatic + Foundation Serialization / float** — ❌ Value or precision changed
- **Enigmatic + Foundation Serialization / double** — ❌ Value or precision changed
- **Enigmatic + Foundation Serialization / floatInfinity** — ⚠️ EncodingError.invalidValue: Swift.Double (Double.Type). Path: value[0]. Debug description: Can not convert inf to JSONSerialization compatible NSObject
- **Enigmatic + Foundation Serialization / doubleInfinity** — ⚠️ EncodingError.invalidValue: Swift.Double (Double.Type). Path: value[0]. Debug description: Can not convert inf to JSONSerialization compatible NSObject
- **Enigmatic + Foundation Serialization / floatNaN** — ⚠️ EncodingError.invalidValue: Swift.Double (Double.Type). Path: value. Debug description: Can not convert nan to JSONSerialization compatible NSObject
- **Enigmatic + Foundation Serialization / doubleNaN** — ⚠️ EncodingError.invalidValue: Swift.Double (Double.Type). Path: value. Debug description: Can not convert nan to JSONSerialization compatible NSObject
- **Enigmatic + Foundation Serialization / data** — ⚠️ EncodingError.invalidValue: 5 bytes (Data). Path: value. Debug description: Can not convert Data to JSONSerialization compatible NSObject
- **Enigmatic + Foundation Serialization / date** — ⚠️ EncodingError.invalidValue: 2004-11-29 21:33:09 +0000 (Date). Path: value. Debug description: Can not convert Date to JSONSerialization compatible NSObject
- **Enigmatic + Foundation Serialization / defaultNull** — ❌ Optional nil key is absent or not JSON null
- **PotentCodables AnyValue + Foundation / string** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / bool** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / int** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / int8** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / int16** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / int32** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / int64** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / uint** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / uint8** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / uint16** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / uint32** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / uint64** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / int128** — ⚠️ EncodingError.invalidValue: -170141183460469231731687303715884105728 (Int128). Path: value[0]. Debug description: Encoder has not implemented support for Int128
- **PotentCodables AnyValue + Foundation / uint128** — ⚠️ EncodingError.invalidValue: 0 (UInt128). Path: value[0]. Debug description: Encoder has not implemented support for UInt128
- **PotentCodables AnyValue + Foundation / float16** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / float** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / double** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / floatInfinity** — ⚠️ EncodingError.invalidValue: inf (Float). Path: [1][0]. Debug description: Unable to encode Float.inf directly in JSON.
- **PotentCodables AnyValue + Foundation / doubleInfinity** — ⚠️ EncodingError.invalidValue: inf (Double). Path: [1][0]. Debug description: Unable to encode Double.inf directly in JSON.
- **PotentCodables AnyValue + Foundation / floatNaN** — ⚠️ EncodingError.invalidValue: nan (Float). Path: [1]. Debug description: Unable to encode Float.nan directly in JSON.
- **PotentCodables AnyValue + Foundation / doubleNaN** — ⚠️ EncodingError.invalidValue: nan (Double). Path: [1]. Debug description: Unable to encode Double.nan directly in JSON.
- **PotentCodables AnyValue + Foundation / decimal** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / cgFloat** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / data** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / date** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / url** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / uuid** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / nested** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / optional** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / explicitNull** — ❌ Optional nil key is absent or not JSON null
- **PotentCodables AnyValue + Foundation / defaultNull** — ❌ Optional nil key is absent or not JSON null
- **PotentCodables AnyValue + Foundation / nullRoot** — ⚠️ DecodingError.valueNotFound: Expected value of type Optional<String> but found null instead. Debug description: Value contained null when attempting to decode non-optional type
- **PotentJSON / string** — ⚠️ invalidData(PotentJSON.JSONSerialization.Error.InvalidData.expectedArraySeparator, position: 56)
- **PotentJSON / int128** — ⚠️ EncodingError.invalidValue: -170141183460469231731687303715884105728 (Int128). Path: value[0]. Debug description: Encoder has not implemented support for Int128
- **PotentJSON / uint128** — ⚠️ EncodingError.invalidValue: 0 (UInt128). Path: value[0]. Debug description: Encoder has not implemented support for UInt128
- **PotentJSON / floatInfinity** — ⚠️ EncodingError.invalidValue: inf (Float). Path: value[0]. Debug description: Unable to encode Float.infinity directly in JSON. Use NonConformingFloatEncodingStrategy.convertToString to specify how the value should be encoded.
- **PotentJSON / doubleInfinity** — ⚠️ EncodingError.invalidValue: inf (Double). Path: value[0]. Debug description: Unable to encode Double.infinity directly in JSON. Use NonConformingFloatEncodingStrategy.convertToString to specify how the value should be encoded.
- **PotentJSON / floatNaN** — ⚠️ EncodingError.invalidValue: nan (Float). Path: value. Debug description: Unable to encode Float.nan directly in JSON. Use NonConformingFloatEncodingStrategy.convertToString to specify how the value should be encoded.
- **PotentJSON / doubleNaN** — ⚠️ EncodingError.invalidValue: nan (Double). Path: value. Debug description: Unable to encode Double.nan directly in JSON. Use NonConformingFloatEncodingStrategy.convertToString to specify how the value should be encoded.
- **PotentJSON / defaultNull** — ❌ Optional nil key is absent or not JSON null
- **PotentJSON / nullRoot** — ⚠️ DecodingError.valueNotFound: Expected value of type Optional<String> but found null instead. Debug description: Value contained null when attempting to decode non-optional type
- **SwiftyJSON + Foundation Codable / float16** — ❌ Value or precision changed
- **SwiftyJSON + Foundation Codable / float** — ❌ Value or precision changed
- **SwiftyJSON + Foundation Codable / double** — ❌ Value or precision changed
- **SwiftyJSON + Foundation Codable / floatInfinity** — ⚠️ EncodingError.invalidValue: inf (Float). Path: value[0]. Debug description: Unable to encode Float.inf directly in JSON.
- **SwiftyJSON + Foundation Codable / doubleInfinity** — ⚠️ EncodingError.invalidValue: inf (Double). Path: value[0]. Debug description: Unable to encode Double.inf directly in JSON.
- **SwiftyJSON + Foundation Codable / floatNaN** — ⚠️ EncodingError.invalidValue: nan (Float). Path: value. Debug description: Unable to encode Float.nan directly in JSON.
- **SwiftyJSON + Foundation Codable / doubleNaN** — ⚠️ EncodingError.invalidValue: nan (Double). Path: value. Debug description: Unable to encode Double.nan directly in JSON.
- **SwiftyJSON + Foundation Codable / defaultNull** — ❌ Optional nil key is absent or not JSON null
- **SwiftyJSON + Foundation Codable / scalarRoot** — ⚠️ Error Domain=NSCocoaErrorDomain Code=3840 "JSON text did not start with array or object and option to allow fragments not set. around line 1, column 0." UserInfo={NSDebugDescription=JSON text did not start with array or object and option to allow fragments not set. around line 1, column 0., NSJSONSerializationErrorIndex=0}
- **SwiftyJSON + Foundation Codable / nullRoot** — ⚠️ Error Domain=NSCocoaErrorDomain Code=3840 "JSON text did not start with array or object and option to allow fragments not set. around line 1, column 0." UserInfo={NSDebugDescription=JSON text did not start with array or object and option to allow fragments not set. around line 1, column 0., NSJSONSerializationErrorIndex=0}
- **PMJSON / uint** — ⚠️ EncodingError.invalidValue: 18446744073709551615 (UInt). Path: value[1]. Debug description: Encoded value is out of range for JSON integer.
- **PMJSON / uint64** — ⚠️ EncodingError.invalidValue: 18446744073709551615 (UInt64). Path: value[2]. Debug description: Encoded value is out of range for JSON integer.
- **PMJSON / int128** — ⚠️ EncodingError.invalidValue: -170141183460469231731687303715884105728 (Int128). Path: value[0]. Debug description: Encoder has not implemented support for Int128
- **PMJSON / uint128** — ⚠️ EncodingError.invalidValue: 0 (UInt128). Path: value[0]. Debug description: Encoder has not implemented support for UInt128
- **PMJSON / floatInfinity** — ⚠️ DecodingError.dataCorrupted: Data was corrupted. Debug description: The given data was not valid JSON.. Underlying error: JSONParserError(invalidSyntax, line: 0, column: 11)
- **PMJSON / doubleInfinity** — ⚠️ DecodingError.dataCorrupted: Data was corrupted. Debug description: The given data was not valid JSON.. Underlying error: JSONParserError(invalidSyntax, line: 0, column: 11)
- **PMJSON / floatNaN** — ⚠️ DecodingError.dataCorrupted: Data was corrupted. Debug description: The given data was not valid JSON.. Underlying error: JSONParserError(invalidSyntax, line: 0, column: 10)
- **PMJSON / doubleNaN** — ⚠️ DecodingError.dataCorrupted: Data was corrupted. Debug description: The given data was not valid JSON.. Underlying error: JSONParserError(invalidSyntax, line: 0, column: 10)
- **PMJSON / decimal** — ⚠️ DecodingError.typeMismatch: expected value of type JSONObject. Path: value. Debug description: Expected to decode object but found number. Underlying error: expected object, found number
- **PMJSON / defaultNull** — ❌ Optional nil key is absent or not JSON null
- **AnyCodable + Foundation Codable / int128** — ⚠️ DecodingError.dataCorrupted: Data was corrupted. Debug description: The given data was not valid JSON.. Underlying error: Error Domain=NSCocoaErrorDomain Code=3840 "Number -1.7014118346046923e+38 is not representable in Swift." UserInfo={NSDebugDescription=Number -1.7014118346046923e+38 is not representable in Swift.}
- **AnyCodable + Foundation Codable / uint128** — ⚠️ DecodingError.dataCorrupted: Data was corrupted. Debug description: The given data was not valid JSON.. Underlying error: Error Domain=NSCocoaErrorDomain Code=3840 "Number 3.402823669209385e+38 is not representable in Swift." UserInfo={NSDebugDescription=Number 3.402823669209385e+38 is not representable in Swift.}
- **AnyCodable + Foundation Codable / float16** — ❌ Value or precision changed
- **AnyCodable + Foundation Codable / float** — ❌ Value or precision changed
- **AnyCodable + Foundation Codable / double** — ❌ Value or precision changed
- **AnyCodable + Foundation Codable / floatInfinity** — ⚠️ EncodingError.invalidValue: inf (Float). Path: value[0]. Debug description: Unable to encode Float.inf directly in JSON.
- **AnyCodable + Foundation Codable / doubleInfinity** — ⚠️ EncodingError.invalidValue: inf (Double). Path: value[0]. Debug description: Unable to encode Double.inf directly in JSON.
- **AnyCodable + Foundation Codable / floatNaN** — ⚠️ EncodingError.invalidValue: nan (Float). Path: value. Debug description: Unable to encode Float.nan directly in JSON.
- **AnyCodable + Foundation Codable / doubleNaN** — ⚠️ EncodingError.invalidValue: nan (Double). Path: value. Debug description: Unable to encode Double.nan directly in JSON.
- **AnyCodable + Foundation Codable / decimal** — ❌ Value or precision changed
- **AnyCodable + Foundation Codable / defaultNull** — ❌ Optional nil key is absent or not JSON null
- **swift-json (IkigaJSON) / int** — ⚠️ decodingError(expected: Swift.Int, keyPath: [CodingKeys(stringValue: "value", intValue: nil)])
- **swift-json (IkigaJSON) / int64** — ⚠️ decodingError(expected: Swift.Int64, keyPath: [CodingKeys(stringValue: "value", intValue: nil)])
- **swift-json (IkigaJSON) / uint** — ⚠️ decodingError(expected: Swift.UInt, keyPath: [CodingKeys(stringValue: "value", intValue: nil)])
- **swift-json (IkigaJSON) / uint64** — ⚠️ decodingError(expected: Swift.UInt64, keyPath: [CodingKeys(stringValue: "value", intValue: nil)])
- **swift-json (IkigaJSON) / int128** — ⚠️ EncodingError.invalidValue: -170141183460469231731687303715884105728 (Int128). Path: value. Debug description: Encoder has not implemented support for Int128
- **swift-json (IkigaJSON) / uint128** — ⚠️ EncodingError.invalidValue: 0 (UInt128). Path: value. Debug description: Encoder has not implemented support for UInt128
- **swift-json (IkigaJSON) / double** — ❌ Value or precision changed
- **swift-json (IkigaJSON) / floatInfinity** — ⚠️ Unexpected token 'i': Expected a Value Literal at -1:-1
- **swift-json (IkigaJSON) / doubleInfinity** — ⚠️ Unexpected token 'i': Expected a Value Literal at -1:-1
- **swift-json (IkigaJSON) / floatNaN** — ⚠️ Invalid Literal at -1:-1
- **swift-json (IkigaJSON) / doubleNaN** — ⚠️ Invalid Literal at -1:-1
- **swift-json (IkigaJSON) / decimal** — ❌ Value or precision changed
- **swift-json (IkigaJSON) / defaultNull** — ❌ Optional nil key is absent or not JSON null
- **CodableWrappers + Foundation / floatInfinity** — ⚠️ EncodingError.invalidValue: inf (Float). Path: value[0]. Debug description: Unable to encode Float.inf directly in JSON.
- **CodableWrappers + Foundation / doubleInfinity** — ⚠️ EncodingError.invalidValue: inf (Double). Path: value[0]. Debug description: Unable to encode Double.inf directly in JSON.
- **CodableWrappers + Foundation / floatNaN** — ⚠️ EncodingError.invalidValue: nan (Float). Path: value. Debug description: Unable to encode Float.nan directly in JSON.
- **CodableWrappers + Foundation / doubleNaN** — ⚠️ EncodingError.invalidValue: nan (Double). Path: value. Debug description: Unable to encode Double.nan directly in JSON.
- **CodableWrappers + Foundation / defaultNull** — ❌ Optional nil key is absent or not JSON null
- **BetterCodable + Foundation / floatInfinity** — ⚠️ EncodingError.invalidValue: inf (Float). Path: value[0]. Debug description: Unable to encode Float.inf directly in JSON.
- **BetterCodable + Foundation / doubleInfinity** — ⚠️ EncodingError.invalidValue: inf (Double). Path: value[0]. Debug description: Unable to encode Double.inf directly in JSON.
- **BetterCodable + Foundation / floatNaN** — ⚠️ EncodingError.invalidValue: nan (Float). Path: value. Debug description: Unable to encode Float.nan directly in JSON.
- **BetterCodable + Foundation / doubleNaN** — ⚠️ EncodingError.invalidValue: nan (Double). Path: value. Debug description: Unable to encode Double.nan directly in JSON.
- **BetterCodable + Foundation / defaultNull** — ❌ Optional nil key is absent or not JSON null
- **MetaCodable + Foundation / floatInfinity** — ⚠️ EncodingError.invalidValue: inf (Float). Path: value[0]. Debug description: Unable to encode Float.inf directly in JSON.
- **MetaCodable + Foundation / doubleInfinity** — ⚠️ EncodingError.invalidValue: inf (Double). Path: value[0]. Debug description: Unable to encode Double.inf directly in JSON.
- **MetaCodable + Foundation / floatNaN** — ⚠️ EncodingError.invalidValue: nan (Float). Path: value. Debug description: Unable to encode Float.nan directly in JSON.
- **MetaCodable + Foundation / doubleNaN** — ⚠️ EncodingError.invalidValue: nan (Double). Path: value. Debug description: Unable to encode Double.nan directly in JSON.
- **MetaCodable + Foundation / defaultNull** — ❌ Optional nil key is absent or not JSON null

### JSON (non-finite numbers as strings)

- **Foundation Codable / defaultNull** — ❌ Optional nil key is absent or not JSON null
- **Enigmatic + Foundation Codable / float16** — ❌ Value or precision changed
- **Enigmatic + Foundation Codable / float** — ❌ Value or precision changed
- **Enigmatic + Foundation Codable / double** — ❌ Value or precision changed
- **Enigmatic + Foundation Codable / defaultNull** — ❌ Optional nil key is absent or not JSON null
- **PotentCodables AnyValue + Foundation / string** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / bool** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / int** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / int8** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / int16** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / int32** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / int64** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / uint** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / uint8** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / uint16** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / uint32** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / uint64** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / int128** — ⚠️ EncodingError.invalidValue: -170141183460469231731687303715884105728 (Int128). Path: value[0]. Debug description: Encoder has not implemented support for Int128
- **PotentCodables AnyValue + Foundation / uint128** — ⚠️ EncodingError.invalidValue: 0 (UInt128). Path: value[0]. Debug description: Encoder has not implemented support for UInt128
- **PotentCodables AnyValue + Foundation / float16** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / float** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / double** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / floatInfinity** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / doubleInfinity** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / floatNaN** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / doubleNaN** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / decimal** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / cgFloat** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / data** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / date** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / url** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / uuid** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / nested** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / optional** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / explicitNull** — ❌ Optional nil key is absent or not JSON null
- **PotentCodables AnyValue + Foundation / defaultNull** — ❌ Optional nil key is absent or not JSON null
- **PotentCodables AnyValue + Foundation / nullRoot** — ⚠️ DecodingError.valueNotFound: Expected value of type Optional<String> but found null instead. Debug description: Value contained null when attempting to decode non-optional type
- **PotentJSON / string** — ⚠️ invalidData(PotentJSON.JSONSerialization.Error.InvalidData.expectedArraySeparator, position: 56)
- **PotentJSON / int128** — ⚠️ EncodingError.invalidValue: -170141183460469231731687303715884105728 (Int128). Path: value[0]. Debug description: Encoder has not implemented support for Int128
- **PotentJSON / uint128** — ⚠️ EncodingError.invalidValue: 0 (UInt128). Path: value[0]. Debug description: Encoder has not implemented support for UInt128
- **PotentJSON / defaultNull** — ❌ Optional nil key is absent or not JSON null
- **PotentJSON / nullRoot** — ⚠️ DecodingError.valueNotFound: Expected value of type Optional<String> but found null instead. Debug description: Value contained null when attempting to decode non-optional type
- **AnyCodable + Foundation Codable / int128** — ⚠️ DecodingError.dataCorrupted: Data was corrupted. Debug description: The given data was not valid JSON.. Underlying error: Error Domain=NSCocoaErrorDomain Code=3840 "Number -1.7014118346046923e+38 is not representable in Swift." UserInfo={NSDebugDescription=Number -1.7014118346046923e+38 is not representable in Swift.}
- **AnyCodable + Foundation Codable / uint128** — ⚠️ DecodingError.dataCorrupted: Data was corrupted. Debug description: The given data was not valid JSON.. Underlying error: Error Domain=NSCocoaErrorDomain Code=3840 "Number 3.402823669209385e+38 is not representable in Swift." UserInfo={NSDebugDescription=Number 3.402823669209385e+38 is not representable in Swift.}
- **AnyCodable + Foundation Codable / float16** — ❌ Value or precision changed
- **AnyCodable + Foundation Codable / float** — ❌ Value or precision changed
- **AnyCodable + Foundation Codable / double** — ❌ Value or precision changed
- **AnyCodable + Foundation Codable / decimal** — ❌ Value or precision changed
- **AnyCodable + Foundation Codable / defaultNull** — ❌ Optional nil key is absent or not JSON null
- **CodableWrappers + Foundation / defaultNull** — ❌ Optional nil key is absent or not JSON null
- **BetterCodable + Foundation / defaultNull** — ❌ Optional nil key is absent or not JSON null
- **MetaCodable + Foundation / defaultNull** — ❌ Optional nil key is absent or not JSON null

### XML plist

- **Foundation Codable / int128** — ⚠️ EncodingError.invalidValue: Comparison.ValueBox<Swift.Array<Swift.Int128>>(value: [-170141183460469231731687303715884105728, -1, 0, 170141183460469231731687303715884105727]) (ValueBox<Array<Int128>>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: -170141183460469231731687303715884105728 (Int128). Path: value[0]. Debug description: Encoder has not implemented support for Int128
- **Foundation Codable / uint128** — ⚠️ EncodingError.invalidValue: Comparison.ValueBox<Swift.Array<Swift.UInt128>>(value: [0, 340282366920938463463374607431768211455]) (ValueBox<Array<UInt128>>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: 0 (UInt128). Path: value[0]. Debug description: Encoder has not implemented support for UInt128
- **Foundation Codable / date** — ❌ Value or precision changed
- **Foundation Codable / nativeDate** — ❌ Native plist Date present, but timestamp changed: 123456789.125 → 123456789.0
- **Foundation Codable / scalarRoot** — ⚠️ EncodingError.invalidValue: "root 😀" (String). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: "root 😀" (String). Debug description: Top-level String encoded as string property list fragment.
- **Foundation Codable / nullRoot** — ⚠️ EncodingError.invalidValue: nil (Optional<String>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: nil (Optional<String>). Debug description: Top-level Optional<String> encoded as string property list fragment.
- **Foundation Codable + Serialization / int128** — ⚠️ EncodingError.invalidValue: Comparison.ValueBox<Swift.Array<Swift.Int128>>(value: [-170141183460469231731687303715884105728, -1, 0, 170141183460469231731687303715884105727]) (ValueBox<Array<Int128>>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: -170141183460469231731687303715884105728 (Int128). Path: value[0]. Debug description: Encoder has not implemented support for Int128
- **Foundation Codable + Serialization / uint128** — ⚠️ EncodingError.invalidValue: Comparison.ValueBox<Swift.Array<Swift.UInt128>>(value: [0, 340282366920938463463374607431768211455]) (ValueBox<Array<UInt128>>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: 0 (UInt128). Path: value[0]. Debug description: Encoder has not implemented support for UInt128
- **Foundation Codable + Serialization / float16** — ❌ Value or precision changed
- **Foundation Codable + Serialization / float** — ❌ Value or precision changed
- **Foundation Codable + Serialization / double** — ❌ Value or precision changed
- **Foundation Codable + Serialization / date** — ❌ Value or precision changed
- **Foundation Codable + Serialization / nativeDate** — ❌ Native plist Date present, but timestamp changed: 123456789.125 → 123456789.0
- **Foundation Codable + Serialization / scalarRoot** — ⚠️ EncodingError.invalidValue: "root 😀" (String). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: "root 😀" (String). Debug description: Top-level String encoded as string property list fragment.
- **Foundation Codable + Serialization / nullRoot** — ⚠️ EncodingError.invalidValue: nil (Optional<String>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: nil (Optional<String>). Debug description: Top-level Optional<String> encoded as string property list fragment.
- **Enigmatic + Foundation Codable / int128** — ⚠️ EncodingError.invalidValue: ["value": [-170141183460469231731687303715884105728, -1, 0, 170141183460469231731687303715884105727]] (Enigma). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: -170141183460469231731687303715884105728 (Int128). Path: value. Debug description: Encoder has not implemented support for Int128
- **Enigmatic + Foundation Codable / uint128** — ⚠️ EncodingError.invalidValue: ["value": [0, 340282366920938463463374607431768211455]] (Enigma). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: 0 (UInt128). Path: value. Debug description: Encoder has not implemented support for UInt128
- **Enigmatic + Foundation Codable / float16** — ❌ Value or precision changed
- **Enigmatic + Foundation Codable / float** — ❌ Value or precision changed
- **Enigmatic + Foundation Codable / double** — ❌ Value or precision changed
- **Enigmatic + Foundation Codable / nativeData** — ❌ Data is not stored as native plist data, or changed
- **Enigmatic + Foundation Codable / nativeDate** — ❌ Date is not stored as native plist date
- **Enigmatic + Foundation Codable / plistDataType** — ❌ Encoded plist value is not native Data
- **Enigmatic + Foundation Codable / plistDateType** — ❌ Encoded plist value is not native Date
- **Enigmatic + Foundation Codable / scalarRoot** — ⚠️ EncodingError.invalidValue: "root 😀" (Enigma). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: "root 😀" (Enigma). Debug description: Top-level Enigma encoded as string property list fragment.
- **Enigmatic + Foundation Codable / nullRoot** — ⚠️ EncodingError.invalidValue: null (Enigma). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: null (Enigma). Debug description: Top-level Enigma encoded as string property list fragment.
- **Enigmatic + Foundation Serialization / int128** — ⚠️ EncodingError.invalidValue: Enigmatic.Enigma.Int128Box (Int128Box.Type). Path: value[0]. Debug description: Can not convert Int128 to NSObject
- **Enigmatic + Foundation Serialization / uint128** — ⚠️ EncodingError.invalidValue: Enigmatic.Enigma.UInt128Box (UInt128Box.Type). Path: value[0]. Debug description: Can not convert UInt128 to NSObject
- **Enigmatic + Foundation Serialization / float16** — ❌ Value or precision changed
- **Enigmatic + Foundation Serialization / float** — ❌ Value or precision changed
- **Enigmatic + Foundation Serialization / double** — ❌ Value or precision changed
- **Enigmatic + Foundation Serialization / date** — ❌ Value or precision changed
- **Enigmatic + Foundation Serialization / optional** — ⚠️ EncodingError.invalidValue: <null> (NSNull). Path: value[0]. Debug description: Can not convert null to PropertyListSerialization compatible NSObject
- **Enigmatic + Foundation Serialization / nativeDate** — ❌ Native plist Date present, but timestamp changed: 123456789.125 → 123456789.0
- **Enigmatic + Foundation Serialization / nullRoot** — ⚠️ EncodingError.invalidValue: <null> (NSNull). Debug description: Can not convert null to PropertyListSerialization compatible NSObject
- **PotentCodables AnyValue + Foundation / string** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / bool** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / int** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / int8** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / int16** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / int32** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / int64** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / uint** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / uint8** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / uint16** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / uint32** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / uint64** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / int128** — ⚠️ EncodingError.invalidValue: -170141183460469231731687303715884105728 (Int128). Path: value[0]. Debug description: Encoder has not implemented support for Int128
- **PotentCodables AnyValue + Foundation / uint128** — ⚠️ EncodingError.invalidValue: 0 (UInt128). Path: value[0]. Debug description: Encoder has not implemented support for UInt128
- **PotentCodables AnyValue + Foundation / float16** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / float** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / double** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / floatInfinity** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / doubleInfinity** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / floatNaN** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / doubleNaN** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / decimal** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / cgFloat** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / data** — ⚠️ unsupportedType
- **PotentCodables AnyValue + Foundation / date** — ⚠️ unsupportedType
- **PotentCodables AnyValue + Foundation / url** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / uuid** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / nested** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / optional** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / nativeData** — ⚠️ unsupportedType
- **PotentCodables AnyValue + Foundation / nativeDate** — ⚠️ unsupportedType
- **PotentCodables AnyValue + Foundation / plistDataType** — ❌ Encoded plist value is not native Data
- **PotentCodables AnyValue + Foundation / plistDateType** — ❌ Encoded plist value is not native Date
- **PotentCodables AnyValue + Foundation / scalarRoot** — ⚠️ EncodingError.invalidValue: root 😀 (AnyValue). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: root 😀 (AnyValue). Debug description: Top-level AnyValue encoded as string property list fragment.
- **PotentCodables AnyValue + Foundation / nullRoot** — ⚠️ EncodingError.invalidValue: nil (AnyValue). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: nil (AnyValue). Debug description: Top-level AnyValue encoded as string property list fragment.
- **AnyCodable + Foundation Codable / int128** — ⚠️ EncodingError.invalidValue: Comparison.ValueBox<Swift.Array<Swift.Int128>>(value: [-170141183460469231731687303715884105728, -1, 0, 170141183460469231731687303715884105727]) (ValueBox<Array<Int128>>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: -170141183460469231731687303715884105728 (Int128). Path: value[0]. Debug description: Encoder has not implemented support for Int128
- **AnyCodable + Foundation Codable / uint128** — ⚠️ EncodingError.invalidValue: Comparison.ValueBox<Swift.Array<Swift.UInt128>>(value: [0, 340282366920938463463374607431768211455]) (ValueBox<Array<UInt128>>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: 0 (UInt128). Path: value[0]. Debug description: Encoder has not implemented support for UInt128
- **AnyCodable + Foundation Codable / float16** — ❌ Value or precision changed
- **AnyCodable + Foundation Codable / float** — ❌ Value or precision changed
- **AnyCodable + Foundation Codable / double** — ❌ Value or precision changed
- **AnyCodable + Foundation Codable / data** — ⚠️ DecodingError.dataCorrupted: Data was corrupted. Debug description: AnyDecodable value cannot be decoded
- **AnyCodable + Foundation Codable / date** — ⚠️ DecodingError.dataCorrupted: Data was corrupted. Debug description: AnyDecodable value cannot be decoded
- **AnyCodable + Foundation Codable / nativeData** — ⚠️ DecodingError.dataCorrupted: Data was corrupted. Debug description: AnyDecodable value cannot be decoded
- **AnyCodable + Foundation Codable / nativeDate** — ⚠️ DecodingError.dataCorrupted: Data was corrupted. Debug description: AnyDecodable value cannot be decoded
- **AnyCodable + Foundation Codable / plistDataType** — ⚠️ DecodingError.dataCorrupted: Data was corrupted. Debug description: AnyDecodable value cannot be decoded
- **AnyCodable + Foundation Codable / plistDateType** — ⚠️ DecodingError.dataCorrupted: Data was corrupted. Debug description: AnyDecodable value cannot be decoded
- **AnyCodable + Foundation Codable / scalarRoot** — ⚠️ EncodingError.invalidValue: "root 😀" (String). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: "root 😀" (String). Debug description: Top-level String encoded as string property list fragment.
- **AnyCodable + Foundation Codable / nullRoot** — ⚠️ EncodingError.invalidValue: nil (Optional<String>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: nil (Optional<String>). Debug description: Top-level Optional<String> encoded as string property list fragment.
- **CodableWrappers + Foundation / int128** — ⚠️ EncodingError.invalidValue: Comparison.ValueBox<Swift.Array<Swift.Int128>>(value: [-170141183460469231731687303715884105728, -1, 0, 170141183460469231731687303715884105727]) (ValueBox<Array<Int128>>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: -170141183460469231731687303715884105728 (Int128). Path: value[0]. Debug description: Encoder has not implemented support for Int128
- **CodableWrappers + Foundation / uint128** — ⚠️ EncodingError.invalidValue: Comparison.ValueBox<Swift.Array<Swift.UInt128>>(value: [0, 340282366920938463463374607431768211455]) (ValueBox<Array<UInt128>>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: 0 (UInt128). Path: value[0]. Debug description: Encoder has not implemented support for UInt128
- **CodableWrappers + Foundation / date** — ❌ Value or precision changed
- **CodableWrappers + Foundation / nativeDate** — ❌ Native plist Date present, but timestamp changed: 123456789.125 → 123456789.0
- **CodableWrappers + Foundation / scalarRoot** — ⚠️ EncodingError.invalidValue: "root 😀" (String). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: "root 😀" (String). Debug description: Top-level String encoded as string property list fragment.
- **CodableWrappers + Foundation / nullRoot** — ⚠️ EncodingError.invalidValue: nil (Optional<String>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: nil (Optional<String>). Debug description: Top-level Optional<String> encoded as string property list fragment.
- **BetterCodable + Foundation / int128** — ⚠️ EncodingError.invalidValue: Comparison.ValueBox<Swift.Array<Swift.Int128>>(value: [-170141183460469231731687303715884105728, -1, 0, 170141183460469231731687303715884105727]) (ValueBox<Array<Int128>>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: -170141183460469231731687303715884105728 (Int128). Path: value[0]. Debug description: Encoder has not implemented support for Int128
- **BetterCodable + Foundation / uint128** — ⚠️ EncodingError.invalidValue: Comparison.ValueBox<Swift.Array<Swift.UInt128>>(value: [0, 340282366920938463463374607431768211455]) (ValueBox<Array<UInt128>>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: 0 (UInt128). Path: value[0]. Debug description: Encoder has not implemented support for UInt128
- **BetterCodable + Foundation / date** — ❌ Value or precision changed
- **BetterCodable + Foundation / nativeDate** — ❌ Native plist Date present, but timestamp changed: 123456789.125 → 123456789.0
- **BetterCodable + Foundation / scalarRoot** — ⚠️ EncodingError.invalidValue: "root 😀" (String). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: "root 😀" (String). Debug description: Top-level String encoded as string property list fragment.
- **BetterCodable + Foundation / nullRoot** — ⚠️ EncodingError.invalidValue: nil (Optional<String>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: nil (Optional<String>). Debug description: Top-level Optional<String> encoded as string property list fragment.
- **MetaCodable + Foundation / int128** — ⚠️ EncodingError.invalidValue: Comparison.ValueBox<Swift.Array<Swift.Int128>>(value: [-170141183460469231731687303715884105728, -1, 0, 170141183460469231731687303715884105727]) (ValueBox<Array<Int128>>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: -170141183460469231731687303715884105728 (Int128). Path: value[0]. Debug description: Encoder has not implemented support for Int128
- **MetaCodable + Foundation / uint128** — ⚠️ EncodingError.invalidValue: Comparison.ValueBox<Swift.Array<Swift.UInt128>>(value: [0, 340282366920938463463374607431768211455]) (ValueBox<Array<UInt128>>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: 0 (UInt128). Path: value[0]. Debug description: Encoder has not implemented support for UInt128
- **MetaCodable + Foundation / date** — ❌ Value or precision changed
- **MetaCodable + Foundation / nativeDate** — ❌ Native plist Date present, but timestamp changed: 123456789.125 → 123456789.0
- **MetaCodable + Foundation / scalarRoot** — ⚠️ EncodingError.invalidValue: "root 😀" (String). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: "root 😀" (String). Debug description: Top-level String encoded as string property list fragment.
- **MetaCodable + Foundation / nullRoot** — ⚠️ EncodingError.invalidValue: nil (Optional<String>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: nil (Optional<String>). Debug description: Top-level Optional<String> encoded as string property list fragment.

### Binary plist

- **Foundation Codable / int128** — ⚠️ EncodingError.invalidValue: Comparison.ValueBox<Swift.Array<Swift.Int128>>(value: [-170141183460469231731687303715884105728, -1, 0, 170141183460469231731687303715884105727]) (ValueBox<Array<Int128>>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: -170141183460469231731687303715884105728 (Int128). Path: value[0]. Debug description: Encoder has not implemented support for Int128
- **Foundation Codable / uint128** — ⚠️ EncodingError.invalidValue: Comparison.ValueBox<Swift.Array<Swift.UInt128>>(value: [0, 340282366920938463463374607431768211455]) (ValueBox<Array<UInt128>>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: 0 (UInt128). Path: value[0]. Debug description: Encoder has not implemented support for UInt128
- **Foundation Codable / scalarRoot** — ⚠️ EncodingError.invalidValue: "root 😀" (String). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: "root 😀" (String). Debug description: Top-level String encoded as string property list fragment.
- **Foundation Codable / nullRoot** — ⚠️ EncodingError.invalidValue: nil (Optional<String>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: nil (Optional<String>). Debug description: Top-level Optional<String> encoded as string property list fragment.
- **Foundation Codable + Serialization / int128** — ⚠️ EncodingError.invalidValue: Comparison.ValueBox<Swift.Array<Swift.Int128>>(value: [-170141183460469231731687303715884105728, -1, 0, 170141183460469231731687303715884105727]) (ValueBox<Array<Int128>>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: -170141183460469231731687303715884105728 (Int128). Path: value[0]. Debug description: Encoder has not implemented support for Int128
- **Foundation Codable + Serialization / uint128** — ⚠️ EncodingError.invalidValue: Comparison.ValueBox<Swift.Array<Swift.UInt128>>(value: [0, 340282366920938463463374607431768211455]) (ValueBox<Array<UInt128>>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: 0 (UInt128). Path: value[0]. Debug description: Encoder has not implemented support for UInt128
- **Foundation Codable + Serialization / scalarRoot** — ⚠️ EncodingError.invalidValue: "root 😀" (String). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: "root 😀" (String). Debug description: Top-level String encoded as string property list fragment.
- **Foundation Codable + Serialization / nullRoot** — ⚠️ EncodingError.invalidValue: nil (Optional<String>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: nil (Optional<String>). Debug description: Top-level Optional<String> encoded as string property list fragment.
- **Enigmatic + Foundation Codable / int128** — ⚠️ EncodingError.invalidValue: ["value": [-170141183460469231731687303715884105728, -1, 0, 170141183460469231731687303715884105727]] (Enigma). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: -170141183460469231731687303715884105728 (Int128). Path: value. Debug description: Encoder has not implemented support for Int128
- **Enigmatic + Foundation Codable / uint128** — ⚠️ EncodingError.invalidValue: ["value": [0, 340282366920938463463374607431768211455]] (Enigma). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: 0 (UInt128). Path: value. Debug description: Encoder has not implemented support for UInt128
- **Enigmatic + Foundation Codable / float16** — ❌ Value or precision changed
- **Enigmatic + Foundation Codable / float** — ❌ Value or precision changed
- **Enigmatic + Foundation Codable / double** — ❌ Value or precision changed
- **Enigmatic + Foundation Codable / nativeData** — ❌ Data is not stored as native plist data, or changed
- **Enigmatic + Foundation Codable / nativeDate** — ❌ Date is not stored as native plist date
- **Enigmatic + Foundation Codable / plistDataType** — ❌ Encoded plist value is not native Data
- **Enigmatic + Foundation Codable / plistDateType** — ❌ Encoded plist value is not native Date
- **Enigmatic + Foundation Codable / scalarRoot** — ⚠️ EncodingError.invalidValue: "root 😀" (Enigma). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: "root 😀" (Enigma). Debug description: Top-level Enigma encoded as string property list fragment.
- **Enigmatic + Foundation Codable / nullRoot** — ⚠️ EncodingError.invalidValue: null (Enigma). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: null (Enigma). Debug description: Top-level Enigma encoded as string property list fragment.
- **Enigmatic + Foundation Serialization / int128** — ⚠️ EncodingError.invalidValue: Enigmatic.Enigma.Int128Box (Int128Box.Type). Path: value[0]. Debug description: Can not convert Int128 to NSObject
- **Enigmatic + Foundation Serialization / uint128** — ⚠️ EncodingError.invalidValue: Enigmatic.Enigma.UInt128Box (UInt128Box.Type). Path: value[0]. Debug description: Can not convert UInt128 to NSObject
- **Enigmatic + Foundation Serialization / optional** — ⚠️ EncodingError.invalidValue: <null> (NSNull). Path: value[0]. Debug description: Can not convert null to PropertyListSerialization compatible NSObject
- **Enigmatic + Foundation Serialization / nullRoot** — ⚠️ EncodingError.invalidValue: <null> (NSNull). Debug description: Can not convert null to PropertyListSerialization compatible NSObject
- **PotentCodables AnyValue + Foundation / string** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / bool** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / int** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / int8** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / int16** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / int32** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / int64** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / uint** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / uint8** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / uint16** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / uint32** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / uint64** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / int128** — ⚠️ EncodingError.invalidValue: -170141183460469231731687303715884105728 (Int128). Path: value[0]. Debug description: Encoder has not implemented support for Int128
- **PotentCodables AnyValue + Foundation / uint128** — ⚠️ EncodingError.invalidValue: 0 (UInt128). Path: value[0]. Debug description: Encoder has not implemented support for UInt128
- **PotentCodables AnyValue + Foundation / float16** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / float** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / double** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / floatInfinity** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / doubleInfinity** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / floatNaN** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / doubleNaN** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / decimal** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / cgFloat** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / data** — ⚠️ unsupportedType
- **PotentCodables AnyValue + Foundation / date** — ⚠️ unsupportedType
- **PotentCodables AnyValue + Foundation / url** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / uuid** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / nested** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / optional** — ⚠️ DecodingError.valueNotFound: Expected value of type KeyedDecodingContainer<CodingKeys> but found null instead. Debug description: Cannot get keyed decoding container -- found null value instead.
- **PotentCodables AnyValue + Foundation / nativeData** — ⚠️ unsupportedType
- **PotentCodables AnyValue + Foundation / nativeDate** — ⚠️ unsupportedType
- **PotentCodables AnyValue + Foundation / plistDataType** — ❌ Encoded plist value is not native Data
- **PotentCodables AnyValue + Foundation / plistDateType** — ❌ Encoded plist value is not native Date
- **PotentCodables AnyValue + Foundation / scalarRoot** — ⚠️ EncodingError.invalidValue: root 😀 (AnyValue). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: root 😀 (AnyValue). Debug description: Top-level AnyValue encoded as string property list fragment.
- **PotentCodables AnyValue + Foundation / nullRoot** — ⚠️ EncodingError.invalidValue: nil (AnyValue). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: nil (AnyValue). Debug description: Top-level AnyValue encoded as string property list fragment.
- **AnyCodable + Foundation Codable / int128** — ⚠️ EncodingError.invalidValue: Comparison.ValueBox<Swift.Array<Swift.Int128>>(value: [-170141183460469231731687303715884105728, -1, 0, 170141183460469231731687303715884105727]) (ValueBox<Array<Int128>>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: -170141183460469231731687303715884105728 (Int128). Path: value[0]. Debug description: Encoder has not implemented support for Int128
- **AnyCodable + Foundation Codable / uint128** — ⚠️ EncodingError.invalidValue: Comparison.ValueBox<Swift.Array<Swift.UInt128>>(value: [0, 340282366920938463463374607431768211455]) (ValueBox<Array<UInt128>>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: 0 (UInt128). Path: value[0]. Debug description: Encoder has not implemented support for UInt128
- **AnyCodable + Foundation Codable / float16** — ❌ Value or precision changed
- **AnyCodable + Foundation Codable / float** — ❌ Value or precision changed
- **AnyCodable + Foundation Codable / double** — ❌ Value or precision changed
- **AnyCodable + Foundation Codable / data** — ⚠️ DecodingError.dataCorrupted: Data was corrupted. Debug description: AnyDecodable value cannot be decoded
- **AnyCodable + Foundation Codable / date** — ⚠️ DecodingError.dataCorrupted: Data was corrupted. Debug description: AnyDecodable value cannot be decoded
- **AnyCodable + Foundation Codable / nativeData** — ⚠️ DecodingError.dataCorrupted: Data was corrupted. Debug description: AnyDecodable value cannot be decoded
- **AnyCodable + Foundation Codable / nativeDate** — ⚠️ DecodingError.dataCorrupted: Data was corrupted. Debug description: AnyDecodable value cannot be decoded
- **AnyCodable + Foundation Codable / plistDataType** — ⚠️ DecodingError.dataCorrupted: Data was corrupted. Debug description: AnyDecodable value cannot be decoded
- **AnyCodable + Foundation Codable / plistDateType** — ⚠️ DecodingError.dataCorrupted: Data was corrupted. Debug description: AnyDecodable value cannot be decoded
- **AnyCodable + Foundation Codable / scalarRoot** — ⚠️ EncodingError.invalidValue: "root 😀" (String). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: "root 😀" (String). Debug description: Top-level String encoded as string property list fragment.
- **AnyCodable + Foundation Codable / nullRoot** — ⚠️ EncodingError.invalidValue: nil (Optional<String>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: nil (Optional<String>). Debug description: Top-level Optional<String> encoded as string property list fragment.
- **CodableWrappers + Foundation / int128** — ⚠️ EncodingError.invalidValue: Comparison.ValueBox<Swift.Array<Swift.Int128>>(value: [-170141183460469231731687303715884105728, -1, 0, 170141183460469231731687303715884105727]) (ValueBox<Array<Int128>>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: -170141183460469231731687303715884105728 (Int128). Path: value[0]. Debug description: Encoder has not implemented support for Int128
- **CodableWrappers + Foundation / uint128** — ⚠️ EncodingError.invalidValue: Comparison.ValueBox<Swift.Array<Swift.UInt128>>(value: [0, 340282366920938463463374607431768211455]) (ValueBox<Array<UInt128>>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: 0 (UInt128). Path: value[0]. Debug description: Encoder has not implemented support for UInt128
- **CodableWrappers + Foundation / scalarRoot** — ⚠️ EncodingError.invalidValue: "root 😀" (String). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: "root 😀" (String). Debug description: Top-level String encoded as string property list fragment.
- **CodableWrappers + Foundation / nullRoot** — ⚠️ EncodingError.invalidValue: nil (Optional<String>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: nil (Optional<String>). Debug description: Top-level Optional<String> encoded as string property list fragment.
- **BetterCodable + Foundation / int128** — ⚠️ EncodingError.invalidValue: Comparison.ValueBox<Swift.Array<Swift.Int128>>(value: [-170141183460469231731687303715884105728, -1, 0, 170141183460469231731687303715884105727]) (ValueBox<Array<Int128>>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: -170141183460469231731687303715884105728 (Int128). Path: value[0]. Debug description: Encoder has not implemented support for Int128
- **BetterCodable + Foundation / uint128** — ⚠️ EncodingError.invalidValue: Comparison.ValueBox<Swift.Array<Swift.UInt128>>(value: [0, 340282366920938463463374607431768211455]) (ValueBox<Array<UInt128>>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: 0 (UInt128). Path: value[0]. Debug description: Encoder has not implemented support for UInt128
- **BetterCodable + Foundation / scalarRoot** — ⚠️ EncodingError.invalidValue: "root 😀" (String). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: "root 😀" (String). Debug description: Top-level String encoded as string property list fragment.
- **BetterCodable + Foundation / nullRoot** — ⚠️ EncodingError.invalidValue: nil (Optional<String>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: nil (Optional<String>). Debug description: Top-level Optional<String> encoded as string property list fragment.
- **MetaCodable + Foundation / int128** — ⚠️ EncodingError.invalidValue: Comparison.ValueBox<Swift.Array<Swift.Int128>>(value: [-170141183460469231731687303715884105728, -1, 0, 170141183460469231731687303715884105727]) (ValueBox<Array<Int128>>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: -170141183460469231731687303715884105728 (Int128). Path: value[0]. Debug description: Encoder has not implemented support for Int128
- **MetaCodable + Foundation / uint128** — ⚠️ EncodingError.invalidValue: Comparison.ValueBox<Swift.Array<Swift.UInt128>>(value: [0, 340282366920938463463374607431768211455]) (ValueBox<Array<UInt128>>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: 0 (UInt128). Path: value[0]. Debug description: Encoder has not implemented support for UInt128
- **MetaCodable + Foundation / scalarRoot** — ⚠️ EncodingError.invalidValue: "root 😀" (String). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: "root 😀" (String). Debug description: Top-level String encoded as string property list fragment.
- **MetaCodable + Foundation / nullRoot** — ⚠️ EncodingError.invalidValue: nil (Optional<String>). Debug description: Unable to encode the given top-level value as a property list. Underlying error: EncodingError.invalidValue: nil (Optional<String>). Debug description: Top-level Optional<String> encoded as string property list fragment.
