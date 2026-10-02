# Composing coding strategies

Choose a representation independently from a property's Swift value type.

## Property wrappers and collections

```swift
struct Payload: Codable {
  @Codec.Box<Codec.Base64Data> var bytes: Data
  @Codec.Box<Codec.StringURL?> var link: URL?
}
```

`Base64Data` encodes a Base64 string and rejects malformed input. `StringURL`
uses Foundation's URL initializer, which permits relative URLs; it does not enforce
an HTTP scheme. `Id<T>` delegates to T's own Codable implementation.

Strategy arrays, dictionaries, optionals and sets transform their elements:
`[Codec.Base64Data]`, `[String: Codec.Base64Data?]`, `Set<Codec.Id<Int>>`.
A set removes duplicates and its output order is unspecified. Built-in strategy
types conform to Hashable so they can be used as Set's element type.
An optional strategy accepts explicit null; a missing wrapped-property key still
follows synthesized Codable behavior and throws `keyNotFound`.

## Alternatives and products

``Codec/Either`` tries Right before Left and emits only the selected value. If
both decoders fail, the resulting `dataCorrupted` context contains
``Enigma/CompositeError`` with both errors in attempt order. The same precedence
applies when Either composes two strategies.

``Codec/Each`` reads each component from the same input and writes every component
to the same encoder. Disjoint keyed models combine naturally; overlapping keys
or scalar writes conflict with Enigma's encoder. Each is not a tuple-array format.
The older Each2/Each3/Each4 types remain available for older Apple runtimes.

`Result<Strategy, any Error>` converts a decoding failure to a Result value.
Encoding a failed Result throws `EncodingError.invalidValue` and retains the
original error in `underlyingError`.

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
