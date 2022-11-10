import UIKit

extension UIView: StylerCompatible { }

public extension Styler where Base: UIView {
    @discardableResult
    func backgroundColor(_ color: UIColor) -> Self {
        base.backgroundColor = color
        return self
    }
    
    @discardableResult
    func borderColor(_ color: UIColor) -> Self {
        base.layer.borderColor = color.cgColor
        return self
    }
    
    @discardableResult
    func borderWidth(_ width: CGFloat) -> Self {
        base.layer.borderWidth = width
        return self
    }
    
    @discardableResult
    func cornerRadius(_ radius: CGFloat) -> Self {
        base.clipsToBounds = true
        base.layer.cornerRadius = radius
        return self
    }
}
