import UIKit

extension UIView: StylerCompatible { }

extension Styler where Base: UIView {
    @discardableResult
    public func backgroundColor(_ color: UIColor) -> Self {
        base.backgroundColor = color
        return self
    }
    
    @discardableResult
    public func borderColor(_ color: UIColor) -> Self {
        base.layer.borderColor = color.cgColor
        return self
    }
    
    @discardableResult
    public func borderWidth(_ width: CGFloat) -> Self {
        base.layer.borderWidth = width
        return self
    }
    
    @discardableResult
    public func round(_ radius: CGFloat) -> Self {
        base.clipsToBounds = true
        base.layer.cornerRadius = radius
        return self
    }
    
    @discardableResult
    public func dottedBorder(
        _ color: UIColor,
        lineDashPattern: [Int] = [8,4],
        lineWidth: CGFloat = 1,
        radius: CGFloat = 5
    ) -> Self {
        DispatchQueue.main.async {
            let border = CAShapeLayer()
            border.strokeColor = color.cgColor
            border.fillColor = .none
            border.path = UIBezierPath(roundedRect: self.base.bounds, cornerRadius: radius).cgPath
            border.frame = self.base.bounds
            border.lineWidth = lineWidth
            border.lineDashPattern = [8,4]
            
            self.base.layer.cornerRadius = radius
            self.base.layer.masksToBounds = true
            self.base.layer.addSublayer(border)
        }
        return self
    }
    
    @discardableResult
    public func round(at corners: CACornerMask, radius: CGFloat) -> Self {
        base.clipsToBounds = true
        base.layer.cornerRadius = radius
        base.layer.maskedCorners = corners
        return self
    }
    
    @discardableResult
    public func shadow(
        color: UIColor = .black,
        opacity: Float,
        offset: CGSize,
        shadowRadius: CGFloat,
        cornerRadius: CGFloat,
        scale: Bool = true
    ) -> Self {
        DispatchQueue.main.async {
            self.base.clipsToBounds = false
            self.base.layer.cornerRadius = cornerRadius
            self.base.layer.shadowColor = color.cgColor
            self.base.layer.shadowOpacity = opacity
            self.base.layer.shadowOffset = offset
            self.base.layer.shadowRadius = shadowRadius
            self.base.layer.shadowPath =  UIBezierPath(roundedRect: self.base.bounds, cornerRadius: cornerRadius).cgPath
            self.base.layer.shouldRasterize = true
            self.base.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
        }
        return self
    }
}
