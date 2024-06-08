import Foundation

/// API 請求結構協議
public protocol APIRequest {
    /// 收到正常回應的格式
    associatedtype Response: Codable

    /// API Server 路徑
    var baseURL: URL? { get }
    /// API 路徑
    var path: String { get }
    /// API HTTP 方法
    var method: APILayer.HTTPMethod { get }
    /// 請求參數
    var parameters: APIParameterConvertible { get set }
    /// 參數格式
    var contentType: APILayer.ContentType { get }
    /// 額外的標頭
    var extraHeader: [String: String] { get }
    /// 連線優先級
    var priority: APILayer.RequestPriority { get }
    /// 請求超時設定
    var timeout: TimeInterval { get }
    /// 重新請求次數
    var retryCount: Int { get }
    /// 請求端口
    var client: APILayer.HTTPClient { get }
    /// 是否 print local log
    var isEnableDebugLog: Bool { get }
    /// 「調整」請求參數的組合器
    var parameterAdapters: [APIParameterAdapter] { get }
    /// 「建構」請求的組合器
    var adapters: [APIRequestAdapter] { get }
    /// 收到回應後，「依序」要執行的決策
    var decisions: [APIDecision] { get }
    /// 處理是否要 print local log 或是 post log
    var logDecisions: [APILogDecision] { get }
    /// 建立出 LogInfo 讓 logDecisions 使用
    func buildLogInfo(
        request: URLRequest,
        originalRequestDate: Date,
        realRequestDate: Date,
        responseDate: Date,
        response: HTTPURLResponse?,
        data: Data?,
        error: Error?) -> APILogInfo
}

// MARK: - Default Implement

extension APIRequest {
    public var url: URL? {
        URL(string: path, relativeTo: baseURL)
    }

    public var priority: APILayer.RequestPriority {
        .default
    }

    public var extraHeader: [String: String] {
        [:]
    }

    public var timeout: TimeInterval {
        30
    }

    public var retryCount: Int {
        1
    }

    public var parameterAdapters: [APIParameterAdapter] {
        []
    }

    public var adapters: [APIRequestAdapter] {
        [
            method.adapter,
            APILayer.RequestExtraHeaderAdapter(header: extraHeader),
            APILayer.RequestContentAdapter(method: method, contentType: contentType, content: parameters),
            APILayer.RequestTimeoutAdapter(timeout: timeout),
        ]
    }

    public var decisions: [APIDecision] {
        [
            APILayer.RetryDecision(leftCount: retryCount),
            APILayer.ParseResultDecision()
        ]
    }

    public var logDecisions: [APILogDecision] {
        [
            APILayer.DebugLogDecision()
        ]
    }

    public func send(
        decisions: [APIDecision]? = nil,
        queue: DispatchQueue,
        handler: @escaping (Result<Response, Error>) -> Void)
    {
        client.send(
            self,
            decisions: decisions,
            queue: queue,
            handler: handler)
    }

    public func send(
        decisions: [APIDecision]? = nil,
        queue: DispatchQueue)
        async throws -> Response
    {
        try await withCheckedThrowingContinuation { continuation in
            client.send(
                self,
                decisions: decisions,
                queue: queue,
                handler: {
                    switch $0 {
                    case .success(let response):
                        continuation.resume(returning: response)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                })
        }
    }

    public func buildLogInfo(
        request: URLRequest,
        originalRequestDate: Date,
        realRequestDate: Date,
        responseDate: Date,
        response: HTTPURLResponse?,
        data: Data?,
        error: Error?)
        -> APILogInfo
    {
        APILayer.DefaultLogInfo(
            request: request,
            originalRequestDate: originalRequestDate,
            realRequestDate: realRequestDate,
            responseDate: responseDate,
            response: response,
            data: data,
            error: error)
    }
}

// MARK: - Extension

extension APIRequest {
    mutating func attachMoreParameter() throws {
        parameters = try parameterAdapters
            .reduce(parameters) {
                try $1.adapted($0).dictionary
            }
    }

    func buildRequest() throws -> URLRequest {
        guard let url else { throw URLError(.badURL) }
        let request = URLRequest(url: url)
        return try adapters
            .reduce(request) {
                try $1.adapted($0)
            }
    }
}
