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

## Complexity notes

Public executable symbols document their algorithmic complexity in a
`Complexity` entry. For tree APIs, `n` denotes visited values, `d` denotes path
depth, and collection copy-on-write can add work proportional to a modified
collection's size when its storage is shared. Strategy methods include the work
performed by the selected strategy or identify it as delegated work.
