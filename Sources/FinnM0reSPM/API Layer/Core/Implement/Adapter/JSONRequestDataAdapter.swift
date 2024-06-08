import Foundation

extension APILayer {
    public struct JSONRequestDataAdapter: APIRequestAdapter {
        let data: APIParameterConvertible

        public func adapted(_ request: URLRequest) throws -> URLRequest {
            var request = request
            
            request.httpBody = try JSONSerialization.data(
                withJSONObject: data.dictionary,
                options: [])

            return request
        }
    }
}
