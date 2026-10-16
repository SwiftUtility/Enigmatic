# Composing coding strategies

Choose a representation independently from a property's Swift value type.

## Property wrappers and collections

```swift
import Foundation
import Enigmatic

struct Payload: Codable {
  @Codec.Box<Codec.Base64Data> var bytes: Data
  @Codec.Box<Codec.StringURL?> var link: URL?
}
```

When `link` is nil, its key is omitted from keyed output. Decoding treats a
missing or null key as nil. Use `Codec.OptionalBox` when working directly with
the present payload of an optional strategy.

Use `Codec.Nullable<Strategy>` when a key must be present even when its value
is nil:

```swift
struct Customer: Codable {
  @Codec.Box<Codec.Nullable<Codec.Id<String>>> var phone: String?
  @Codec.Box<Codec.Nullable<Codec.Base64Data>> var avatar: Data?
}
```

Nil properties encode as explicit null. Decoding accepts null as nil and delegates
present values to the wrapped strategy. A missing key throws `keyNotFound`, and
invalid present values retain the wrapped strategy's errors. Decoding and encoding
capabilities are independent, just as for optional strategies.

`Base64Data` encodes a Base64 string and rejects malformed input. `StringURL`
uses Foundation's URL initializer, which permits relative URLs; it does not enforce
an HTTP scheme. `PathURL` turns filesystem paths into file URLs and encodes their
unescaped absolute paths. Relative paths resolve against the process's working directory;
the original relative spelling and URL base are not preserved. Encoding a
non-file URL still writes only its path.
On Windows, `PathURL` accepts drive and network paths with either slash style.
It encodes forward slashes, keeps drive prefixes such as `C:/` without an extra
leading slash, and preserves trailing directory separators. Other platforms
retain their existing Foundation and FilePath normalization.

Strategy arrays, dictionaries, optionals and sets transform their elements:
`[Codec.Base64Data]`, `[String: Codec.Base64Data?]`, `Set<Codec.Id<Int>>`.
A set removes duplicates and its output order is unspecified. Built-in strategy
types conform to Hashable so they can be used as Set's element type. Optional
values accept explicit null; optional `Codec.Box` properties also support missing
keys and omit nil keys while encoding.

On macOS 13, iOS 16, tvOS 16 and watchOS 9 or newer, dictionary strategies stream
entries when their keys conform to `CodingKeyRepresentable`. Other keys use
Swift's Codable dictionary format, including alternating key/value arrays for
keys such as Bool. JSON key strategies apply to streamed keys.

`Codec.CodingKeyedDictionary<Key, Value>` (also `[Key: Value].CodingKeyed`) selects
the keyed format explicitly and does not require Key to be Codable. It requires
`CodingKeyRepresentable`, available from macOS 12.3, iOS 15.4, tvOS 15.4 and
watchOS 8.5. Decoding rejects unrecognized keys and distinct spellings that map
to the same key, including entries whose values are null.

`Codec.Box<Strategy>` exposes `Strategy.BoxedValue` as a wrapped property. The
strategy protocol family separates the boxed value type, whole optional value,
present optional payload, decoding operation and encoding operation. Implement
`DecodeOptionalStrategy` and `EncodeOptionalStrategy` when a custom strategy
needs distinct behavior for nil and present payloads.

`Id<T>` calls T's Codable methods directly. For Date and Data, this uses
Foundation's own representation and bypasses the encoder's type-specific
strategies. An `Id<Date>` or `Id<Data>` box cannot decode Enigma's native `.date`
or `.data` nodes; plain Date/Data properties can. Use Base64Data or a date codec
when choosing a specific representation.

## Explicit portable representations

> Warning: When serializing an Enigma tree, Foundation's date/data strategies
> and PropertyListEncoder's native Date/Data handling are bypassed. Non-finite
> Float/Double values (`NaN`, positive infinity and negative infinity) also need
> an explicit representation for portable JSON. External Foundation encoders and
> decoders support matching nonconforming-float string strategies, but Enigma's
> own model/tree conversions expose no such settings. See <Serialization> for
> the exact behavior.

Apply `Codec.Box` strategies before building the tree. Use `Base64Data` for Data
and `PlistDate` for seconds since 2001-01-01; `UnixSecondsDate` is an alternative
for Unix seconds on all supported compilers. For Float and Double, define a string
strategy that preserves special values explicitly:

