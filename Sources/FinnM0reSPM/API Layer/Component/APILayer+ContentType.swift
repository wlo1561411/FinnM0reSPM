import Foundation

extension APILayer {
    public enum ContentType: String {
        case json = "application/json"
        case urlForm = "application/x-www-form-urlencoded"
    }
}

// MARK: - Adapter

extension APILayer.ContentType {
    public var headerAdapter: APIRequestAnyAdapter {
        .init { req in
            var req = req
            req.setValue(rawValue, forHTTPHeaderField: "Content-Type")
            return req
        }
    }

    public func dataAdapter(for data: any APIParameterConvertible) -> APIRequestAdapter {
        switch self {
        case .json:
            return APILayer.JSONRequestDataAdapter(data: data)
        case .urlForm:
            return APILayer.URLFormRequestDataAdapter(data: data)
        }
    }
}
