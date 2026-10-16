---
name: enigmatic-tree
description: Change or review Enigma path lookup, tree mutation, allPaths traversal, and merge behavior in Enigmatic.
---

# Enigma tree operations

Paths here are relative to the repository root. Locate the affected method in
`Sources/Enigmatic/Public/Enigma/Capabilities/Enigma+Modification.swift` or
`Enigma+Inspection.swift`; follow it into
`Sources/Enigmatic/Internal/Extensions/Enigma+Utility.swift` or
`Sources/Enigmatic/Internal/Primitives/Enigma+*MergeStrategy.swift` as needed.

Preserve these contracts unless the user requests a behavior change:

- An empty path selects the root: it can replace but cannot delete it. Child
  assignment of nil deletes; `.null` stores null. Reads never coerce containers.
- Non-nil writes create or replace containers to match pins. Array writes append
  only at count. Any invalid index makes the entire write an atomic no-op;
  deletion never creates containers. Preserve independent copies.
- `or:` evaluates its fallback only for a missing read, including read-modify-write;
  stored null and simple assignment do not evaluate it.
- `allPaths` excludes the root, includes empty descendants, and walks depth first
  with sorted dictionary keys and ascending array indices.
- Dictionary pairs merge recursively. Policy merges handle array pairs using
  `arrayAction`; `.zip` recurses by index and retains the longer tail. Throwing
  merges pass other pairs whole to the resolver; new keys bypass it. Failures
  leave the original intact. Dictionary resolver order is unspecified.

Extend `TreeContractTests` for the affected boundary; `OperationsTests` covers
basic usage. Run `swift test --filter TreeContractTests`, then the shared checks
in `AGENTS.md`. For detailed semantics, read
[TreeOperations.md](../../../Sources/Enigmatic/Enigmatic.docc/TreeOperations.md).
