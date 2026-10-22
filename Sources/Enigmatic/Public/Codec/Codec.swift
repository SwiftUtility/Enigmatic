import Foundation

/// Composable strategies for choosing a Codable representation.
///
/// See [composing coding strategies](https://swiftutility.github.io/Enigmatic/documentation/enigmatic/codingstrategies/) for wrappers, collections, and examples.
public enum Codec {
  /// Parses a JSON document, including a scalar root.
  public static func decode(
    json string: some StringProtocol
  ) throws(DecodingError) -> Enigma {
    var decoder = JsonDecoder(String(string))
    return try decoder.decode()
  }

  /// Parses JSON bytes in the specified text encoding. Invalid text is rejected.
  public static func decode(
    json data: some DataProtocol,
    as encoding: String.Encoding
  ) throws(DecodingError) -> Enigma {
    guard let string = String(data: Data(data), encoding: encoding) else {
      throw .dataCorrupted(.init(codingPath: [], debugDescription: "Invalid JSON text encoding"))
    }
    return try decode(json: string)
  }

  /// Writes compact JSON. Date, Data and non-finite numbers are rejected.
  public static func encode(
    json enigma: Enigma
  ) throws(EncodingError) -> String {
    try JsonEncoder.encode(enigma)
  }

  /// Writes JSON bytes without lossy text conversion.
  public static func encode(
    json enigma: Enigma,
    as encoding: String.Encoding
  ) throws(EncodingError) -> Data {
    let string = try encode(json: enigma)
    guard let data = string.data(using: encoding, allowLossyConversion: false) else {
      throw .invalidValue(enigma, .init(
        codingPath: [], debugDescription: "JSON cannot be represented in the requested text encoding"
      ))
    }
    return data
  }
}
