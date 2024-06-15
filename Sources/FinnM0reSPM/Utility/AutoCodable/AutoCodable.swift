import Foundation

public protocol AutoCodable: Codable {
    init()
}

extension AutoCodable {
    public init(from decoder: Decoder) throws {
        self.init()
        for (path, decodable) in decodablePaths {
            try decodable.decodeWrappedValue(
                at: path,
                from: decoder,
                target: String(describing: type(of: self)))
        }
    }

    private var decodablePaths: [(AutoDecodePath, WrappedDecodable)] {
        Mirror(reflecting: self)
            .children
            .compactMap { key, value in
                guard 
                    var key, key.isEmpty == false,
                    let decodable = value as? WrappedDecodable
                else {
                    return nil
                }
                
                if key.hasPrefix("_") {
                    key.remove(at: key.startIndex)
                }

                return (AutoDecodePath(type: .key(key)), decodable)
            }
    }
}
