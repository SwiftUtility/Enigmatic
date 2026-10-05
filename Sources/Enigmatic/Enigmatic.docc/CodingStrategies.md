# Composing coding strategies

Choose a representation independently from a property's Swift value type.

## Property wrappers and collections

```swift
struct Payload: Codable {
  @Codec.Box<Codec.Base64Data> var bytes: Data
  @Codec.Box<Codec.StringURL?> var link: URL?
}
```

When `link` is nil, its key is omitted from keyed output. Decoding treats a
missing or null key as nil. Use `Codec.OptionalBox` when working directly with
the present payload of an optional strategy.

`Base64Data` encodes a Base64 string and rejects malformed input. `StringURL`
uses Foundation's URL initializer, which permits relative URLs; it does not enforce
an HTTP scheme. `Id<T>` delegates to T's own Codable implementation.

Strategy arrays, dictionaries, optionals and sets transform their elements:
`[Codec.Base64Data]`, `[String: Codec.Base64Data?]`, `Set<Codec.Id<Int>>`.
A set removes duplicates and its output order is unspecified. Built-in strategy
types conform to Hashable so they can be used as Set's element type. Optional
values accept explicit null; optional `Codec.Box` properties also support missing
keys and omit nil keys while encoding.

`Codec.Box<Strategy>` exposes `Strategy.BoxedValue` as a wrapped property. The
strategy protocol family separates the boxed value type, whole optional value,
present optional payload, decoding operation and encoding operation. Implement
`DecodeOptionalStrategy` and `EncodeOptionalStrategy` when a custom strategy
needs distinct behavior for nil and present payloads.

## Alternatives and products

``Codec/Either`` tries Right before Left and emits only the selected value. If
both decoders fail, the resulting `dataCorrupted` context contains
``Enigma/CompositeError`` with both errors in attempt order. The same precedence
applies when Either composes two strategies.

``Codec/Each`` reads each component from the same input and writes every component
to the same encoder. Disjoint keyed models combine naturally, including disjoint
children under a shared container key. Arrays written under the same key append;
competing leaf writes or incompatible containers conflict with Enigma's encoder.
Each is not a tuple-array format.
The older Each2/Each3/Each4 types remain available for older Apple runtimes.

`Result<Strategy, any Error>` converts a decoding failure to a Result value.
Encoding a failed Result throws `EncodingError.invalidValue` and retains the
original error in `underlyingError`.

`Base64Data` maps `Data` to Base64 text. `StringURL` uses Foundation's general
URL parser and permits relative URLs. `PathURL` maps file URLs to path strings.
`Id<Value>` delegates to the wrapped value's Codable implementation.

## Dates

`PlistDate` uses seconds since Foundation's reference date (2001-01-01).
`UnixDate<scale>` uses a Double counting units of `10^-scale` seconds since 1970.
`UnixIntDate<scale>` uses Int and truncates toward zero during encoding.
Common scales are 0 (seconds), 3 (milliseconds), and 6 (microseconds).

Non-finite inputs, zero/infinite decimal factors, non-finite results and integer
overflow are rejected. Finite values can still lose precision because Date stores
a floating-point time interval. Use scales appropriate to the required precision.

The generic Unix strategies require Apple OS 26; the named seconds and
milliseconds strategies remain available for older deployment targets.
`PlistDate` instead uses seconds relative to Foundation's 2001 reference date.
