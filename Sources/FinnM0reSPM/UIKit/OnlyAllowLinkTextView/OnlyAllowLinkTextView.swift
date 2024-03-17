import UIKit

public class OnlyAllowLinkTextView: UITextView {
    /// 只有當使用者觸摸的點位於 UITextView 中的一個 *link* 上時，這個點才被認為是在 UITextView 的內部
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard
            super.point(inside: point, with: event),
            // 找到給定點最接近的文字位置
            let pos = closestPosition(to: point),
            // 尋找包圍指定位置的字元範圍
            let range = tokenizer.rangeEnclosingPosition(pos, with: .character, inDirection: .layout(.left))
        else { return false }

        let startIndex = offset(from: beginningOfDocument, to: range.start)

        // 檢查在 startIndex 位置的屬性文字是否有連結屬性（.link）。如果有，則傳回 true，表示點在連結上
        return attributedText.attribute(.link, at: startIndex, effectiveRange: nil) != nil
    }
}
