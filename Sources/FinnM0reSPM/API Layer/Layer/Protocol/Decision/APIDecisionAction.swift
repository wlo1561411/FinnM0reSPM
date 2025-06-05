import Foundation

/// 執行決策後的動作
public enum APIDecisionAction<Request: APILayer.Request> {
    /// 繼續下一個決策
    case `continue`(Data, HTTPURLResponse)
    /// 帶入新的決策，重新進行請求
    case restart([APIDecision])
    /// 拋出錯誤
    case error(Error)
    /// 正常完成請求，後續的決策全數不執行
    case done(Request.Response)
}
