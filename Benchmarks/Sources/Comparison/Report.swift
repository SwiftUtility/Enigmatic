import Foundation

struct CheckRecord: Codable {
  var engine: Engine
  var wire: Wire
  var probe: String
  var result: ProbeResult
}

struct RunData: Codable {
  var timestamp: String
  var swift: String
  var machine: String
  var revision: String
  var samples: Int
  var records: Int
  var fixtureJSONBytes: Int
  var versions: [String: String]
  var checks: [CheckRecord]
  var timings: [TimingResult]
  var failures: [String]
}

func capture(_ command: String, _ arguments: [String]) -> String {
  let task = Process()
  task.executableURL = URL(fileURLWithPath: command)
  task.arguments = arguments
  let pipe = Pipe()
  task.standardOutput = pipe
  task.standardError = pipe
  do {
    try task.run()
    let output = pipe.fileHandleForReading.readDataToEndOfFile()
    task.waitUntilExit()
    return String(decoding: output, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
  } catch { return String(describing: error) }
}

func isolatedProbe(engine: Engine, wire: Wire, kind: Probe, executable: URL) -> ProbeResult {
  if !engine.supports(wire) { return .unsupported("No adapter for this format/path") }
  let task = Process()
  task.executableURL = executable
  task.arguments = ["--probe", engine.rawValue, wire.rawValue, kind.rawValue]
  let pipe = Pipe()
  task.standardOutput = pipe
  // A crashing dependency can emit megabytes of backtrace text. Keep it off the result pipe.
  task.standardError = FileHandle.nullDevice
  let completed = DispatchSemaphore(value: 0)
  task.terminationHandler = { _ in completed.signal() }
  do {
    try task.run()
    if completed.wait(timeout: .now() + 15) == .timedOut {
      task.terminate()
      if completed.wait(timeout: .now() + 1) == .timedOut {
        kill(task.processIdentifier, SIGKILL)
        task.waitUntilExit()
      }
      return .init(status: "⏱", detail: "Probe exceeded 15 seconds")
    }
    let bytes = pipe.fileHandleForReading.readDataToEndOfFile()
    guard task.terminationReason == .exit, task.terminationStatus == 0 else {
      return .init(status: "💥", detail: "Child process failed: \(task.terminationReason), status \(task.terminationStatus)")
    }
    return try JSONDecoder().decode(ProbeResult.self, from: bytes)
  } catch { return .init(status: "💥", detail: String(describing: error)) }
}

func markdown(_ run: RunData) -> String {
  var text = """
  # Competitor benchmarks

  Generated: \(run.timestamp). This is a measured snapshot, not a general ranking.

  - Toolchain: `\(run.swift.replacingOccurrences(of: "\n", with: "; "))`
  - Machine: `\(run.machine)`
  - Enigmatic revision: `\(run.revision)` (local working tree is used).
  - Build: Release, no coverage; \(run.samples) samples, \(run.records) identical records per payload.
  - Common fixture: \(run.fixtureJSONBytes) compact Foundation JSON bytes; strings, Bool, Int, Double,
    arrays, dictionaries, and Optional fields. Special values are isolated in contract probes.

  ## Dependencies

  Latest stable versions selected when this project was created; prereleases excluded.
  `Benchmarks/Package.resolved` pins transitive revisions. Update exact versions deliberately before rerunning.

  """
  let packages = run.versions.keys.sorted()
  text += "| Package | " + packages.joined(separator: " | ") + " |\n"
  text += "| --- | " + packages.map { _ in "---" }.joined(separator: " | ") + " |\n"
  text += "| Version | " + packages.map { run.versions[$0] ?? "—" }.joined(separator: " | ") + " |\n"
  text += "\n" + featureMatrix(run)
  text += """

  ## Interpretation

  ✅ probe requirements met (exact typed model roundtrip except the two type-only probes);
  ❌ changed value, missing null key, or non-native plist storage;
  ⚠️ encoder/decoder rejected the input; 💥 isolated process failed; ⏱ timeout;
  — no implemented path or case is not applicable. A rejection of NaN/infinity in default JSON
  is expected standards-compliant behavior, not necessarily a library defect.
  For finite floating-point values, signed zero and bit patterns are checked; NaN is compared by isNaN.
  Integer cases contain minimum/maximum values, with Int64/UInt64 also checking values beyond 2^53.
  Int128/UInt128 and Float16 mean the native Swift types, not third-party BigInt or Float16 wrappers.
  These are enumerated contract probes, not an exhaustive proof for all possible values.

  A typed roundtrip does not imply identical wire representations or compatibility with Foundation default Date/Data policies.
  Every serialized check is model → bytes → model. The plist nativeData/nativeDate rows also inspect
  the actual PropertyListSerialization result for Data/Date rather than accepting strings or numbers.
  plistDataType/plistDateType check only the stored type, independently of roundtrip correctness.
  The Date sample has a .125-second fraction, so XML date precision loss remains visible even when
  plistDateType passes.
  defaultNull tests synthesized Optional nil (omitting a key fails this *presence* requirement);
  explicitNull uses an explicit encode of Optional nil; libraryNull uses Enigmatic Nullable or CodableWrappers EncodeNulls.
  This distinguishes representation policy from loss of an Optional value.

  Foundation Codable means JSONEncoder/Decoder or PropertyListEncoder/Decoder.
  Foundation Serialization uses JSONSerialization or PropertyListSerialization *after* the Foundation Codable bridge.
  Enigmatic Serialization uses its direct object bridge. Enigmatic Codec uses its own JSON parser/writer.
  SwiftyJSON and AnyCodable need Foundation Codable bridges to move between a typed model and their values;
  these costs are included. Potent AnyValue uses AnyValueEncoder/Decoder and Foundation for bytes.
  The AnyValue + Foundation Codable path can fail the common object-shaped fixture because AnyValue
  dictionary Codable representation uses non-String dictionary keys; this does not imply failure of PotentJSON.
  JSON-only libraries have no plist adapter and are marked —, rather than measured through an unrelated fallback.

  CodableWrappers, BetterCodable, and MetaCodable are model-layer tools, not serializers.
  Generic scalar probes in these columns inherit Foundation behavior. Performance uses matching records:
  CodableWrappers Immutable on id, BetterCodable LosslessValue on id, and MetaCodable-generated Codable.
  Other columns use synthesized Codable. All records have identical values and serialized structure.

  ## Roundtrips

  """
  for wire in Wire.allCases {
    text += "### \(wire.title)\n\n"
    text += "| Data type / case | " + Engine.allCases.map(\.title).joined(separator: " | ") + " |\n"
    text += "| --- | " + Engine.allCases.map { _ in "---" }.joined(separator: " | ") + " |\n"
    for kind in Probe.allCases {
      let cells = Engine.allCases.map { engine in
        run.checks.first { $0.engine == engine && $0.wire == wire && $0.probe == kind.rawValue }?.result.status ?? "—"
      }
      text += "| \(kind.rawValue) | " + cells.joined(separator: " | ") + " |\n"
    }
    text += "\n"
  }
  text += """
  ## Performance

  Each operation is measured separately, after validation and warm-up. Execution order rotates per sample.
  Decode inputs are the exact same Foundation-produced bytes for every library in a format.
  Model/encoder/tree creation required by a path stays inside its measurement; fixture setup and correctness
  comparisons stay outside. Encoder and decoder instances are created per operation for every path.
  The roundtrip is timed as one operation; its median is not the sum of stage medians.

  For paired sample i, rᵢ = library timeᵢ / Foundation Codable timeᵢ.
  E[r] = Σrᵢ/n; Var[r] = Σ(rᵢ − E[r])²/n (population variance of observed ratios, dimensionless).
  Time % = 100 × E[r]; lower is faster. Factor = E[r]× slower or 1/E[r]× faster.
  E[r] is not the ratio of medians. Variance describes this run's dispersion, not a confidence interval.
  Raw times and detailed check outcomes are saved beside this report as `CompetitorBenchmarks.json`.

  """
  for wire in [Wire.json, .xml, .binary] {
    for scenario in ["model → Data", "Data → model", "model → Data → model"] {
      text += "### \(wire.title): \(scenario)\n\n"
      text += "| Metric | " + Engine.allCases.map(\.title).joined(separator: " | ") + " |\n"
      text += "| --- | " + Engine.allCases.map { _ in "---:" }.joined(separator: " | ") + " |\n"
      for metric in ["Median ms/op", "Time %", "E[r]", "Var[r]", "Factor"] {
        let cells = Engine.allCases.map { engine -> String in
          guard let result = run.timings.first(where: {
            $0.engine == engine && $0.wire == wire && $0.operation == scenario
          }) else { return "—" }
          let s = result.statistics
          switch metric {
          case "Median ms/op": return number(s.medianNanoseconds / 1_000_000, 6)
          case "Time %": return "\(number(s.meanRatio * 100))%"
          case "E[r]": return number(s.meanRatio, 6)
          case "Var[r]": return number(s.varianceRatio, 9)
          default:
            return engine == .foundation ? "baseline" : s.meanRatio < 1
              ? "\(number(1 / s.meanRatio))x faster" : "\(number(s.meanRatio))x slower"
          }
        }
        text += "| \(metric) | " + cells.joined(separator: " | ") + " |\n"
      }
      text += "\n"
    }
  }
  text += "## Observations\n\n"
  for wire in [Wire.json, .xml, .binary] {
    let rows = run.timings.filter { $0.wire == wire && $0.operation == "Data → model" }
    if let fastest = rows.min(by: { $0.statistics.meanRatio < $1.statistics.meanRatio }) {
      text += "- Lowest observed mean decoding ratio for \(wire.title): **\(fastest.engine.title)**, \(number(fastest.statistics.meanRatio * 100))% of Foundation.\n"
    }
  }
  for (wire, kinds, title) in [
    (Wire.xml, [Probe.nativeData, .nativeDate], "Native Data and Date with exact values in XML plist"),
    (.binary, [.nativeData, .nativeDate], "Native Data and Date with exact values in binary plist"),
    (.json, [.int128, .uint128], "Exact Int128 and UInt128 JSON roundtrip"),
    (.json, [.libraryNull], "Explicit JSON null with a configured library wrapper"),
  ] {
    let names = Engine.allCases.filter { engine in
      kinds.allSatisfy { kind in
        run.checks.contains { $0.engine == engine && $0.wire == wire
          && $0.probe == kind.rawValue && $0.result.status == "✅" }
      }
    }.map(\.title)
    text += "- \(title): \(names.isEmpty ? "no passing adapter" : names.joined(separator: "; ")).\n"
  }
  let crashes = run.checks.filter { $0.result.status == "💥" }.count
  if crashes > 0 {
    text += "- \(crashes) probes terminated their isolated process; inspect the diagnostics before using those type/path combinations.\n"
  }
  if !run.failures.isEmpty {
    text += "\n### Excluded performance paths\n\n"
    for failure in run.failures { text += "- \(escape(failure))\n" }
  }
  text += "\n## Probe diagnostics\n\n"
  for wire in Wire.allCases {
    let failures = run.checks.filter {
      $0.wire == wire && $0.result.status != "✅" && $0.result.status != "—"
    }
    guard !failures.isEmpty else { continue }
    text += "### \(wire.title)\n\n"
    for check in failures {
      text += "- **\(check.engine.title) / \(check.probe)** — \(check.result.status) \(escape(check.result.detail))\n"
    }
    text += "\n"
  }
  return text.trimmingCharacters(in: .whitespacesAndNewlines) + "\n"
}

private func escape(_ text: String) -> String {
  text.replacingOccurrences(of: "|", with: "\\|").replacingOccurrences(of: "\n", with: " ")
}
