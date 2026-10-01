@testable import Enigmatic
import Foundation
import CoreFoundation
import XCTest

final class PerformanceTests: XCTestCase {
  func avarage<T>(run count: Int = 1000, _ block: () throws -> T, call: StaticString = #function) rethrows -> Double {
    _ = try block()
    let start = DispatchTime.now()
    for _ in 0..<count {
      try autoreleasepool {
        _ = try block()
      }
    }
    let end = DispatchTime.now()
    return Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / Double(count)
  }

  func report(_ action: String, _ direct: Double, _ values: [Double]) throws {
    let indirect = values.reduce(0, +)
    let times = (indirect / direct).formatted(.number.precision(.fractionLength(3)))
    var message: [String] = ["Performance of \(action) - \(times) slower:"]
    message.append("\(direct.formatted(.number.precision(.fractionLength(3))))ns VS")
    let values = values.map { "\($0.formatted(.number.precision(.fractionLength(3))))ns" }
    message.append(values.joined(separator: " + "))
    print(message.joined(separator: " "))
  }

  func testDecoding() throws {
    let value = Regular()
    let jsonData = try Coder.encode(value, \.nonConformingFloatJson)
    let xmlData = try Coder.encode(value, \.xmlPlistEncoder)
    let binData = try Coder.encode(value, \.binaryPlistEncoder)
    let enigma = try Enigma(encode: value)
    let jsonObject = try Coder.deserialize(jsonData, json: true)
    let plistObject = try Coder.deserialize(xmlData, json: false)

    let decodeValueFromJsonTime = try avarage {
      try Coder.decode(Regular.self, jsonData, \.nonConformingFloatJson)
    }
    let decodeValueFromXmlTime = try avarage {
      try Coder.decode(Regular.self, xmlData)
    }
    let decodeValueFromBinTime = try avarage {
      try Coder.decode(Regular.self, binData)
    }
    let decodeEnigmaFromJsonTime = try avarage {
      try Coder.decode(Enigma.self, jsonData, \.nonConformingFloatJson)
    }
    let decodeEnigmaFromXmlTime = try avarage {
      try Coder.decode(Enigma.self, xmlData)
    }
    let decodeEnigmaFromBinTime = try avarage {
      try Coder.decode(Enigma.self, binData)
    }
    let decodeValueFromEnigmaTime = try avarage(run: 10000) {
      try enigma.decode(Regular.self)
    }
    let deserializeJsonTime = try avarage {
      try Coder.deserialize(jsonData, json: true)
    }
    let deserializeXmlTime = try avarage {
      try Coder.deserialize(xmlData, json: false)
    }
    let deserializeBinTime = try avarage {
      try Coder.deserialize(binData, json: false)
    }
    let castJsonTime = try avarage {
      try Enigma(cast: jsonObject)
    }
    let castPlistTime = try avarage {
      try Enigma(cast: plistObject)
    }

    try report("json decoding", decodeValueFromJsonTime, [
        decodeEnigmaFromJsonTime,
        decodeValueFromEnigmaTime,
    ])
    try report("json deserialization", decodeValueFromJsonTime, [
        deserializeJsonTime,
        castJsonTime,
        decodeValueFromEnigmaTime,
    ])
    try report("xml plist decoding", decodeValueFromXmlTime, [
        decodeEnigmaFromXmlTime,
        decodeValueFromEnigmaTime,
    ])
    try report("xml plist deserialization", decodeValueFromXmlTime, [
        deserializeXmlTime,
        castPlistTime,
        decodeValueFromEnigmaTime,
    ])
    try report("binary plist decoding", decodeValueFromBinTime, [
        decodeEnigmaFromBinTime,
        decodeValueFromEnigmaTime,
    ])
    try report("binary plist deserialization", decodeValueFromBinTime, [
        deserializeBinTime,
        castPlistTime,
        decodeValueFromEnigmaTime,
    ])
  }

  func testEncoding() throws {
    let value = Regular()
    let enigma = try Enigma(encode: value)
    let jsonObject = try enigma.jsonObject
    let plistObject = try enigma.plistObject

    let encodeValueJsonTime = try avarage {
      try Coder.encode(value, \.nonConformingFloatJson)
    }
    let encodeValueXmlTime = try avarage {
      try Coder.encode(value, \.xmlPlistEncoder)
    }
    let encodeValueBinTime = try avarage {
      try Coder.encode(value, \.binaryPlistEncoder)
    }
    let encodeEnigmaTime = try avarage {
      try Enigma(encode: value)
    }
    let encodeEnigmaJsonTime = try avarage {
      try Coder.encode(enigma, \.nonConformingFloatJson)
    }
    let encodeEnigmaXmlTime = try avarage {
      try Coder.encode(enigma, \.xmlPlistEncoder)
    }
    let encodeEnigmaBinTime = try avarage {
      try Coder.encode(enigma, \.binaryPlistEncoder)
    }
    let castJsonObjectTime = try avarage {
      try enigma.jsonObject
    }
    let castPlistObjectTime = try avarage {
      try enigma.plistObject
    }
    let serializeJsonTime = try avarage {
      try Coder.serialize(jsonObject)
    }
    let serializeXmlTime = try avarage {
      try Coder.serialize(plistObject, .xml)
    }
    let serializeBinTime = try avarage {
      try Coder.serialize(plistObject, .binary)
    }

    try report("json encoding", encodeValueJsonTime, [
        encodeEnigmaTime,
        encodeEnigmaJsonTime,
    ])
    try report("json serialization", encodeValueJsonTime, [
        encodeEnigmaTime,
        castJsonObjectTime,
        serializeJsonTime,
    ])
    try report("xml plist encoding", encodeValueXmlTime, [
        encodeEnigmaTime,
        encodeEnigmaXmlTime,
    ])
    try report("xml plist serialization", encodeValueXmlTime, [
        encodeEnigmaTime,
        castPlistObjectTime,
        serializeXmlTime,
    ])
    try report("binary plist encoding", encodeValueBinTime, [
        encodeEnigmaTime,
        encodeEnigmaBinTime,
    ])
    try report("binary plist serialization", encodeValueBinTime, [
        encodeEnigmaTime,
        castPlistObjectTime,
        serializeBinTime,
    ])
  }
}
