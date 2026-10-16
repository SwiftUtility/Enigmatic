---
name: enigmatic-codable
description: Change or review Enigma encoder/decoder containers, coding paths, serialization, and Swift/Foundation object bridging.
---

# Enigma Codable and bridging

Paths here are relative to the repository root. For containers, inspect only the
affected keyed, unkeyed, or single files in
`Sources/Enigmatic/Internal/EnigmaEncoder` or `EnigmaDecoder`. For serialization
or casting, locate the method in `Public/Enigma/Enigma.swift`,
`Public/Enigma/Capabilities/Enigma+Conversion.swift`, `Internal/Extensions`, or
`Internal/Primitives/EnigmaConvertible*.swift`, all under `Sources/Enigmatic`.

Preserve these contracts unless the user requests a behavior change:

- Keep codingPath keys and userInfo through nested and super containers.
  Distinguish missing, null, mismatched values, and array exhaustion. Failed
  unkeyed reads do not advance; `decodeNil()` advances only for null.
- Keyed handles share storage; reopening unkeyed or occupied child containers
  records a conflict. Completion throws the first recorded acquisition error.
  Direct duplicate value writes can be caught without invalidating encoding;
  successful partial writes are not rolled back.
- Date/Data retain native nodes through Enigma containers. External tree encoding
  calls Foundation Codable directly, bypassing external date/data strategies.
- Object bridge keys normalize to strings; reject collisions and unsupported
  keys with their paths. JSON objects reject Date/Data, non-finite numbers, and
  128-bit integers; plist objects reject null and 128-bit integers.

Select `ContainerContractTests`, `CodingPathContractTests`,
`EnigmaEncodingContractTests`, or `SerializationContractTests` by behavior.
Run the affected class, then `AGENTS.md` checks. Read the relevant section of
[Serialization.md](../../../Sources/Enigmatic/Enigmatic.docc/Serialization.md)
for recovery or bridge details.
