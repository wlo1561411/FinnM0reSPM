import UIKit

/// 多語言物件介面
protocol LocalizationContent {
    /// key
    var key: String { get }
    /// arguments
    var arguments: [CVarArg] { get }

    /// 獲取多語言
    var provider: LocalizationProvider { get }

    /// 創建時當下的 localized text
    /// 主要是用來做 replacing
    var currentLocalized: String { get }

    /// 獲取當前語言的新物件
    func refresh() -> Self
}

// MARK: - Default Implement

extension LocalizationContent {
    /// 根據 key, arguments 轉換成當下語言的 text
    var localized: String {
        provider.localized(key: key, arguments: arguments)
    }
}

// MARK: - Implement

/// 通用 LocalizationContent
///
/// 只有單一狀態
struct GeneralLocalizationContent: LocalizationContent {
    let key: String
    let arguments: [CVarArg]
    let provider: LocalizationProvider

    var currentLocalized = ""

    init(key: String,
         arguments: [CVarArg],
         provider: LocalizationProvider) {
        self.key = key
        self.arguments = arguments
        self.provider = provider
        self.currentLocalized = localized
    }

    func refresh() -> GeneralLocalizationContent {
        .init(key: key, arguments: arguments, provider: provider)
    }
}

/// 多狀態 LocalizationContent
struct StatefulLocalizationContent: LocalizationContent {
    let key: String
    let arguments: [CVarArg]
    let provider: LocalizationProvider
    let state: UIControl.State

    var currentLocalized = ""

    init(key: String,
         arguments: [CVarArg],
         provider: LocalizationProvider,
         state: UIControl.State) {
        self.key = key
        self.arguments = arguments
        self.provider = provider
        self.state = state
        self.currentLocalized = localized
    }

    func refresh() -> StatefulLocalizationContent {
        .init(key: key, arguments: arguments, provider: provider, state: state)
    }
}
