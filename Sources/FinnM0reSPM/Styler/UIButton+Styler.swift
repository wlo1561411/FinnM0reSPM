import UIKit

extension Styler where Base: UIButton {
    @discardableResult
    public func font(_ font: UIFont) -> Self {
        base.titleLabel?.font = font
        return self
    }
    
    @discardableResult
    public func textColor(_ controlState: UIControl.State, _ color: UIColor) -> Self {
        base.setTitleColor(color, for: controlState)
        return self
    }
}
