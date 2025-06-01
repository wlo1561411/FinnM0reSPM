import Foundation
import UIKit

/// 多語言畫面更新介面
protocol Localizable {
    /// 依據當前語言`全部`更新
    func updateLocalization(by contents: [LocalizationContent])
    /// 依據當前語言`替換`掉所指定的 content
    func replaceLocalization(by old: [LocalizationContent], by new: [LocalizationContent])
}

// MARK: - Implement

extension UILabel: Localizable {
    func updateLocalization(by contents: [any LocalizationContent]) {
        // Label 都只有單一狀態, 取 first 就好
        guard let first = contents.first
        else {
            return
        }

        text = first.localized
    }

    func replaceLocalization(by old: [any LocalizationContent], by new: [any LocalizationContent]) {
        // Label 都只有單一狀態, 取 first 就好
        guard
            text?.isEmpty == false,
            let old = old.first,
            text?.contains(old.currentLocalized) == true,
            let new = new.first
        else {
            return
        }

        text = text?.replacingOccurrences(of: old.currentLocalized, with: new.localized)
    }
}

extension UIButton: Localizable {
    func updateLocalization(by contents: [any LocalizationContent]) {
        for content in contents {
            if let stateful = content as? StatefulLocalizationContent {
                setTitle(stateful.localized, for: stateful.state)
            } else {
                setTitle(content.localized, for: .normal)
            }
        }
    }

    func replaceLocalization(by old: [any LocalizationContent], by new: [any LocalizationContent]) {
        let allStates: [UIControl.State] = [.normal, .highlighted, .disabled, .selected]

        for state in allStates {
            guard let currentTitle = title(for: state), !currentTitle.isEmpty
            else {
                continue
            }

            // 嘗試找對應 state 的 content
            let old = old.first(where: {
                if let content = $0 as? StatefulLocalizationContent {
                    return content.state == state
                } else {
                    // fallback, 只有單一狀態
                    return state == .normal
                }
            })

            let new = new.first(where: {
                if let content = $0 as? StatefulLocalizationContent {
                    return content.state == state
                } else {
                    return state == .normal
                }
            })

            guard
                let old,
                currentTitle.contains(old.currentLocalized) == true,
                let new
            else {
                continue
            }

            let updated = currentTitle.replacingOccurrences(of: old.currentLocalized, with: new.localized)

            setTitle(updated, for: state)
        }
    }
}
