# Serialization and numeric contracts

Distinguish the typed tree from a format-specific representation.

## Numeric values

The tree keeps explicit numeric cases. Integer accessors accept only exactly
representable values, so fractions and overflow fail. Integer-to-floating-point
conversion also requires exact representability. Double-to-Float allows rounding
and underflow, but rejects finite overflow; non-finite values remain non-finite.

Enigma equality compares normalized shortest decimal representations across all
numeric cases. Float and Double literals `0.1` compare equal, but both differ from
`Double(Float(0.1))`, whose decimal representation is `0.10000000149011612`.
Integer widths and equivalent decimal/exponent forms are ignored. This comparison
supports JSON-style untyped access, independently of exact typed conversions.
For example, Float `1e12` equals integer `1000000000000`, although its exact binary
integer value is `999999995904`. Equality does not guarantee identical storage,
bits, or successful typed conversion. NaNs compare equal, including Date
timestamps, and positive and negative zero compare equal. These non-finite rules
extend the contract beyond JSON. `skipEqual` uses the same equality and keeps the
existing value. Enigma does not conform to Hashable.

External decoding tries integer types before floating-point types, including
128-bit integers on supported systems. Floating downscaling and literals preserve
both exact binary values and decimal equality, but may normalize negative zero to
integer zero. JSON loses Float/Double width: Float `0.1` reads into an untyped tree
as Double `0.1`, which compares equal. Typed decoding restores the original Float.
Equality uses Swift's shortest decimal number descriptions, rather than calling
an encoder. Other encoders or Foundation NSNumber bridging may widen Float and
change its decimal representation even when the binary value is preserved.

## Foundation and external encoders

`asSwiftAny` exports Swift values. It can be read back by `Enigma(cast:)`.
This is an in-memory bridge, not a portable archive format. Dictionary keys supplied
to `cast` are converted to their string descriptions; colliding descriptions are rejected.

`asJsonObject` rejects Date, Data, NaN, infinity and 128-bit integers. Use
JSONSerialization's `fragmentsAllowed` option for a scalar root. `asPlistObject`
rejects null and 128-bit integers. Array/dictionary roots are the portable choice
for property-list document encoding. Conversion errors carry the offending path.

Root and nested Date/Data preserve their native cases when building an Enigma
tree. Keeping Date native allows property-list storage using Foundation's 2001
reference epoch. Encoding an existing tree calls Foundation's own `encode(to:)`
for Date/Data at root, array, and keyed positions. With JSONEncoder, dates become
seconds since 2001 and data becomes a byte array, bypassing its date/data encoding
strategies. Apply explicit Codec strategies to model values before building the
tree to control the wire representation. Standard Enigma decoding does not infer
Base64 or date units from arbitrary strings/numbers.

`description` and `debugDescription` are for inspection, not machine serialization.

## Errors and context

Encoder and decoder containers propagate userInfo to nested and super containers.
Decoding failures distinguish missing keys, mismatched types and exhausted arrays.
A failed array decode leaves its index unchanged, and `decodeNil()` advances only
when it consumes a null. Exhausted-array errors identify the container path;
type mismatches identify the offending element. Error message wording is diagnostic
and should not be parsed by clients.
