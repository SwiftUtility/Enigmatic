# Serialization and numeric contracts

Distinguish the typed tree from a format-specific representation.

## Numeric identity and conversion

The tree stores integers in width-specific integer cases and floating-point values
in a `Double` case. A `Float` passed to an Enigma encoder is widened to `Double`
before it enters the tree, preserving the exact numeric value of that `Float`.
Numeric equality compares stored values, regardless of integer storage width. For
example, a Float value `f` is equal to `.double(Double(f))`, and can differ from
`.double(0.1)` when `f` is `Float(0.1)`. NaN values compare equal to one another,
and positive and negative zero compare equal. `Enigma` does not conform to
`Hashable`.

Integer accessors return a value only when the stored number is an exact integer
within the destination range. `asDouble` requires integer values to be exactly
representable as `Double`. `asFloat` first requires integer inputs to be exactly
representable as `Double`, then rounds to `Float`. Stored Double inputs go
straight to that rounding step. Conversion returns nil if a finite number
overflows to infinity or a nonzero number underflows to zero. NaN and infinity
are preserved.

The intermediate Double requirement matters: `.int64(16_777_217).asFloat`
rounds to `16_777_216`, but `.int64(9_007_199_254_740_993).asFloat` returns nil
even though that integer is within Float's range. Float decoding uses the same
accessor.

## Foundation and external encoders

> Warning: Enigma trees bypass Foundation's Date/Data serialization strategies.
> Non-finite Float/Double values also need a format-specific representation for
> JSON. Apply `Codec.Box` strategies to the source model before building the tree
> to avoid relying on Foundation encoder/decoder settings; see <CodingStrategies>
> for an explicit Data/Date/Float/Double example.

`asAny` exports nested Swift/Foundation values that `Enigma(cast:)` can read back.
On systems without native Int128/UInt128 support, the 128-bit cases export their
box types instead; those boxes cannot be read back through `cast`.
This is an in-memory bridge, not a portable archive format. Swift dictionaries
support `String` and `Int` keys, `AnyHashable` keys whose bases are String or
8-, 16-, 32-, 64-bit or platform-sized integers, and `CodingKeyRepresentable`
keys on supported runtimes. Direct Int8/UInt64-keyed dictionaries are unsupported;
wrapping those keys in AnyHashable enables conversion. Foundation dictionaries
require keys that bridge to String. Keys normalize to strings;
collisions and unsupported key types produce a decoding error. Arrays and sets
convert to arrays, with set order unspecified.

Boxed Foundation booleans remain boolean nodes, distinct from numeric zero and
one, including on Windows where CoreFoundation is not exposed by the SDK.

On all platforms, `Enigma(cast:)` converts `NSDecimalNumber` values by
parsing their `stringValue` with `Double.init(_:)`, rather than reading
`doubleValue`. This avoids precision loss in Foundation's decimal-to-Double
bridge, including numbers returned by Linux `JSONSerialization`. It does not
recover digits already lost while parsing a decimal. If the string cannot be
parsed as Double, conversion fails with a decoding error. Other NSNumber values
retain their Foundation conversion.

`asJsonObject` rejects Date, Data, NaN, infinity and 128-bit integers. Use
JSONSerialization's `fragmentsAllowed` option for a scalar root. `asPlistObject`
retains Date/Data as native Foundation objects and rejects null and 128-bit
integers. Array/dictionary roots are the portable choice
for property-list document encoding. Conversion errors carry the offending path.

`Enigma.encode(to:)` encodes floating-point values as `Double`. A `Float` passed
through an Enigma encoder has already been widened to `Double`, so this does not
preserve its original Float type. `asJsonObject` and `asPlistObject` also expose
ordinary floating-point numbers without a Float/Double type tag. A serializer
round trip preserves numeric identity when its parsed `Double` value is unchanged.
`asFloat` can then round a stored Double back to Float subject to the range
checks above.

Date/Data values passed through Enigma's encoding containers retain their native
cases, at the root and in collections. Calling Date/Data's `encode(to:)` directly
uses Foundation's Codable representation instead.

