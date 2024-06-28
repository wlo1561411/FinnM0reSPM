import Foundation

extension APILayer {
    public struct RequestContentAdapter: APIRequestAdapter {
        public let method: HTTPMethod
        public let contentType: ContentType
        public let content: APIParameterConvertible

        public func adapted(_ request: URLRequest) throws -> URLRequest {
            switch method {
            case .GET:
                return try URLQueryDataAdapter(data: content).adapted(request)

            case .POST:
                let headerAdapter = contentType.headerAdapter
                let dataAdapter = contentType.dataAdapter(for: content)
                let request = try headerAdapter.adapted(request)
                return try dataAdapter.adapted(request)
            }
        }
    }
}