```swift
import Foundation
import Enigmatic

enum FloatingPointString<Value: BinaryFloatingPoint & LosslessStringConvertible>:
  Codec.DecodeStrategy, Codec.EncodeStrategy {
  typealias BoxedValue = Value

  static func decode(decoder: some Decoder) throws -> Value {
    let text = try String(from: decoder)
    guard let value = Value(text) else {
      throw DecodingError.dataCorrupted(.init(
        codingPath: decoder.codingPath,
        debugDescription: "Invalid floating-point string: \(text)"
      ))
    }
    return value
  }

  static func encode(value: Value, encoder: some Encoder) throws {
    try String(value).encode(to: encoder)
  }
}

struct PortablePayload: Codable {
  @Codec.Box<Codec.Base64Data> var bytes: Data
  @Codec.Box<Codec.PlistDate> var date: Date
  @Codec.Box<FloatingPointString<Float>> var sample: Float
  @Codec.Box<FloatingPointString<Double>> var reading: Double
}

let payload = PortablePayload(
  bytes: Data([1, 2, 3]),
  date: Date(timeIntervalSinceReferenceDate: 0),
  sample: .nan,
  reading: .infinity
)
let tree = try Enigma(encode: payload)
let json = try JSONEncoder().encode(tree)
// {"bytes":"AQID","date":0,"sample":"nan","reading":"inf"} (key order varies)
let decodedTree = try JSONDecoder().decode(Enigma.self, from: json)
let restored = try decodedTree.decode(PortablePayload.self)
// restored.sample.isNaN == true; restored.reading == .infinity
```

This custom strategy writes all floating-point values, including finite ones,
as strings. It also accepts `"-inf"` for negative infinity. It requires no
Foundation date/data or nonconforming-float strategy settings. Built-in
`CanonicalFloat` controls finite decimal representation and does not replace
this strategy for JSON-safe special values.

## Float representation

`CanonicalFloat` stores a Float using its shortest decimal spelling as a Double.
For example, `Float(0.1)` becomes `.double(0.1)` instead of the exact binary
widening used by ordinary Float properties. Decoding parses the Double's decimal
spelling as Float and rejects finite overflow and nonzero underflow to zero.
Signed zero, NaN and infinity are preserved in memory; the external encoder
still decides whether non-finite values can be serialized.

## Alternatives and products

``Codec/Either`` tries Right before Left and emits only the selected value. If
both decoders fail, the resulting `dataCorrupted` context contains
``Enigma/CompositeError`` with both errors in attempt order. The same precedence
applies when Either composes two strategies.
The Decodable form calls each alternative's initializer directly, so a native
Date/Data node also cannot be decoded by `Either<Date, Data>`. The strategy form
uses the selected strategies' decode operations.

``Codec/Each`` reads each component from the same input and writes every component
to the same encoder. Disjoint keyed models and Enigma dictionaries combine
naturally. Enigma's encoder rejects overlapping keys even when their values are
equal or contain disjoint nested dictionaries; Each does not recursively merge
them. Repeated scalar writes and multiple unkeyed components also conflict,
including empty arrays. Each is not a tuple-array format. The older
Each2/Each3/Each4 types remain available for older Apple runtimes and follow the
same composition rules.
Each products expose writable tuple members through key paths, for example
`product.0`. This also applies to Each2/Each3/Each4.

`Result<Strategy, any Error>` converts a decoding failure to a Result value.
Encoding a failed Result throws `EncodingError.invalidValue` and retains the
original error in `underlyingError`.

## Dates

`PlistDate` uses seconds since Foundation's reference date (2001-01-01).
`UnixDate<scale>` uses a Double counting units of `10^-scale` seconds since 1970.
`UnixIntDate<scale>` uses Int and truncates toward zero during encoding.
Common scales are 0 (seconds), 3 (milliseconds), and 6 (microseconds).

Non-finite inputs, zero/infinite decimal factors, non-finite results and integer
overflow are rejected. Date stores a floating-point time interval, so an integer
timestamp need not survive a decode/encode round trip unchanged. For example,
`UnixIntDate<3>` decodes `2` milliseconds after 1970 and re-encodes it as `1`:
the stored interval is just below two milliseconds, and encoding truncates toward
zero. The named integer strategies have the same precision limitation.

The generic Unix strategies require Swift 6.2.3 or newer. On Apple platforms,
they also require OS 26. With earlier compilers or older deployment targets, use
`UnixSecondsDate` / `UnixIntSecondsDate` or
`UnixMillisecondsDate` / `UnixIntMillisecondsDate`. The named strategies are
deprecated on Apple OS 26 only when compiled with Swift 6.2.3 or newer; earlier
compilers retain them without deprecation warnings. Other scales require the
generic strategies or a custom strategy.

For example, this model uses integer milliseconds on every supported compiler:

```swift
struct Event: Codable {
  @Codec.Box<Codec.UnixIntMillisecondsDate> var timestamp: Date
}

let event = Event(timestamp: Date(timeIntervalSince1970: -123.25))
let tree = try Enigma(encode: event)
// {"timestamp": -123250}
```

## Complexity

Scalar transformations such as URL and date strategies use constant-time
arithmetic apart from parsing or formatting their strings. Base64 conversion is
linear in the data size. Array and set strategies visit each element once;
dictionary strategies visit each entry once on average. The cost of nested
strategies is additional and accumulates across the elements. Streamed keyed
dictionaries avoid an intermediate boxed dictionary. `Either` attempts
the right strategy first and attempts the left only if the right fails, so its
worst-case decode cost is the sum of both alternatives.
