---
name: enigmatic-numbers
description: Change or review Enigma numeric identity, typed number accessors, Float/Double conversion, and Int128/UInt128 support.
---

# Enigma numeric contracts

Paths here are relative to the repository root. Start with the affected accessor
in `Sources/Enigmatic/Public/Enigma/Capabilities/Enigma+Conversion.swift` or
equality in `Sources/Enigmatic/Public/Enigma/Enigma.swift`. Follow numeric helpers
in `Sources/Enigmatic/Internal/Extensions/Enigma+Comparison.swift` and
`Double.swift`; inspect `Public/Enigma/Primitives/Enigma+*128Box.swift` under the
same library root only for 128-bit work.

Preserve these contracts unless the user requests a behavior change:

- Integer storage widths do not change numeric equality. Compare exact values
  without routing large integers through lossy Double conversion. Enigma treats
  NaNs as equal and signed zeros as equal; it has no Hashable conformance.
- Float inputs widen to Double with their binary value intact; Float(0.1) is not
  the same stored value as Double(0.1).
- Integer accessors require exact, in-range values. `asDouble` requires exact
  integer representability. `asFloat` first requires that same Double conversion
  for integer inputs, then rounds; reject finite overflow and nonzero underflow
  to zero, while preserving NaN and infinity.
- Keep 128-bit availability guards and box value semantics. Copy mutation must
  not affect the original box.

Extend `NumericContractTests` or `EquatableTests` with the relevant range or
identity boundary. For box bridging, also inspect `SerializationContractTests`.
Run the affected class with `swift test --filter <TestClass>`, then `AGENTS.md`
checks. Consult the numeric section of
[Serialization.md](../../../Sources/Enigmatic/Enigmatic.docc/Serialization.md)
for conversion examples.
