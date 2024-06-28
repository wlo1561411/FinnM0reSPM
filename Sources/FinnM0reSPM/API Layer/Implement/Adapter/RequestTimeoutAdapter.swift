import Foundation

extension APILayer {
    /// 設定 timeout
    struct RequestTimeoutAdapter: APIRequestAdapter {
        let timeout: TimeInterval

        func adapted(_ request: URLRequest) throws -> URLRequest {
            var request = request
            request.timeoutInterval = timeout
            return request
        }
    }
}
