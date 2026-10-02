# Migrating to the revised tree contracts

Update code that depends on root representations or malformed bridge values.

## Paths

Replace `tree.pathes` with `tree.paths`. The old spelling remains as a deprecated
alias. Previously the traversal always returned an empty array; it now includes
all descendants in deterministic depth-first order, excluding the root.

## Root Date and Data

`Enigma(encode: date)` now produces `.date(date)` instead of the Foundation
reference-date Double. `Enigma(encode: data)` now produces `.data(data)` instead of
an array of bytes. This matches nested values. `decode(Date.self)` and
`decode(Data.self)` read the native cases, and legacy scalar/array representations
remain decodable.

Code that inspects enum cases or uses root `jsonObject` must adapt. To request an
explicit representation, use `Codec.Box<Codec.PlistDate>`, `Codec.Box<Codec.Base64Data>`
or encode `Array(data)` for a byte array. Root Date/Data previously passed through
`jsonObject` via their scalar/array shapes; native Date/Data cases are rejected.

## Containers, dates and strategies

Repeated unkeyed-container requests now share their existing storage. The count
tracks appended children, including nested containers and super encoders.
Incompatible container types and duplicate writes still throw on writing.

Invalid decimal date factors now throw instead of silently producing zero in
some cases. Integer date encoding accepts the exactly representable Int.min
boundary and retains its exclusive upper bound to avoid a conversion trap.
Built-in strategy types now conform to Hashable, allowing Set-based composition.

## 128-bit Foundation bridging

Apple bridges now use the correct `t`/`T` Objective-C encodings with terminated
C strings. Linux uses an internal NSObject wrapper because corelibs Foundation
does not implement these NSValue encodings. Do not persist or depend on the
concrete object class returned by `rawObject`; use a defined wire format instead.
Native Int128/UInt128 exported through `rawAny` can now be passed to `Enigma(cast:)`.
