# Project guidance

Enigmatic is a dependency-free SwiftPM library for Codable value trees and
composable coding strategies. It requires Swift 6.1; generic Unix date strategies
require Swift 6.2.3. Checks separately tests the original Swift 6.1 release,
Swift 6.2.3, and Swift 6.4.1 on macOS, Linux, and Windows in Debug and Release.
Coverage and DocC use macOS with Swift 6.2.3. Release uses 6.3.3 to build the
previous API baseline.

Follow the existing two-space Swift style. Preserve typed throws, runtime
availability guards, and visibility required by `@inlinable` code. Update the
relevant contract tests and DocC guide when public behavior changes.

## Selective skills

Read only the skill matching the task; combine skills when the change crosses
domains. Paths below are relative to the repository root.

| Task | Skill |
| --- | --- |
| Paths, traversal, mutation, merging | [enigmatic-tree](.agents/skills/enigmatic-tree/SKILL.md) |
| Numeric equality, conversion, 128-bit values | [enigmatic-numbers](.agents/skills/enigmatic-numbers/SKILL.md) |
| Encoder/decoder containers, serialization, Foundation bridging | [enigmatic-codable](.agents/skills/enigmatic-codable/SKILL.md) |
| Property wrappers and coding strategies | [enigmatic-codecs](.agents/skills/enigmatic-codecs/SKILL.md) |

## Context budget

Use `rg` to locate symbols, then read the relevant ranges. Exclude `.build`,
`.swiftpm`, and `.git` from source searches. Load linked guides only when needed;
keep guidance concise and avoid duplicating existing documentation. Keep long
command output in a temporary log and report the result and relevant failures.

## Validation

While iterating, use `swift test --filter <TestClass>`. For Swift behavior changes,
finish with `swift test --skip PerformanceTests` and
`swift test -c release --skip PerformanceTests`.

For coverage, benchmarks, DocC, or CI work, read
[Development.md](Sources/Enigmatic/Enigmatic.docc/Development.md) and the relevant
workflow in `.github/workflows`. Guidance-only edits need frontmatter and path
checks rather than a Swift rebuild.
