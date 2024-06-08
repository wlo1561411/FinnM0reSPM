import Foundation

/// API 請求參數的抽象介面
public protocol APIParameterConvertible {
    var dictionary: [String: Any] { get }
}

// MARK: - [String: Any]

extension [String: Any]: APIParameterConvertible {
    public var dictionary: [String: Any] {
        self
    }
}

// MARK: - Encodable

extension APIParameterConvertible where Self: Encodable {
    public var dictionary: [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else { return [:] }
        return (
            try? JSONSerialization
                .jsonObject(with: data, options: .mutableContainers))
            .flatMap { $0 as? [String: Any] } ?? [:]
    }
}
