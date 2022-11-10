import UIKit

extension Styler where Base: UILabel {
    @discardableResult
    public func font(_ font: UIFont) -> Self {
        base.font = font
        return self
    }
    
    @discardableResult
    public func textColor(_ controlState: UIControl.State = .normal, _ color: UIColor) -> Self {
        base.textColor = color
        return self
    }
}
