import UIKit

extension Styler where Base: UILabel {
    @discardableResult
    public func font(_ font: UIFont) -> Self {
        base.font = font
        return self
    }
    
    @discardableResult
    public func textColor(_ color: UIColor, state: UIControl.State = .normal) -> Self {
        base.textColor = color
        return self
    }
    
    @discardableResult
    public func text(_ text: String?, state: UIControl.State = .normal) -> Self {
        base.text = text
        return self
    }
}
