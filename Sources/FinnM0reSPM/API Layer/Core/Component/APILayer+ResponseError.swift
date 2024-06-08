import Foundation

extension APILayer {
    /// 回應錯誤類型
    public enum ResponseError: Error {
        /// 伺服器有回應，但無內容
        case nilData
        /// 伺服器有回應，但不是標準 HTTP 協議的定義
        case invalidHTTPResponse
        /// API 業務格式錯誤
        case api(error: Error, statusCode: Int)
    }
}
