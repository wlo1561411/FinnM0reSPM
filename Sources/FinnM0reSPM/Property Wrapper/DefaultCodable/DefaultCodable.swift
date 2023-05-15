import Foundation

protocol DefaultValue {
  associatedtype Value: Codable
  static var defaultValue: Value { get }
}

@propertyWrapper
struct Default<T: DefaultValue> {
  var wrappedValue: T.Value
  
  init(wrappedValue: T.Value) {
    self.wrappedValue = wrappedValue
  }
  
  init(_ decodableValue: T) {
    self.wrappedValue = T.defaultValue
  }
}

extension Default: Codable {
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    wrappedValue = (try? container.decode(T.Value.self)) ?? T.defaultValue
  }
}

extension KeyedDecodingContainer {
  func decode<T>(
    _ type: Default<T>.Type,
    forKey key: Key)
    throws -> Default<T>
    where T: DefaultValue
  {
    try decodeIfPresent(type, forKey: key) ?? Default(wrappedValue: T.defaultValue)
  }
}
