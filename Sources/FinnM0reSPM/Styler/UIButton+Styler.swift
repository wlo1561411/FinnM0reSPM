import UIKit

public extension Styler where Base: UIButton {
    @discardableResult
    func font(_ font: UIFont) -> Self {
        base.titleLabel?.font = font
        return self
    }
    
    @discardableResult
    func textColor(_ controlState: UIControl.State, _ color: UIColor) -> Self {
        base.setTitleColor(color, for: controlState)
        return self
    }
}
