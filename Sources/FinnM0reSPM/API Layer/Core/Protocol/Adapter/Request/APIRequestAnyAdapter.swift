import Foundation

/// 自定義構建請求內容
public struct APIRequestAnyAdapter: APIRequestAdapter {
    /// 自定請求結構
    let closure: (URLRequest) throws -> URLRequest

    public init(closure: @escaping (URLRequest) throws -> URLRequest) {
        self.closure = closure
    }

    public func adapted(_ request: URLRequest) throws -> URLRequest {
        try closure(request)
    }
}
