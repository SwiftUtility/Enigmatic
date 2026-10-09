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
representable as `Double`. `asFloat` returns the nearest `Float` unless conversion
overflows to infinity or underflows a nonzero finite value to zero. NaN and
infinity are preserved by floating-point accessors.

## Foundation and external encoders

`asAny` exports nested Swift/Foundation values. It can be read back by `Enigma(cast:)`.
This is an in-memory bridge, not a portable archive format. `cast` supports string
and integer dictionary keys, `AnyHashable` keys with string-convertible bases, and
`CodingKeyRepresentable` keys on supported runtimes. Keys normalize to strings;
collisions and unsupported key types produce a decoding error. Arrays and sets
convert to arrays, with set order unspecified.

`asJsonObject` rejects Date, Data, NaN, infinity and 128-bit integers. Use
JSONSerialization's `fragmentsAllowed` option for a scalar root. `asPlistObject`
rejects null and 128-bit integers. Array/dictionary roots are the portable choice
for property-list document encoding. Conversion errors carry the offending path.

`Enigma.encode(to:)` encodes floating-point values as `Double`. A `Float` passed
through an Enigma encoder has already been widened to `Double`, so this does not
preserve its original Float type. `asJsonObject` and `asPlistObject` also expose
ordinary floating-point numbers without a Float/Double type tag. A serializer
round trip preserves numeric identity when its parsed `Double` value is unchanged.
`asFloat` can then produce the nearest Float if conversion does not overflow or
underflow a nonzero finite value to zero.

Root and nested Date/Data preserve their native cases when building an Enigma
tree. Encoding that tree through an external encoder preserves the existing
position-dependent behavior: keyed Date/Data values pass through the external
encoder's strategies, while root and array nodes call Foundation's own
`encode(to:)`. Use explicit Codec strategies to control the wire representation
consistently. Standard Enigma decoding does not infer Base64 or date units from
arbitrary strings/numbers.

`description` and `debugDescription` are for inspection, not machine serialization.

## Errors and context

Encoder and decoder containers propagate userInfo to nested and super containers.
Decoding failures distinguish missing keys, mismatched types and exhausted arrays.
A failed array decode leaves its index unchanged, and `decodeNil()` advances only
when it consumes a null. Exhausted-array errors identify the container path;
type mismatches identify the offending element. Error message wording is diagnostic
and should not be parsed by clients.
