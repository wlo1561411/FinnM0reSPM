import Foundation

extension APILayer {
    public struct HTTPClient {
        public let session: URLSession

        /// 發送請求
        /// - Parameters:
        ///   - request: API 請求結構
        ///   - decisions: 收到回應後需執行的決策。如果為 nil，則使用預設決策
        ///   - handler: 執行決策後的結果
        public func send<Request: APIRequest>(
            _ request: Request,
            decisions: [APIDecision]? = nil,
            queue: DispatchQueue,
            handler: @escaping (Result<Request.Response, Error>) -> Void)
        {
            let originalRequestDate = Date()

            DispatchQueue.global().async {
                var request = request

                let urlRequest: URLRequest
                do {
                    try request.attachMoreParameter()
                    urlRequest = try request.buildRequest()
                }
                catch {
                    handler(.failure(error))
                    return
                }

                let realRequestDate = Date()
                let task = session
                    .dataTask(with: urlRequest) { data, response, error in
                        request.logDecisions
                            .forEach {
                                let logInfo = request.buildLogInfo(
                                    request: urlRequest,
                                    originalRequestDate: originalRequestDate,
                                    realRequestDate: realRequestDate,
                                    responseDate: Date(),
                                    response: response as? HTTPURLResponse,
                                    data: data,
                                    error: error)

                                guard $0.shouldApply(request: request, logInfo: logInfo) else { return }
                                $0.apply(request: request, logInfo: logInfo)
                            }

                        guard let data
                        else {
                            handler(.failure(error ?? APILayer.ResponseError.nilData))
                            return
                        }

                        guard let response = response as? HTTPURLResponse
                        else {
                            handler(.failure(APILayer.ResponseError.invalidHTTPResponse))
                            return
                        }

                        handleDecision(
                            request,
                            data: data,
                            response: response,
                            decisions: decisions ?? request.decisions,
                            queue: queue,
                            handler: handler)
                    }

                task.priority = min(1, max(0, request.priority.rawValue))
                task.resume()
            }
        }

        private func handleDecision<Request: APIRequest>(
            _ request: Request,
            data: Data,
            response: HTTPURLResponse,
            decisions: [APIDecision],
            queue: DispatchQueue,
            handler: @escaping (Result<Request.Response, Error>) -> Void)
        {
            guard decisions.isEmpty == false
            else {
                fatalError("沒有適用的決策")
            }

            var decisions = decisions
            let current = decisions.removeFirst()

            guard current.shouldApply(request: request, data: data, response: response)
            else {
                handleDecision(
                    request,
                    data: data,
                    response: response,
                    decisions: decisions,
                    queue: queue,
                    handler: handler)
                return
            }

            current.apply(request: request, data: data, response: response) { action in
                switch action {
                case .continue(let data, let response):
                    handleDecision(
                        request,
                        data: data,
                        response: response,
                        decisions: decisions,
                        queue: queue,
                        handler: handler)

                case .restart(let decisions):
                    send(request, decisions: decisions, queue: queue, handler: handler)

                case .error(let error):
                    queue.async {
                        handler(.failure(error))
                    }

                case .done(let value):
                    queue.async {
                        handler(.success(value))
                    }
                }
            }
        }
    }
}
