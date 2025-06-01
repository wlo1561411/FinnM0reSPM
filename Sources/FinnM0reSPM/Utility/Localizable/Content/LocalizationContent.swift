import UIKit

/// 多語言物件介面
protocol LocalizationContent {
    /// key
    var key: String { get }
    /// arguments
    var arguments: any CVarArg { get }

    /// 多語言橋接
    var bridge: LocalizableBridge { get }

    /// 創建時當下的 localized text
    /// 主要是用來做 replacing
    var currentLocalized: String { get }

    /// 獲取當前語言的新物件
    func refresh() -> Self
}

// MARK: - Default Implement

extension LocalizationContent {
    var bridge: LocalizableBridge {
        MockLocalizableBridge.shared
    }

    /// 根據 key, arguments 轉換成當下語言的 text
    var localized: String {
        bridge.localized(key: key, arguments: arguments)
    }
}

// MARK: - Factory

struct LocalizationContentFactory {
    /// 建立單一狀態 LocalizationContent
    static func general(_ key: String, arguments: [String] = []) -> [LocalizationContent] {
        [GeneralLocalizationContent(key: key, arguments: arguments)]
    }

    /// 建立多狀態 LocalizationContent
    static func stateful(isEnable: GeneralLocalizationContent,
                         isDisable: GeneralLocalizationContent? = nil,
                         isSelected: GeneralLocalizationContent? = nil) -> [LocalizationContent] {
        var contents: [StatefulLocalizationContent] = [
            .init(key: isEnable.key, arguments: isEnable.arguments, state: .normal)
        ]

        if let isDisable {
            contents.append(.init(key: isDisable.key, arguments: isDisable.arguments, state: .disabled))
        }

        if let isSelected {
            contents.append(.init(key: isSelected.key, arguments: isSelected.arguments, state: .selected))
        }

        return contents
    }
}

// MARK: - Implement

/// 通用 LocalizationContent
///
/// 只有單一狀態
struct GeneralLocalizationContent: LocalizationContent {
    let key: String
    let arguments: any CVarArg

    var currentLocalized: String = ""

    init(key: String, arguments: any CVarArg) {
        self.key = key
        self.arguments = arguments
        self.currentLocalized = localized
    }

    func refresh() -> GeneralLocalizationContent {
        .init(key: key, arguments: arguments)
    }
}

/// 多狀態 LocalizationContent
struct StatefulLocalizationContent: LocalizationContent {
    let key: String
    let arguments: any CVarArg
    let state: UIControl.State

    var currentLocalized: String = ""

    init(key: String, arguments: any CVarArg, state: UIControl.State) {
        self.key = key
        self.arguments = arguments
        self.state = state
        self.currentLocalized = localized
    }

    func refresh() -> StatefulLocalizationContent {
        .init(key: key, arguments: arguments, state: state)
    }
}
