import Foundation
import Enigmatic
import AnyCodable

@main struct Probe {
  static func main() throws {
    let source: [String: Any] = ["zero": 0, "one": 1, "flag": true]
    let input = try JSONSerialization.data(withJSONObject: source)
    let wrapped = AnyCodable(try JSONSerialization.jsonObject(with: input))
    let codableOutput = try JSONEncoder().encode(wrapped)
    let nativeOutput = try JSONSerialization.data(withJSONObject: wrapped.value)
    let output: [String: Any] = [
      "input": try JSONSerialization.jsonObject(with: input),
      "anycodable_jsonencoder_output": try JSONSerialization.jsonObject(with: codableOutput),
      "anycodable_jsonserialization_output": try JSONSerialization.jsonObject(with: nativeOutput),
      "enigma_node_stride_bytes": MemoryLayout<Enigma>.stride,
      "anycodable_wrapper_stride_bytes": MemoryLayout<AnyCodable>.stride,
    ]
    print(String(decoding: try JSONSerialization.data(withJSONObject: output, options: [.sortedKeys]), as: UTF8.self))
  }
}
