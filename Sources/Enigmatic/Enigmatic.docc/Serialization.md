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
extend the contract beyond JSON. `skipEqual: true` uses the same equality and keeps the
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

`asAny` exports Swift values. It can be read back by `Enigma(cast:)`.
This is an in-memory bridge, not a portable archive format. Swift dictionaries support String, Int, supported AnyHashable bases, and
CodingKeyRepresentable keys. Foundation dictionary keys must bridge to String.
Unsupported keys and collisions are rejected.

`asJsonObject` rejects Date, Data, NaN, infinity and 128-bit integers. Use
JSONSerialization's `fragmentsAllowed` option for a scalar root. `asPlistObject`
rejects null and 128-bit integers. Array/dictionary roots are the portable choice
for property-list document encoding. Conversion errors carry the offending path.

Actual Date/Data model values preserve their native cases at root and nested
positions when building an Enigma tree. Keeping Date native allows property-list
storage using Foundation's 2001
reference epoch. Encoding an existing tree calls Foundation's own `encode(to:)`
for Date/Data at root, array, and keyed positions. With JSONEncoder, dates become
seconds since 2001 and data becomes a byte array, bypassing its date/data encoding
strategies. Apply explicit Codec strategies to model values before building the
tree to control the wire representation. Standard Enigma decoding does not infer
Base64 or date units from arbitrary strings/numbers.

A root Enigma passed to `Enigma(encode:)` is returned directly. Enigma values
embedded in models use their Codable conformance, converting native Date/Data
nodes to reference-date seconds/byte arrays even with Enigma's internal encoder.

`description` and `debugDescription` are for inspection, not machine serialization.

## Errors and context

Encoder and decoder containers propagate userInfo to nested and super containers.
Coding paths retain both stringValue and intValue from the original coding keys.
Missing keyed `decodeNil` throws `keyNotFound`. Null primitive values throw
`valueNotFound`; incompatible non-null values throw `typeMismatch`.
A failed array decode leaves its index unchanged, and `decodeNil()` advances only
when it consumes a null. Exhausted-array errors identify the container path;
type mismatches identify the offending element. Error message wording is diagnostic
and should not be parsed by clients.

Super decoders intentionally accept null for nullable scalar superclass values,
unlike Swift's documented null error. Successfully obtaining an unkeyed super
decoder advances the index even when its value is null.

Encoding is not transactional: catching a child encoding error can leave a
reserved array element or partially written child in the output. Unwritten child
slots become empty dictionaries; a root that encodes nothing throws.
Arena materialization is iterative. Consumer Codable implementations and other
tree operations may still recurse.
