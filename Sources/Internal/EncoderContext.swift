import Foundation

final class EncoderContext: @unchecked Sendable {
  var enigma: Enigma?

  func store(value: Enigma, path: [CodingKey]) throws {
    enigma = try patch(enigma: enigma, value: value, path: path, deep: 0)
  }

  func makeKeyed<K: CodingKey>(path: [CodingKey]) -> KeyedEncodingContainer<K> {
    KeyedEncodingContainer(KeyedEncoder<K>(context: self, codingPath: path))
  }

  func makeUnkeyed(path: [CodingKey]) -> UnkeyedEncoder {
    UnkeyedEncoder(context: self, codingPath: path)
  }

  func makeValue(path: [CodingKey]) -> ValueEncoder {
    ValueEncoder(context: self, codingPath: path)
  }

  func patch(enigma: Enigma?, value: Enigma, path: [CodingKey], deep: Int) throws -> Enigma {
    guard deep < path.count else {
      guard let enigma = enigma else { return value }
      guard enigma != value else { return enigma }
      guard enigma != .dictionary([:]) else { return value }
      throw EncodingError.invalidValue(value, EncodingError.Context(
        codingPath: path,
        debugDescription: "attempt to change \(enigma.debugDescription)"
      ))
    }
    let key = path[deep]
    let deep = deep + 1
    if case .index(let index) = key as? CommonKey {
      var array: [Enigma]
      if let enigma = enigma {
        switch enigma {
        case .array(let value): array = value
        case .dictionary([:]): array = []
        default:
          throw EncodingError.invalidValue(value, EncodingError.Context(
            codingPath: path,
            debugDescription: "attempt to change index \(index) of \(enigma.debugDescription)"
          ))
        }
      } else {
        array = []
      }
      if index < array.count {
        array[index] = try patch(enigma: array[index], value: value, path: path, deep: deep)
      } else {
        try array.append(patch(enigma: nil, value: value, path: path, deep: deep))
      }
      return .array(array)
    } else {
      let key = key.stringValue
      var dictionary: [String: Enigma]
      if let enigma = enigma {
        switch enigma {
        case .array([]): dictionary = [:]
        case .dictionary(let value): dictionary = value
        default:
          throw EncodingError.invalidValue(value, EncodingError.Context(
            codingPath: path,
            debugDescription: "attempt to change key \(key) of \(enigma.debugDescription)"
          ))
        }
      } else {
        dictionary = [:]
      }
      if let index = dictionary.keys.firstIndex(of: key) {
        dictionary.values[index] = try patch(
          enigma: dictionary.values[index], value: value, path: path, deep: deep
        )
      } else {
        dictionary[key] = try patch(enigma: nil, value: value, path: path, deep: deep)
      }
      return .dictionary(dictionary)
    }
  }
}
