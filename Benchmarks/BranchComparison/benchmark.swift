import Foundation
import Darwin
#if ENIGMA
import Enigmatic
typealias Tree = Enigma
#else
import AnyCodable
typealias Tree = AnyCodable
#endif

struct Document: Codable, Equatable {
  var records: [Record]
  var version: Int

  struct Record: Codable, Equatable {
    var id: Int
    var name: String
    var active: Bool
    var score: Double
    var tags: [String]
    var meta: Meta

    struct Meta: Codable, Equatable {
      var city: String
      var rank: Int
      var note: String?
    }
  }
}

@inline(never) @_optimize(none)
func consume<T>(_ value: T) { withExtendedLifetime(value) {} }

func residentBytes() -> UInt64 {
  var info = mach_task_basic_info()
  var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: info) / MemoryLayout<integer_t>.size)
  let status = withUnsafeMutablePointer(to: &info) {
    $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
      task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
    }
  }
  precondition(status == KERN_SUCCESS)
  return info.resident_size
}

func liveHeapBytes() -> UInt64 {
  var stats = malloc_statistics_t()
  malloc_zone_statistics(nil, &stats)
  return UInt64(stats.size_in_use)
}

func cpuNanoseconds() -> Double {
  var usage = rusage()
  precondition(getrusage(RUSAGE_SELF, &usage) == 0)
  return Double(usage.ru_utime.tv_sec + usage.ru_stime.tv_sec) * 1e9
    + Double(usage.ru_utime.tv_usec + usage.ru_stime.tv_usec) * 1e3
}

func emit(_ record: [String: Any]) throws {
  print(String(decoding: try JSONSerialization.data(withJSONObject: record, options: .sortedKeys), as: UTF8.self))
}

