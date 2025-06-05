import Foundation

/// Log 決策
public protocol APILogDecision {
    /// 判別是否執行此決策
    /// - Parameters:
    ///   - request: 發出的請求
    ///   - logInfo: Log 資訊
    /// - Returns: `true` 則執行此決策；反之則判斷下一個決策
    func shouldApply<Request: APILayer.Request>(request: Request, logInfo: APILogInfo) -> Bool

    /// 執行決策
    /// - Parameters:
    ///   - request: 發出的請求
    ///   - logInfo: Log 資訊
    func apply<Request: APILayer.Request>(request: Request, logInfo: APILogInfo)
}
