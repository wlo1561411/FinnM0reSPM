import Foundation

extension APILayer {
    public enum HTTPMethod: String {
        case GET
        case POST
        #warning("TODO: 等待實作")
        //    case PUT
        //    case PATCH
        //    case DELETE
        //    case HEAD
    }
}

// MARK: - Adapter

extension APILayer.HTTPMethod {
    public var adapter: APIRequestAnyAdapter {
        .init { request in
            var request = request
            request.httpMethod = rawValue
            return request
        }
    }
}
