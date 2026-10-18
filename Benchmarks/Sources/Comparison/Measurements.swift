import Foundation

struct Statistics: Codable {
  let medianNanoseconds: Double
  let meanRatio: Double
  let varianceRatio: Double

  init(times: [Double], baseline: [Double]) {
    precondition(!times.isEmpty && times.count == baseline.count && baseline.allSatisfy { $0 > 0 })
    let ratios = zip(times, baseline).map { $0 / $1 }
    meanRatio = ratios.reduce(0, +) / Double(ratios.count)
    let mean = meanRatio
    varianceRatio = ratios.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / Double(ratios.count)
    let sorted = times.sorted()
    medianNanoseconds = sorted.count.isMultiple(of: 2)
      ? (sorted[sorted.count / 2 - 1] + sorted[sorted.count / 2]) / 2
      : sorted[sorted.count / 2]
  }
}

struct TimingResult: Codable {
  let engine: Engine
  let wire: Wire
  let operation: String
  let times: [Double]
  let statistics: Statistics
}

struct Operation {
  let engine: Engine
  let run: () throws -> Int
}

struct Measurements {
  var results: [TimingResult] = []
  var failures: [String] = []
  var checksum = 0

  mutating func measure(wire: Wire, scenario: String, samples: Int, records: Int) throws {
    var operations: [Operation] = []
    let plain = Payload(records: (0..<records).map(PlainRow.init))
    let canonical = try foundationEncode(plain, wire: wire)
    for engine in Engine.allCases where engine.supports(wire) {
      do {
        let operation: Operation
        switch engine {
        case .codableWrappers:
          operation = try makeOperation(engine, Payload(records: (0..<records).map(WrappedRow.init)),
            canonical: canonical, wire: wire, scenario: scenario)
        case .betterCodable:
          operation = try makeOperation(engine, Payload(records: (0..<records).map(BetterRow.init)),
            canonical: canonical, wire: wire, scenario: scenario)
        case .metaCodable:
          operation = try makeOperation(engine, Payload(records: (0..<records).map(MacroRow.init)),
            canonical: canonical, wire: wire, scenario: scenario)
        default:
          operation = try makeOperation(engine, plain, canonical: canonical, wire: wire, scenario: scenario)
        }
        operations.append(operation)
      } catch {
        failures.append("\(wire.title), \(scenario), \(engine.title): \(error)")
      }
    }
    guard operations.first?.engine == .foundation else { throw CheckFailure("Missing Foundation baseline") }
    for operation in operations { checksum &+= try autoreleasepool { try operation.run() } }
    var times = Array(repeating: [Double](), count: operations.count)
    for sample in 0..<samples {
      for offset in operations.indices {
        let index = (offset + sample) % operations.count
        let start = DispatchTime.now().uptimeNanoseconds
        checksum &+= try autoreleasepool { try operations[index].run() }
        times[index].append(Double(DispatchTime.now().uptimeNanoseconds - start))
      }
    }
    for index in operations.indices {
      let statistics = Statistics(times: times[index], baseline: times[0])
      results.append(.init(engine: operations[index].engine, wire: wire, operation: scenario,
        times: times[index], statistics: statistics))
      let ratio = statistics.meanRatio
      let factor = operations[index].engine == .foundation ? "baseline"
        : ratio < 1 ? "\(number(1 / ratio))x faster" : "\(number(ratio))x slower"
      print("  \(operations[index].engine.title) | \(number(ratio * 100))% (\(factor))")
      print("    \(scenario) median: \(number(statistics.medianNanoseconds / 1_000_000, 6)) ms/op")
    }
  }
}

private func makeOperation<Row: Codable & Equatable>(
  _ engine: Engine, _ model: Payload<Row>, canonical: Data, wire: Wire, scenario: String
) throws -> Operation {
  let encoded = try engine.encode(model, wire: wire)
  guard try engine.decode(Payload<Row>.self, data: encoded, wire: wire) == model,
    try engine.decode(Payload<Row>.self, data: canonical, wire: wire) == model else {
    throw CheckFailure("Fixture failed exact roundtrip or common-input decoding")
  }
  // Every library must produce the same semantic payload; key order is irrelevant.
  let expected = try object(canonical, wire: wire) as AnyObject
  let actual = try object(encoded, wire: wire) as AnyObject
  guard let expected = expected as? NSDictionary, let actual = actual as? NSDictionary,
    expected == actual else { throw CheckFailure("Encoded fixture differs from Foundation payload") }
  switch scenario {
  case "model → Data": return Operation(engine: engine, run: { try engine.encode(model, wire: wire).count })
  case "Data → model": return Operation(engine: engine, run: {
    let output = try engine.decode(Payload<Row>.self, data: canonical, wire: wire)
    return output.records.count
  })
  default: return Operation(engine: engine, run: {
    let bytes = try engine.encode(model, wire: wire)
    let output = try engine.decode(Payload<Row>.self, data: bytes, wire: wire)
    return output.records.count
  })
  }
}

func number(_ value: Double, _ precision: Int = 3) -> String {
  String(format: "%.*f", locale: Locale(identifier: "en_US_POSIX"), precision, value)
}

extension Engine: Codable {}
extension Wire: Codable {}
