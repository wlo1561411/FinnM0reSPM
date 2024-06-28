import Foundation

extension APILayer {
    public struct RequestExtraHeaderAdapter: APIRequestAdapter {
        public let header: [String: String]

        public func adapted(_ request: URLRequest) throws -> URLRequest {
            var request = request

            for item in header {
                request.setValue(item.value, forHTTPHeaderField: item.key)
            }

            return request
        }
    }
}
