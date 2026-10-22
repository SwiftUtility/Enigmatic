# Competitor benchmarks

Independent SwiftPM executable; the library target remains dependency-free.
All performance measurements live here. The main package contains only functional
tests; run them with `swift test` and `swift test -c release` from the repository root.
Requires macOS 15+ and the repository's Swift toolchain (currently validated with Swift 6.3.3).

Run `./Benchmarks/Run.command` from any working directory, or double-click it in Finder.
The script builds Release, checks roundtrips in isolated processes, and writes
`Sources/Enigmatic/Enigmatic.docc/CompetitorBenchmarks.md` and a raw JSON sidecar.
The first build downloads dependencies and builds SwiftSyntax macro plugins, so it can take several minutes.

Defaults: 900 deterministic records, 25 samples for each of JSON/XML plist/binary plist
encoding, decoding, and complete roundtrip. Override with `--samples 51 --records 900`.
Use `swift test --package-path Benchmarks -c release` for harness contract tests.

All eight competitors from the comparison are imported and exercised:
PotentCodables, SwiftyJSON, PMJSON, CodableWrappers, BetterCodable, MetaCodable,
AnyCodable, and swift-json (IkigaJSON). Exact latest **stable** releases were selected
on 2026-10-18; prereleases are excluded. Package.resolved pins transitive dependencies.
To update, check upstream tags, change exact requirements, run `swift package
--package-path Benchmarks resolve`, and regenerate the report. Runs do not silently upgrade dependencies.

There are several rows for Enigmatic and PotentCodables to distinguish native parsers,
Foundation Codable, and Foundation object serialization. Wrapper/macro rows use Foundation
and matching model variants; scalar probe results on those rows inherit Foundation behavior.
See the generated report for the exact paths, representation policies, and formulas.
Unsupported paths are not replaced with a Foundation fallback and labelled as competitor support.

Ratios are paired by sample: path time / Foundation Codable time. The report contains
median ms/op, mean ratio, population variance of the ratios, unsigned time percentage,
and a faster/slower factor. Values are not performance assertions or cross-machine promises.
Decoder input bytes are shared. Validation and warm-up are outside timings;
required intermediary conversions and coder construction are inside timings.

The probe matrix includes every integer width (including 128-bit extrema), Float16/Float/Double,
signed zero, NaN and both infinities, Decimal, CGFloat, String, Bool, Data, Date, URL, UUID,
nested/optional values, scalar/array roots, JSON null-key policies, and actual native plist Data/Date storage.
Strict JSON rejection of non-finite numbers is reported separately from configured string conversion.
A failed probe is recorded rather than aborting the report. Each probe has a 15-second timeout.

All comparison tables put libraries/paths in columns. Roundtrip tables have one row
per data type/case and one complete table per format/path, including inapplicable
cases marked —. Performance tables put metrics in rows for each scenario.
To reformat the report without rerunning measurements:

```sh
./Benchmarks/Run.command --render Sources/Enigmatic/Enigmatic.docc/CompetitorBenchmarks.json
```

The feature matrix combines paths into one column per library. API descriptions
link to pinned upstream sources; measured feature statuses are derived from the saved
roundtrip probes. Not probed means absent harness coverage, not absent library support.
Native plist types and exact Date roundtrips are separate features.
