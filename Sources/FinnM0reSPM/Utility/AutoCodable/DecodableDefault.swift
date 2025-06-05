import Foundation

protocol WrappedDecodable {
    func decodeWrappedValue(at path: AutoDecodePath, from decoder: Decoder, target: String) throws
}

@propertyWrapper
public final class DecodableDefault<Value> {
    private var isDecoded = false

    private var decodedValue: Value?
    private var defaultValue: Value?

    let decoder: AutoDecoder<Value>
    let context: AutoDecoderContext

    public var wrappedValue: Value {
        get {
            let value: Value? = isDecoded ? (decodedValue ?? defaultValue) : defaultValue
            guard let wrappedValue = value
            else {
                fatalError("\(type(of: self)) error")
            }
            return wrappedValue
        } 
        set {
            isDecoded = true
            decodedValue = newValue
        }
    }

    public convenience init(
        _ defaultValue: Value? = nil,
        path: String = "")
        where Value: Decodable
    {
        let decoder = AutoDecoder<Value>(configuration: { input in
            try input.decoder.decode(
                Value.self,
                path: input.context.preferredPath,
                target: input.target)
        })

        self.init(
            defaultValue,
            path: path.isEmpty ? nil : .init(type: .key(path)),
            decoder: decoder)
    }

    init(
        _ defaultValue: Value? = nil,
        path: AutoDecodePath? = nil,
        decoder: AutoDecoder<Value>)
    {
        self.defaultValue = defaultValue ?? Self.extractDefaultValue()
        self.decoder = decoder
        self.context = .init(givenPath: path)
    }

    private static func extractDefaultValue<T>() -> T? {
        guard
            let type = T.self as? ExpressibleByNilLiteral.Type,
            let none = type.init(nilLiteral: ()) as? T
        else {
            return nil
        }
        return .some(none)
    }
}

// MARK: - WrappedDecodable

extension DecodableDefault: WrappedDecodable {
    func decodeWrappedValue(
        at inferredPath: AutoDecodePath,
        from decoder: Decoder,
        target: String) throws
    {
        isDecoded = true
        do {
            var context = context
            context.inferredPath = inferredPath
            decodedValue = try self.decoder.configuration((decoder, context, target))
        }
        catch {
            if (decodedValue ?? defaultValue) == nil {
                throw error
            }
        }
    }
}

// MARK: - Encodable

extension DecodableDefault: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}
