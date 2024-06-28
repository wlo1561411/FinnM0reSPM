import Foundation

extension APILayer {
    public struct URLQueryDataAdapter: APIRequestAdapter {
        public let data: APIParameterConvertible

        public func adapted(_ request: URLRequest) throws -> URLRequest {
            var request = request

            guard
                let url = request.url,
                var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
            else {
                throw URLError(.badURL)
            }

            var queryItems = urlComponents.queryItems ?? []
            
            queryItems += data
                .dictionary
                .map {
                    .init(name: $0.key, value: "\($0.value)")
                }

            urlComponents.queryItems = queryItems

            request.url = urlComponents.url
            return request
        }
    }
}
