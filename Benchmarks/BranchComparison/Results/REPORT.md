# Current branch vs previous Enigmatic and AnyCodable

Current: `vova/json-codec` at `1c7615f`. Previous: `v3.0.0` (`b28cb62`), the version used in the earlier comparison. AnyCodable: **0.6.7**, pinned to `862808b`. All versions were rebuilt and rerun.

## Findings

- The common Foundation decoder path is effectively unchanged: **301.69 → 302.44 ms** (+0.25%). AnyCodable still takes less time on this path (**221.34 ms**).
- The new Codec parser takes **20.29 ms**: **14.87× faster** than the previous Foundation decoder path, and **2.47× faster** than the previous JSONSerialization + cast path.
- Codec writing is weaker here: **38.89 ms**, versus **24.48 ms** with JSONEncoder. Both sort keys.
- AnyCodable wrapping native JSONSerialization objects remains faster for plain JSON: **9.14 ms** to read, **29.59 ms** for read/edit/write, and **52.59 MiB** retained RSS growth. It does not build an Enigma tree or provide its path and merge APIs.
- The new parser does not reduce retained memory: Codec uses **152.67 MiB** RSS growth, versus **150.05 MiB** with Foundation decoding.
- The direct Enigma model/tree bridge remains useful. AnyCodable needs an intermediate JSON route; using its faster native-object route narrows the difference substantially. Both routes are shown below.

## Same Foundation JSONDecoder backend

10,000 records; **1,697,836 UTF-8 bytes**. Times are milliseconds per operation; lower is better. All JSON writers in the wire-output tasks sort keys.

| Operation | Previous Enigma | Current Enigma | AnyCodable |
| --- | --- | --- | --- |
| JSON → tree | 301.6883 | 302.4446 | 221.3448 |
| Tree → JSON, sorted keys | 24.1742 | 24.4843 | 125.3665 |
| JSON → edit 10 IDs → JSON, sorted keys | 325.8218 | 324.2648 | 347.4230 |
| Read 10 IDs from a prepared tree | 0.0017 | 0.0017 | 0.0010 |
| Edit 10 IDs in a copy of a prepared tree | 0.1260 | 0.1262 | 0.0539 |
| Model → tree → model | 43.2089 | 43.2869 | 384.5976 |

Process median absolute deviations for JSON reading: Previous Enigma / JSONDecoder **2.73%**, Current Enigma / JSONDecoder **0.54%**, AnyCodable / JSONDecoder **1.28%**.

The model/tree row measures direct Enigma encoding and decoding in memory. AnyCodable uses model → JSONEncoder → JSONDecoder(AnyCodable) → JSONEncoder → JSONDecoder(model), since it has no generic in-memory model/tree coder. Intermediate JSON in this row is not sorted.

## Other supported API paths

| Operation | Previous JSONSerialization + cast | Current JSONSerialization + cast | Current Codec Data | AnyCodable native objects |
| --- | --- | --- | --- | --- |
| JSON → tree | 50.1876 | 50.7658 | 20.2885 | 9.1423 |
| Tree → JSON, sorted keys | 32.5872 | 31.7139 | 38.8931 | 20.4580 |
| JSON → edit 10 IDs → JSON, sorted keys | 83.7265 | 83.9205 | 59.7882 | 29.5945 |
| Read 10 IDs from a prepared tree | 0.0017 | 0.0017 | 0.0017 | 1.2611 |
| Edit 10 IDs in a copy of a prepared tree | 0.1333 | 0.1308 | 0.1297 | 0.1303 |
| Model → tree → model | 44.7381 | 44.8915 | 44.1815 | 64.8791 |

The dedicated Codec parser is **unavailable in previous Enigmatic and AnyCodable** (—). Its results are separate from the common Codable decoder comparison. The Codec Data path includes Data/String/UTF-8 conversions inside timed operations.

Enigma’s JSONSerialization routes construct Enigma nodes and use JSONEncoder to write. The AnyCodable native route wraps JSONSerialization objects and writes them with JSONSerialization. Its model roundtrip uses those same native readers/writers, without sorted intermediate JSON. These are valid end-to-end alternatives, with different implementations and API guarantees.

## Retained memory

16 independent decodes of the same 1,697,836-byte Data, held alive in each fresh process. RSS growth and live malloc heap growth are measured against a warmed baseline, **before** validation. Values are MiB. Peak RSS is a whole-process measurement captured before validation; it is not the same metric as retained RSS growth.

