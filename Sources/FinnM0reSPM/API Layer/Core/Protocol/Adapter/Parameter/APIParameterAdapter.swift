import Foundation

/// 請整請求參數的抽象化協議
public protocol APIParameterAdapter {
    /// 組建新的參數
    /// - Parameter parameter: 現有的參數
    /// - Returns: 新的參數
    func adapted(_ parameter: APIParameterConvertible) throws -> APIParameterConvertible
}
