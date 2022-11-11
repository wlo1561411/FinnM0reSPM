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
    
    @discardableResult
    public func gradient(
        _ axis: NSLayoutConstraint.Axis,
        colors: [CGColor],
        completion: ((CAGradientLayer) -> Void)? = nil
    ) -> Self {
        let start: CGPoint
        let end: CGPoint
        
        switch axis {
        case .horizontal:
            start = CGPoint(x: 0, y: 0.5)
            end = CGPoint(x: 1, y: 0.5)
        case .vertical:
            start = CGPoint(x: 0.5, y: 0)
            end = CGPoint(x: 0.5, y: 1)
        @unknown default:
            start = .zero
            end = .zero
        }
        
        completion?(
            applyGradient(startPoint: start, endPoint: end, colors: colors)
        )
        
        return self
    }

    func applyGradient(startPoint: CGPoint, endPoint: CGPoint, colors: [CGColor]) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.colors = colors
        layer.startPoint = startPoint
        layer.endPoint = endPoint
        
        DispatchQueue.main.async {
            layer.frame = self.base.bounds
            self.base.layer.insertSublayer(layer, at: 0)
        }
        return layer
    }
    
    /// nil means set to identity
    @discardableResult
    public func rotate(_ angle: CGFloat?, clockwise: Bool = true) -> Self {
        UIView.animate(withDuration: 0.2) {
            if let angle = angle {
                let _angle = clockwise ? angle : -angle
                self.base.transform = CGAffineTransform(rotationAngle: _angle / 180 * CGFloat(Double.pi))
            }
            else {
                self.base.transform = .identity
            }
        }
        return self
    }
    
    @discardableResult
    public func blur(alpha: CGFloat = 0.8, style: UIBlurEffect.Style = .dark) -> Self {
        let effect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: effect)
        blurView.alpha = alpha
        
        base.addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return self
    }
    
    public enum Visibility: String {
        case visible
        case invisible
        case gone
    }
    
    public var visibility: Visibility {
        let constraint = base.constraints
            .filter {
                $0.firstAttribute == .height && $0.constant == 0
            }
            .first
        
        if let constraint = constraint, constraint.isActive {
            return .gone
        } else {
            return base.isHidden ? .invisible : .visible
        }
    }
    
    @discardableResult
    public func visibility(_ new: Visibility) -> Self {
        guard visibility != new else { return self }
        
        let constraints = base.constraints
            .filter {
                $0.firstAttribute == .height &&
                $0.constant == 0 &&
                $0.secondItem == nil &&
                ($0.firstItem as? UIView) == base
            }
        
        let constraint = constraints.first

        switch new {
        case .visible:
            constraint?.isActive = false
            base.isHidden = false
            
        case .invisible:
            constraint?.isActive = false
            base.isHidden = true
            
        case .gone:
            base.isHidden = true
            
            if let constraint = constraint {
                constraint.isActive = true
            }
            else {
                let constraint = NSLayoutConstraint(
                    item: base,
                    attribute: .height,
                    relatedBy: .equal,
                    toItem: nil,
                    attribute: .height,
                    multiplier: 1,
                    constant: 0
                )
                base.addConstraint(constraint)
                constraint.isActive = true
            }
            base.setNeedsLayout()
            base.setNeedsUpdateConstraints()
        }
        
        return self
    }
}
