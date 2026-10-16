# ``Enigmatic``

Inspect and transform Codable values with a typed intermediate tree.

## Overview

``Enigma`` represents nulls, booleans, numbers, strings, arrays, dictionaries,
dates and data. Encode a model into a tree, modify selected paths, merge a second
model, then decode the result. ``Codec`` provides reusable coding strategies that
compose through a property wrapper.

The package requires Swift 6.3. Availability annotations on individual declarations
specify Apple runtime requirements; Linux and Windows use the toolchain runtime.

## Serialization limitations

> Warning: Foundation's Date/Data serialization strategies are bypassed when
> serializing an Enigma tree. Non-finite Float/Double values (`NaN` and
> positive/negative infinity) are not JSON numbers and default JSON encoding
> rejects them. Apply ``Codec/Box`` strategies before building the tree to choose
> a representation independently of Foundation encoder/decoder settings.

Use ``Codec/Base64Data`` for Base64, ``Codec/PlistDate`` or ``Codec/UnixDate``
for date units, and a custom string strategy for non-finite numbers. See
<Serialization> for the limits and <CodingStrategies> for a complete example.

## Compatibility

The package supports macOS, iOS, tvOS, watchOS, visionOS, Linux, and Windows.
Other platforms produce a compile-time error instead of using a fallback implementation.

The manifest leaves deployment targets at SwiftPM's defaults. Some APIs have
higher runtime requirements:

- `Codec.Each`: macOS 14, iOS/tvOS 17, watchOS 10. Use Each2/Each3/Each4 on older systems.
- Int128/UInt128 access: macOS 15, iOS/tvOS 18, watchOS 11, visionOS 2.
- `Codec.UnixDate<scale>` and `Codec.UnixIntDate<scale>`: Apple OS 26.
  Use the named seconds/milliseconds strategies on older systems.

Linux and Windows use the toolchain runtime without Apple OS availability limits.

## Topics

### Value trees

- ``Enigma``
- ``Enigma/Pin``
- ``Enigma/allPaths``
- <TreeOperations>

### Strategies and errors

- ``Codec``
- ``Codec/Strategy``
- ``Codec/DecodeStrategy``
- ``Codec/EncodeStrategy``
- ``Codec/Box``
- ``Codec/OptionalBox``
- ``Codec/OptionalStrategy``
- ``Codec/DecodeOptionalStrategy``
- ``Codec/EncodeOptionalStrategy``
- ``Codec/OptionalDecoder``
- ``Codec/OptionalEncoder``
- ``Codec/Either``
- ``Codec/Each``
- ``Codec/Each2``
- ``Codec/Each3``
- ``Codec/Each4``
- ``Codec/Id``
- ``Codec/Base64Data``
- ``Codec/StringURL``
- ``Codec/PathURL``
- ``Codec/PlistDate``
- ``Codec/UnixDate``
- ``Codec/UnixIntDate``
- ``Codec/UnixSecondsDate``
- ``Codec/UnixMillisecondsDate``
- ``Codec/UnixIntSecondsDate``
- ``Codec/UnixIntMillisecondsDate``
- ``Enigma/CompositeError``
- <CodingStrategies>

### Serialization and compatibility

- <Serialization>

### Development

- <Development>

## Complexity notes

Public executable symbols document their algorithmic complexity in a
`Complexity` entry. For tree APIs, `n` denotes visited values, `d` denotes path
depth, and collection copy-on-write can add work proportional to a modified
collection's size when its storage is shared. Strategy methods include the work
performed by the selected strategy or identify it as delegated work.
