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
- ``Codec/Either``
- ``Codec/Each``
- ``Enigma/CompositeError``
- <CodingStrategies>

### Compatibility

- <Serialization>
- <Migration>
