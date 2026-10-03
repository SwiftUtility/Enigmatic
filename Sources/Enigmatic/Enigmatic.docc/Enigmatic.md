# ``Enigmatic``

Inspect and transform Codable values with a typed intermediate tree.

## Overview

``Enigma`` represents nulls, booleans, numbers, strings, arrays, dictionaries,
dates and data. Encode a model into a tree, modify selected paths, merge a second
model, then decode the result. ``Codec`` provides reusable coding strategies that
compose through a property wrapper.

The package requires Swift 6.3. Availability annotations on individual declarations
specify Apple runtime requirements; Linux uses the toolchain runtime.

## Topics

### Value trees

- ``Enigma``
- ``Enigma/Pin``
- ``Enigma/paths``
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
