import UIKit

public extension Styler where Base: UIButton {
    @discardableResult
    func font(_ font: UIFont) -> Self {
        base.titleLabel?.font = font
        return self
    }

    @discardableResult
    func titleColor(_ color: UIColor, state: UIControl.State = .normal) -> Self {
        base.setTitleColor(color, for: state)
        return self
    }

    @discardableResult
    func title(_ text: String?, state: UIControl.State = .normal) -> Self {
        base.setTitle(text, for: state)
        return self
    }

    @discardableResult
    func enable(_ enable: Bool) -> Self {
        base.alpha = enable ? 1 : 0.2
        base.isEnabled = enable
        return self
    }
}
