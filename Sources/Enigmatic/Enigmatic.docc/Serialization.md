# Serialization and numeric contracts

Distinguish the typed tree from a format-specific representation.

## Numeric identity and conversion

The tree keeps explicit numeric cases. A finite Float or Double is identified by
its shortest round-trip decimal components; integer cases use their exact decimal
value. Numeric equality compares these canonical values, not IEEE bit patterns or
storage cases. For example, `.float(0.1)` equals `.double(0.1)`, while
`.float(0.1)` does not equal `.double(Double(Float(0.1)))`.

Numeric accessors succeed only when the destination has the same canonical value.
This is stricter than ordinary floating-point rounding and is not the same as
requiring the source's binary fraction to be exactly representable. Integer
accessors additionally require an integral canonical value within the destination
range. Finite overflow or a changed canonical value returns nil. NaN and infinity
are preserved by Float/Double accessors; integer accessors reject them. NaN values
compare equal to one another, and positive and negative zero compare equal.
`Enigma` does not conform to `Hashable`.

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

The Codable path preserves the numeric type at the encoder boundary:
`Enigma.encode(to:)` passes a `.float` case to the supplied `Encoder` as `Float`.
The legacy Foundation bridges `asJsonObject` and `asPlistObject` instead box it as
an `NSNumber` for `JSONSerialization` and `PropertyListSerialization`. Those
serializers write an ordinary number without a Float/Double type tag, so a bridged
Float can come back as a Double with different canonical components. In that case
the Float accessor returns nil and numeric equality with the original Float is
false. A Codable encoder can also target an untyped format; passing Float to it
does not add a type tag to that format. A wire-format round trip preserves numeric
identity only when the serialized decimal output has the same canonical
components.

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
