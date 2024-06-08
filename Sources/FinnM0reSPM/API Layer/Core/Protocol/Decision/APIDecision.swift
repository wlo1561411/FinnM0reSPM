import Foundation

/// 建構收到回應後執行決策的抽象化協議
public protocol APIDecision {
    /// 判別是否執行此決策
    /// - Parameters:
    ///   - request: 發出的請求
    ///   - data: 收到的回應內容
    ///   - response: 收到的回應
    /// - Returns: `true` 則執行此決策；反之則判斷下一個決策
    func shouldApply<Request: APIRequest>(request: Request, data: Data, response: HTTPURLResponse) -> Bool

    /// 執行決策
    /// - Parameters:
    ///   - request: 發出的請求
    ///   - data: 收到的回應內容
    ///   - response: 收到的回應
    ///   - closure: 完成決策後的動作
    func apply<Request: APIRequest>(
        request: Request,
        data: Data,
        response: HTTPURLResponse,
        done closure: @escaping (APIDecisionAction<Request>) -> Void)
}

// MARK: - Extension

extension [APIDecision] {
    public func removing(_ item: APIDecision) -> Array {
        self.replacing(item, with: nil)
    }

    public func replacing(_ item: APIDecision, with newItem: APIDecision?) -> Array {
        var decisions = self

        guard
            let index = decisions.firstIndex(where: { type(of: $0) == type(of: item) })
        else { return self }

        _ = decisions.remove(at: index)

        if let newItem {
            decisions.insert(newItem, at: index)
        }

        return decisions
    }
}
