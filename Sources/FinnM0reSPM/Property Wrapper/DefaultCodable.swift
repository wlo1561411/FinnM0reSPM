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
}

extension Default: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.wrappedValue = (try? container.decode(T.Value.self)) ?? T.defaultValue
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
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

// MARK: - Proxy

extension Int {
    struct Zero: DefaultValue {
        static var defaultValue = 0
    }
}

extension Optional: DefaultValue where Wrapped: Codable {
    static var defaultValue: Self { .none }
}
