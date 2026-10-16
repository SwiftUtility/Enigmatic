---
name: enigmatic-codecs
description: Add, change, or review Enigmatic Codec strategies, Box/OptionalBox wrappers, collection composition, Either, and Each.
---

# Codec strategies and wrappers

Paths here are relative to the repository root. Locate the strategy in
`Sources/Enigmatic/Public/Codec`; read `Codec.swift` only when protocol
relationships matter. Optional keyed behavior also lives in
`Sources/Enigmatic/Public/Extensions/Keyed{Encoding,Decoding}Container.swift`.

Preserve these contracts unless the user requests a behavior change:

- Keep decoding and encoding capabilities separate. Optional strategies expose
  distinct present-payload operations; keyed optional boxes omit nil keys and
  decode missing or null as nil. Test wrappers through synthesized Codable.
- `Either` tries Right first, then Left; both failures remain in CompositeError
  in attempt order. Test fallback after a partial read.
- `Each` writes components to the same encoder. Disjoint keyed components
  combine; overlapping keys, repeated scalars, and repeated unkeyed containers
  conflict, including empty containers. It does not recursively merge.
- Collection strategies transform elements. Set output order is unspecified.
  `Id<Date/Data>` calls Foundation Codable directly rather than handling native
  Enigma date/data nodes.
- Integer date strategies truncate toward zero and can lose round-trip precision.
  Reject non-finite arithmetic, invalid scale factors, and integer overflow.
  Preserve availability on generic Unix strategies and older named alternatives.

Extend `StrategyContractTests`; product composition also uses `ProductTests.swift`
(test class `ContainersTests`). Run the affected class, then `AGENTS.md` checks.
Consult [CodingStrategies.md](../../../Sources/Enigmatic/Enigmatic.docc/CodingStrategies.md)
for representation choices and compatibility. Keep user-facing examples aligned
with `DocumentationExamplesTests`.
