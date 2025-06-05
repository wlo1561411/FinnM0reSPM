import Foundation
import UIKit

/// 多語言畫面更新介面
protocol Localizable {
    /// 依據當前語言`全部`更新
    func updateLocalization(by contents: [LocalizationContent])
    /// 依據當前語言`替換`掉所指定的 content
    func replaceLocalization(by old: [LocalizationContent], by new: [LocalizationContent])
}
