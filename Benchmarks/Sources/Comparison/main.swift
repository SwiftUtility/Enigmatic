import Foundation

func main() throws {
  setbuf(stdout, nil)
  let arguments = Array(CommandLine.arguments.dropFirst())
  if arguments.first == "--probe" {
    guard arguments.count == 4, let engine = Engine(rawValue: arguments[1]),
      let wire = Wire(rawValue: arguments[2]), let kind = Probe(rawValue: arguments[3]) else {
      throw CheckFailure("Invalid probe arguments")
    }
    var result = probe(kind, engine: engine, wire: wire)
    result.detail = String(result.detail.prefix(2000))
    FileHandle.standardOutput.write(try JSONEncoder().encode(result))
    return
  }
  if arguments.contains("--help") {
    print("Comparison [--samples 25] [--records 900] [--output path.md] [--package-root path] [--render results.json]")
    return
  }
  let allowed: Set<String> = ["--samples", "--records", "--output", "--package-root", "--render"]
  guard arguments.count.isMultiple(of: 2) else { throw CheckFailure("Options require values; use --help") }
  var options: [String: String] = [:]
  for index in stride(from: 0, to: arguments.count, by: 2) {
    guard allowed.contains(arguments[index]), options[arguments[index]] == nil else {
      throw CheckFailure("Unknown or duplicate option: \(arguments[index])")
    }
    options[arguments[index]] = arguments[index + 1]
  }
  guard let samples = Int(options["--samples"] ?? "25"), samples >= 3,
    let records = Int(options["--records"] ?? "900"), records > 0 else {
    throw CheckFailure("samples must be >= 3; records must be > 0")
  }
  let defaultPackage = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
    .deletingLastPathComponent().deletingLastPathComponent()
  let package = options["--package-root"].map { URL(fileURLWithPath: $0) } ?? defaultPackage
  let root = package.deletingLastPathComponent()
  let output = options["--output"].map { URL(fileURLWithPath: $0) }
    ?? root.appendingPathComponent("Sources/Enigmatic/Enigmatic.docc/CompetitorBenchmarks.md")
  if let input = options["--render"] {
    let run = try JSONDecoder().decode(RunData.self, from: Data(contentsOf: URL(fileURLWithPath: input)))
    try FileManager.default.createDirectory(at: output.deletingLastPathComponent(), withIntermediateDirectories: true)
    try markdown(run).write(to: output, atomically: true, encoding: .utf8)
    print("Report rendered from saved measurements: \(output.path)")
    return
  }
  let resolved = try Data(contentsOf: package.appendingPathComponent("Package.resolved"))
  let lock = try JSONSerialization.jsonObject(with: resolved) as? [String: Any]
  guard let pins = lock?["pins"] as? [[String: Any]] else { throw CheckFailure("Missing dependency pins") }
  var versions: [String: String] = [:]
  for pin in pins {
    if let name = pin["identity"] as? String, let state = pin["state"] as? [String: String] {
      versions[name] = state["version"] ?? state["revision"]
    }
  }
  var checks: [CheckRecord] = []
  let executable = URL(fileURLWithPath: CommandLine.arguments[0]).standardizedFileURL
  for engine in Engine.allCases {
    print("Checking \(engine.title)…")
    for wire in Wire.allCases {
      for kind in Probe.allCases {
        let result = isolatedProbe(engine: engine, wire: wire, kind: kind, executable: executable)
        checks.append(.init(engine: engine, wire: wire, probe: kind.rawValue, result: result))
      }
    }
  }
  var measurements = Measurements()
  for wire in [Wire.json, .xml, .binary] {
    for scenario in ["model → Data", "Data → model", "model → Data → model"] {
      print("Measuring \(wire.title): \(scenario), \(samples) individual operations…")
      try measurements.measure(wire: wire, scenario: scenario, samples: samples, records: records)
    }
  }
  guard measurements.checksum > 0 else { throw CheckFailure("Empty measurement checksum") }
  let run = RunData(
    timestamp: ISO8601DateFormatter().string(from: Date()),
    swift: capture("/usr/bin/env", ["swift", "--version"]),
    machine: capture("/usr/bin/uname", ["-mrs"])
      + "; logical CPUs: \(ProcessInfo.processInfo.processorCount); RAM bytes: \(ProcessInfo.processInfo.physicalMemory)",
    revision: capture("/usr/bin/git", ["-C", root.path, "describe", "--always", "--dirty"]),
    samples: samples, records: records,
    fixtureJSONBytes: try foundationEncode(Payload(records: (0..<records).map(PlainRow.init)), wire: .json).count,
    versions: versions, checks: checks,
    timings: measurements.results, failures: measurements.failures)
  try FileManager.default.createDirectory(at: output.deletingLastPathComponent(), withIntermediateDirectories: true)
  let encoder = JSONEncoder()
  encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
  try encoder.encode(run).write(to: output.deletingPathExtension().appendingPathExtension("json"), options: .atomic)
  try markdown(run).write(to: output, atomically: true, encoding: .utf8)
  print("Report: \(output.path)")
}

do {
  try main()
} catch {
  FileHandle.standardError.write(Data("Benchmark failed: \(error)\n".utf8))
  exit(1)
}
