import Foundation
import UIKit

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
