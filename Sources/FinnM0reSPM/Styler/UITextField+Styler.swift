import UIKit

extension Styler where Base: UITextField {
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
    
    @discardableResult
    public func placeholder(_ text: String?, color: UIColor = .lightGray) -> Self {
        base.attributedPlaceholder = text?
            .attributed
            .textColor(color)
            .font(base.font ?? .systemFont(ofSize: 16))
        return self
    }
    
    public enum Padding {
        case horizontal
        case left
        case right
    }
    
    @discardableResult
    public func padding(_ padding: Padding, offset: CGFloat) -> Self {
        switch padding {
        case .horizontal:
            let lv = UIView(frame: .init(origin: .zero, size: .init(width: offset, height: 1)))
            let rv = UIView(frame: .init(origin: .zero, size: .init(width: offset, height: 1)))
            base.leftViewMode = .always
            base.rightViewMode = .always
            base.leftView = lv
            base.rightView = rv
            
        case .left:
            let lv = UIView(frame: .init(origin: .zero, size: .init(width: offset, height: 1)))
            base.leftViewMode = .always
            base.leftView = lv
            
        case .right:
            let rv = UIView(frame: .init(origin: .zero, size: .init(width: offset, height: 1)))
            base.rightViewMode = .always
            base.rightView = rv
        }
        return self
    }
}
