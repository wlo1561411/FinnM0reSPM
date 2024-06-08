import Foundation

/// 構建請求結構的抽象化協議
public protocol APIRequestAdapter {
    /// 組件新的請求
    /// - Parameter request: 現有的請求結構
    /// - Returns: 新的請求結構
    func adapted(_ request: URLRequest) throws -> URLRequest
}