When an Enigma tree is encoded by an external encoder, Date/Data nodes call
Foundation's own `encode(to:)` at every position, including dictionary fields.
Date becomes seconds since 2001-01-01; Data becomes an array of bytes. This
bypasses JSONEncoder's `dateEncodingStrategy` and `dataEncodingStrategy` and
PropertyListEncoder's native Date/Data handling.

For example, a tree containing a date at the Unix epoch and two bytes produces
this JSON even with `.secondsSince1970` and `.base64` selected:

```json
{"date": -978307200, "bytes": [1, 255]}
```

Use `@Codec.Box<Codec.Base64Data>` for Base64 data and a date strategy such as
`Codec.PlistDate` (reference-date seconds) or `Codec.UnixDate<0>` (Unix seconds
on supported runtimes) before building the tree to choose a wire format.
`Enigma.init(from:)` does not recognize date units or Base64 text on its own.
Decoding a native `.date` or `.data` node as Date or Data returns the stored value;
other representations follow Foundation's Decodable implementation.

Decoding Enigma from Enigma's own decoder preserves the stored tree directly,
including native Date/Data, integer storage widths and non-finite numbers. This
also applies to Enigma properties and array elements. External decoders still
infer tree cases from the containers and value types they support.

### Non-finite Float and Double values

`Float.nan`, `Double.nan`, and positive/negative infinity can be stored in an
Enigma tree. They are not JSON numbers: default JSONEncoder encoding throws,
and `asJsonObject` rejects them. Float inputs have already been widened to Double.

JSONEncoder's `nonConformingFloatEncodingStrategy = .convertToString(...)` can
write these nodes as strings. A matching JSONDecoder
`nonConformingFloatDecodingStrategy = .convertFromString(...)` can recover them
as non-finite numbers when decoding Enigma. Without that decoding setting, the
special tokens remain strings. These settings belong to the external Foundation
encoder and decoder: `Enigma(encode:)` and `tree.decode(...)` do not expose them.
`asJsonObject` also does not apply these strategies.

For a format independent of Foundation encoder settings, use `Codec.Box` with a
custom strategy that explicitly encodes and decodes string tokens for Float or
Double. The example in <CodingStrategies> handles both types. `Codec.CanonicalFloat`
preserves non-finite values as numbers in memory and is not a string-token strategy.

`description` and `debugDescription` are for inspection, not machine serialization.

## Errors and context

Encoder and decoder containers propagate userInfo to nested and super containers.
Decoding failures distinguish missing keys, mismatched types and exhausted arrays.
A failed array decode leaves its index unchanged, and `decodeNil()` advances only
when it consumes a null. Exhausted-array errors identify the container path;
type mismatches identify the offending element. Error message wording is diagnostic
and should not be parsed by clients.

### Encoding containers and recovery

The encoder allows repeated keyed-container requests on the same encoder;
their handles share storage. Each key can be assigned only once, including by
requesting a nested container or super encoder. Reopening a child through another
nested-container or super-encoder request is a conflict, even if that child is
empty. Use the original child handle to continue writing.

Requesting a second unkeyed container on the same encoder is a conflict even
when the first is empty or the second is never used. Reusing the original
unkeyed handle works. Requesting an incompatible container kind, or requesting
a keyed/unkeyed container after writing a single value, also causes a conflict.

Container acquisition methods cannot throw, so these conflicts are recorded.
Later writes and the enclosing `Enigma(encode:)` throw `EncodingError.invalidValue`
with the first conflict's path, even if an intermediate write error was caught
or no further writes were attempted. This also applies when a generic keyed
encode requests an encoder for an occupied key.

Direct duplicate value writes, including Date, Data and Enigma values passed
through encoding containers, throw immediately and can be caught without
invalidating the whole encoding. Calling an Enigma value's `encode(to:)` directly
instead uses its container traversal, so conflicting container requests follow
the rules above. A caught error from a child's own Encodable implementation can
leave that child partially written; encoding does not roll back successful writes.
Throwing tree merges leave the original tree unchanged.