@main struct Benchmark {
  static func main() throws {
    let args = CommandLine.arguments
    precondition(args.count == 5, "benchmark <foundation|serialization|codec> <fixture> <timing|memory> <samples|copies>")
    let backend = args[1]
    let input = try Data(contentsOf: URL(fileURLWithPath: args[2]))
    let count = Int(args[4])!
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    let modelEncoder = JSONEncoder()

    func parse(_ bytes: Data) throws -> Tree {
      #if ENIGMA
      switch backend {
      case "foundation": return try decoder.decode(Enigma.self, from: bytes)
      case "serialization": return try Enigma(cast: JSONSerialization.jsonObject(with: bytes))
      #if HAS_JSON_CODEC
      case "codec": return try Codec.decode(json: bytes, as: .utf8)
      #endif
      default: preconditionFailure("Unsupported backend")
      }
      #else
      switch backend {
      case "foundation": return try decoder.decode(AnyCodable.self, from: bytes)
      case "serialization": return AnyCodable(try JSONSerialization.jsonObject(with: bytes))
      default: preconditionFailure("AnyCodable has no dedicated JSON parser")
      }
      #endif
    }

    func write(_ tree: Tree) throws -> Data {
      #if HAS_JSON_CODEC
      if backend == "codec" { return try Codec.encode(json: tree, as: .utf8) }
      #endif
      #if !ENIGMA
      if backend == "serialization" {
        return try JSONSerialization.data(withJSONObject: tree.value, options: [.sortedKeys])
      }
      #endif
      return try encoder.encode(tree)
    }

    func lookup(_ tree: Tree, _ index: Int) -> Int {
      #if ENIGMA
      return tree["records", .int(index), "id"]!.asInt!
      #else
      let root = tree.value as! [String: Any]
      let records = root["records"] as! [Any]
      return (records[index] as! [String: Any])["id"] as! Int
      #endif
    }

    func patch(_ original: Tree, _ indices: [Int]) -> Tree {
      #if ENIGMA
      var result = original
      for index in indices { result["records", .int(index), "id"] = .int(-index - 1) }
      return result
      #else
      var root = original.value as! [String: Any]
      var records = root["records"] as! [Any]
      for index in indices {
        var record = records[index] as! [String: Any]
        record["id"] = -index - 1
        records[index] = record
      }
      root["records"] = records
      return AnyCodable(root)
      #endif
    }

    func bridge(_ model: Document) throws -> Document {
      #if ENIGMA
      return try Enigma(encode: model).decode(Document.self)
      #else
      return try decoder.decode(Document.self, from: encoderForBridge(parse(modelEncoder.encode(model))))
      #endif
    }

    // Intermediate JSON in AnyCodable's model bridge is not sorted: it is not a
    // public JSON writing task. AnyCodable has no generic in-memory model decoder.
    func encoderForBridge(_ tree: Tree) throws -> Data {
      #if !ENIGMA
      if backend == "serialization" {
        return try JSONSerialization.data(withJSONObject: tree.value)
      }
      #endif
      return try modelEncoder.encode(tree)
    }

    if args[3] == "memory" {
      // Snapshot before validation, in a fresh process holding independent parses
      // of the same Data. Warm up runtime metadata using a tiny overlapping input.
      try autoreleasepool { consume(try parse(Data("{\"warmup\":[1,true,\"x\",null]}".utf8))) }
      var trees: [Tree] = []
      trees.reserveCapacity(count)
      let beforeRSS = residentBytes()
      let beforeHeap = liveHeapBytes()
      for _ in 0..<count { trees.append(try autoreleasepool { try parse(input) }) }
      let afterHeap = liveHeapBytes()
      let afterRSS = residentBytes()
      var usage = rusage()
      precondition(getrusage(RUSAGE_SELF, &usage) == 0)
      let peakRSS = usage.ru_maxrss
      let expected = try decoder.decode(Document.self, from: input)
      // Validate every retained result after the memory snapshot.
      for tree in trees {
        let restored = try decoder.decode(Document.self, from: write(tree))
        precondition(restored == expected)
      }
      consume(trees)
      try emit([
        "task": "memory", "copies": count, "input_bytes": input.count,
        "rss_before_bytes": beforeRSS, "rss_held_bytes": afterRSS,
        "rss_delta_bytes": Int64(afterRSS) - Int64(beforeRSS),
        "heap_delta_bytes": Int64(afterHeap) - Int64(beforeHeap),
        "peak_rss_bytes": peakRSS,
        "thermal_state": ProcessInfo.processInfo.thermalState.rawValue,
      ])
      return
    }

    let expected = try decoder.decode(Document.self, from: input)
    let prepared = try parse(input)
    let indices = stride(from: 0, to: expected.records.count, by: max(1, expected.records.count / 10)).prefix(10).map { $0 }
    var patched = expected
    for index in indices { patched.records[index].id = -index - 1 }
    // Preserve all fields, Unicode, nulls, numeric values and the original copy.
    let written = try write(prepared)
    let restored = try decoder.decode(Document.self, from: written)
    precondition(restored == expected)
    let originalObject = try JSONSerialization.jsonObject(with: input) as! NSDictionary
    let writtenObject = try JSONSerialization.jsonObject(with: written) as! [AnyHashable: Any]
    precondition(originalObject.isEqual(to: writtenObject))
    let restoredPatch = try decoder.decode(Document.self, from: write(patch(prepared, indices)))
    precondition(restoredPatch == patched)
    let restoredModel = try bridge(expected)
    precondition(restoredModel == expected)
    for index in indices { precondition(lookup(prepared, index) == index) }

    let operations: [(String, () throws -> Void)] = [
      ("parse", { consume(try parse(input)) }),
      ("write-sorted", { consume(try write(prepared)) }),
      ("parse-patch-write-sorted", { consume(try write(patch(parse(input), indices))) }),
      ("lookup-10", { consume(indices.reduce(0) { $0 + lookup(prepared, $1) }) }),
      ("patch-10", { consume(patch(prepared, indices)) }),
      ("model-tree-model", { consume(try bridge(expected)) }),
    ]
    var batches = [Int]()
    for (_, body) in operations {
      try autoreleasepool { try body() }
      let start = DispatchTime.now().uptimeNanoseconds
      try autoreleasepool { try body() }
      let elapsed = max(1, DispatchTime.now().uptimeNanoseconds - start)
      batches.append(max(1, min(1_000, Int(10_000_000 / elapsed))))
    }
    var times = Array(repeating: [Double](), count: operations.count)
    var cpuTimes = times
    var thermalStates = [Int]()
    for sample in 0..<count {
      thermalStates.append(ProcessInfo.processInfo.thermalState.rawValue)
      for offset in operations.indices {
        let index = (offset + sample) % operations.count
        let cpuStart = cpuNanoseconds()
        let start = DispatchTime.now().uptimeNanoseconds
        for _ in 0..<batches[index] { try autoreleasepool { try operations[index].1() } }
        let elapsed = DispatchTime.now().uptimeNanoseconds - start
        let cpuElapsed = cpuNanoseconds() - cpuStart
        times[index].append(Double(elapsed) / Double(batches[index]))
        cpuTimes[index].append(cpuElapsed / Double(batches[index]))
      }
    }
    for index in operations.indices {
      try emit([
        "task": operations[index].0, "input_bytes": input.count,
        "records": expected.records.count, "samples": count,
        "batch_iterations": batches[index], "ns_samples": times[index],
        "ns_per_op": times[index].sorted()[count / 2],
        "cpu_ns_per_op": cpuTimes[index].sorted()[count / 2],
        "thermal_states": thermalStates,
      ])
    }
  }
}
