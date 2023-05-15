import UIKit

extension UIView: StylerCompatible { }

extension Styler where Base: UIView {
    @discardableResult
    public func other(_ closure: @escaping (Base) -> Void) -> Self {
        closure(base)
        return self
    }

    @discardableResult
    public func add(to view: UIView) -> Self {
        view.addSubview(base)
        return self
    }

    @discardableResult
    public func add(to stackView: UIStackView) -> Self {
        stackView.addArrangedSubview(base)
        return self
    }

    @discardableResult
    public func insert(to view: UIView, at: Int) -> Self {
        view.insertSubview(base, at: at)
        return self
    }

    @discardableResult
    public func insert(to stackView: UIStackView, at: Int) -> Self {
        stackView.insertArrangedSubview(base, at: at)
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
        lineDashPattern: [Int] = [8, 4],
        lineWidth: CGFloat = 1,
        radius: CGFloat = 5)
        -> Self
    {
        DispatchQueue.main.async {
            let border = CAShapeLayer()
            border.strokeColor = color.cgColor
            border.fillColor = .none
            border.path = UIBezierPath(roundedRect: self.base.bounds, cornerRadius: radius).cgPath
            border.frame = self.base.bounds
            border.lineWidth = lineWidth
            border.lineDashPattern = lineDashPattern.map { .init(integerLiteral: $0) }

            self.base.layer.cornerRadius = radius
            self.base.layer.masksToBounds = true
            self.base.layer.addSublayer(border)
        }
        return self
    }

    @discardableResult
    public func dottedLine(
        _ color: UIColor,
        lineDashPattern: [Int] = [8, 4],
        lineWidth: CGFloat = 1)
        -> Self
    {
        func updatePath(_ layer: CAShapeLayer) {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: base.frame.height / 2))
            path.addLine(to: CGPoint(x: base.frame.width, y: base.frame.height / 2))
            layer.path = path.cgPath
        }

        DispatchQueue.main.async {
            if let layer = base.layer.sublayers?.first(where: { $0.name == "Dotted" }) as? CAShapeLayer {
                updatePath(layer)
            }
            else {
                let layer = CAShapeLayer()
                layer.name = "Dotted"
                layer.strokeColor = color.cgColor
                layer.fillColor = .none
                layer.lineWidth = lineWidth
                layer.lineDashPattern = lineDashPattern.map { .init(integerLiteral: $0) }

                updatePath(layer)

                base.layer.addSublayer(layer)
            }
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
        scale: Bool = true)
        -> Self
    {
        DispatchQueue.main.async {
            self.base.clipsToBounds = false
            self.base.layer.cornerRadius = cornerRadius
            self.base.layer.shadowColor = color.cgColor
            self.base.layer.shadowOpacity = opacity
            self.base.layer.shadowOffset = offset
            self.base.layer.shadowRadius = shadowRadius
            self.base.layer.shadowPath = UIBezierPath(roundedRect: self.base.bounds, cornerRadius: cornerRadius).cgPath
            self.base.layer.shouldRasterize = true
            self.base.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
        }
        return self
    }

    @discardableResult
    public func gradient(
        _ axis: NSLayoutConstraint.Axis,
        colors: [CGColor],
        completion: ((CAGradientLayer) -> Void)? = nil)
        -> Self
    {
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
            applyGradient(startPoint: start, endPoint: end, colors: colors))

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

    /// nil means set to identity
    @discardableResult
    public func rotating(_ angle: CGFloat?, clockwise: Bool = true) -> Self {
        UIView.animate(withDuration: 0.2) {
            if let angle {
                let _angle = clockwise ? angle : -angle
                self.base.transform = CGAffineTransform(rotationAngle: _angle / 180 * CGFloat(Double.pi))
            }
            else {
                self.base.transform = .identity
            }
        }
        return self
    }

    /// nil means set to identity
    @discardableResult
    public func rotated(_ angle: CGFloat?, clockwise: Bool = true) -> Self {
        if let angle {
            let _angle = clockwise ? angle : -angle
            base.transform = CGAffineTransform(rotationAngle: _angle / 180 * CGFloat(Double.pi))
        }
        else {
            base.transform = .identity
        }
        return self
    }

    @discardableResult
    public func separator(
        _ axis: NSLayoutConstraint.Axis,
        _ color: UIColor)
        -> Self
    {
        base.backgroundColor = color
        makeConstraints { make in
            switch axis {
            case .vertical:
                make.width.equalTo(1)
            case .horizontal:
                make.height.equalTo(1)
            @unknown default:
                break
            }
        }
        return self
    }

    @discardableResult
    public func space(
        _ axis: NSLayoutConstraint.Axis,
        _ height: CGFloat)
        -> Self
    {
        makeConstraints { make in
            switch axis {
            case .vertical:
                make.height.equalTo(height)
            case .horizontal:
                make.width.equalTo(height)
            @unknown default:
                break
            }
        }
        return self
    }

    @discardableResult
    public func hugging(
        _ priority: UILayoutPriority,
        for axis: NSLayoutConstraint.Axis)
        -> Self
    {
        base.setContentHuggingPriority(priority, for: axis)
        return self
    }

    @discardableResult
    public func compressionResistance(
        _ priority: UILayoutPriority,
        for axis: NSLayoutConstraint.Axis)
        -> Self
    {
        base.setContentCompressionResistancePriority(priority, for: axis)
        return self
    }

    @discardableResult
    public func mask(by image: UIImage?) -> Self {
        guard image != nil else { return self }

        let mask = CALayer()
        mask.contents = image?.cgImage
        mask.frame = base.bounds
        base.layer.mask = mask

        return self
    }

    public func addTransition(
        duration: CFTimeInterval = 0.25,
        timingFunction: CAMediaTimingFunctionName = .easeIn,
        type: CATransitionType,
        from: CATransitionSubtype)
    {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: timingFunction)
        animation.type = type
        animation.subtype = from
        animation.duration = duration
        base.layer.add(animation, forKey: type.rawValue)
    }
}

#if swift(>=5.9)
    import Combine

    private class TransitionDemo: UIViewController, HasCancellable {
        var tag = 0
        var cancellable: Set<AnyCancellable> = []

        init(tag: Int = 0) {
            self.tag = tag
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = tag == 0 ? .systemPink : .systemGreen

            UIButton().sr
                .title(tag == 0 ? "push" : "back")
                .add(to: view)
                .makeConstraints { make in
                    make.edges.equalToSuperview()
                }
                .onTap(store: &cancellable, { _ in
                    if self.tag == 0 {
                        self.navigationController?.view.sr.addTransition(type: .moveIn, from: .fromLeft)
                        self.navigationController?.pushViewController(TransitionDemo(tag: 1), animated: false)
                    }
                    else {
                        self.navigationController?.view.sr.addTransition(type: .reveal, from: .fromRight)
                        self.navigationController?.popViewController(animated: false)
                    }
                })
        }
    }

    @available(iOS 17.0, *)
    #Preview {
        UINavigationController(rootViewController: TransitionDemo())
    }
#endif
