# Serialization and numeric contracts

Distinguish the typed tree from a format-specific representation.

## Numeric values

The tree keeps explicit numeric cases. Integer accessors accept only exactly
representable values, so fractions and overflow fail. Integer-to-floating-point
conversion also requires exact representability. Double-to-Float allows rounding
and underflow, but rejects finite overflow; non-finite values remain non-finite.

Enigma equality compares representable numeric values across cases. It treats
NaN as equal to NaN, and Float/Double comparisons use Float rounding. Consequently,
this equality should not be used as a substitute for exact numeric precision
checks. Enigma does not conform to Hashable.

## Foundation and external encoders

`rawAny` exports Swift values. It can be read back by `Enigma(cast:)`.
This is an in-memory bridge, not a portable archive format. Dictionary keys supplied
to `cast` are converted to their string descriptions; colliding descriptions are rejected.

`jsonObject` rejects Date, Data, NaN, infinity and 128-bit integers. Use
JSONSerialization's `fragmentsAllowed` option for a scalar root. `plistObject`
rejects null and 128-bit integers. Array/dictionary roots are the portable choice
for property-list document encoding. Conversion errors carry the offending path.

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
