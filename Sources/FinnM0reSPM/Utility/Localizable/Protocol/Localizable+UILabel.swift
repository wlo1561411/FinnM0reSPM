import Foundation
import UIKit

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
