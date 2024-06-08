import Foundation

extension APILayer {
    public struct DefaultLogInfo: APILogInfo {
        public let request: URLRequest
        public let originalRequestDate: Date
        public let realRequestDate: Date
        public let responseDate: Date
        public let response: HTTPURLResponse?
        public let data: Data?
        public let error: Error?
    }
}
