import Foundation

extension APILayer {
    public struct URLFormRequestDataAdapter: APIRequestAdapter {
        let data: APIParameterConvertible

        public func adapted(_ request: URLRequest) throws -> URLRequest {
            var request = request
            var urlComponents = URLComponents()

            urlComponents.queryItems = data
                .dictionary
                .map {
                    .init(name: $0.key, value: "\($0.value)")
                }

            request.httpBody = urlComponents.query?.data(using: .utf8)

            return request
        }
    }
}
