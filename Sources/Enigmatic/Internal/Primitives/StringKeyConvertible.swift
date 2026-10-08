protocol StringKeyConvertible: Hashable {
  var asStringKey: String { get }
}

extension String: StringKeyConvertible {
  var asStringKey: String {
    self
  }
}

extension StringKeyConvertible where Self: LosslessStringConvertible {
  var asStringKey: String {
    String(self)
  }
}

extension Int: StringKeyConvertible {}
extension Int8: StringKeyConvertible {}
extension Int16: StringKeyConvertible {}
extension Int32: StringKeyConvertible {}
extension Int64: StringKeyConvertible {}
extension UInt: StringKeyConvertible {}
extension UInt8: StringKeyConvertible {}
extension UInt16: StringKeyConvertible {}
extension UInt32: StringKeyConvertible {}
extension UInt64: StringKeyConvertible {}