| Path | Retained RSS growth | Live heap growth | Whole-process peak RSS |
| --- | --- | --- | --- |
| Previous Enigma / JSONDecoder | 150.22 | 142.91 | 158.42 |
| Current Enigma / JSONDecoder | 150.05 | 142.91 | 158.20 |
| AnyCodable / JSONDecoder | 173.33 | 166.14 | 181.20 |
| Previous Enigma / JSONSerialization + cast | 143.08 | 138.08 | 151.27 |
| Current Enigma / JSONSerialization + cast | 142.98 | 138.08 | 151.19 |
| Current Enigma / Codec Data | 152.67 | 145.61 | 160.69 |
| AnyCodable / native objects + native writer | 52.59 | 51.96 | 60.41 |

RSS also includes allocator pages and runtime metadata; it is not an exact object-size count. No manual sharing of a decoded tree is used. Foundation may legitimately share string storage backed by the common input Data.

## Smaller input

100 records; **16,411 UTF-8 bytes**. Times are milliseconds.

| Path | Read JSON | Write sorted JSON | Read/edit/write sorted JSON |
| --- | --- | --- | --- |
| Previous Enigma / JSONDecoder | 3.0743 | 0.2463 | 3.3114 |
| Current Enigma / JSONDecoder | 3.1225 | 0.2511 | 3.3533 |
| AnyCodable / JSONDecoder | 2.2571 | 1.2929 | 3.5904 |
| Previous Enigma / JSONSerialization + cast | 0.5083 | 0.3152 | 0.8250 |
| Current Enigma / JSONSerialization + cast | 0.5108 | 0.3189 | 0.8243 |
| Current Enigma / Codec Data | 0.1986 | 0.3880 | 0.5913 |
| AnyCodable / native objects + native writer | 0.0887 | 0.1995 | 0.3066 |

## Fairness, correctness and reproducibility

The original fixture bytes were recovered; the generator checks their original SHA-256 hashes. The original comparison source was missing, so this driver was rebuilt around the same tree workloads and model. Compare columns within this fresh run rather than combining them with old timings.

Each result is the median of **5 fresh process medians**. Each timing process uses **9 batches**, rotating operation order. Fast operations are batched toward 10 ms, capped at 1,000 iterations. Warm-up, setup and correctness checks are outside the clock; operation cleanup and autoreleasepool draining are inside. Variants rotate between rounds, and no benchmark processes run concurrently. All measured thermal states were nominal.

Every path verifies the complete model, JSON field values, Unicode, nulls, edits to 10 IDs, and preservation of the original copy. The memory run validates all 16 results after its snapshots. The fixture uses valid JSON and small finite numbers. These checks do not establish equivalent behavior for Date/Data, 128-bit numbers, invalid inputs, defaults, merge policies or arbitrary paths. Enigmatic’s extra APIs do not by themselves explain away the measured speed or memory gaps.

AnyCodable 0.6.7 needs the native writer for its native-object route: wrapping JSONSerialization objects and then using JSONEncoder changes numeric 0/1 into booleans on this platform. The chosen native writer passes the same correctness checks. See [probe.json](probe.json).

Machine: Apple M5 Pro, proc 18:6:12:0, 48 GB; macOS-27.0.1-arm64-arm-64bit. Compiler: `Apple Swift version 6.4 (swiftlang-6.4.0.34.1 clang-2100.3.34.1)`. Build flags: `-O -whole-module-optimization`, arm64 macOS 14 target; Swift language mode 6 for Enigmatic and the shared harness, mode 5 for AnyCodable, matching its manifest. Libraries are compiled from isolated source snapshots. The current uncommitted Package.swift change is recorded in metadata; no package manifest is edited by the harness.

Run from the repository root:

```sh
python3 Benchmarks/BranchComparison/run.py
```

The script uses the existing AnyCodable 0.6.7 checkout under `Benchmarks/Comparison/.build/checkouts/AnyCodable`; pass `--anycodable /path/to/AnyCodable` to use another checkout of that exact revision. It requires macOS arm64 and the installed Swift toolchain.

[Environment and source hashes](environment.json) · [All timing samples and memory snapshots](raw.jsonl) · [Summary CSV](summary.csv) · [Summary JSON](summary.json) · [Swift harness](../benchmark.swift) · [Runner](../run.py)
