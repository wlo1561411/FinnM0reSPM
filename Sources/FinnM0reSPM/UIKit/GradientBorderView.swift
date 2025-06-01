import UIKit

/// 支援漸層背景與漸層框線
final class GradientBorderView: UIView {
    /// 背景 layer
    private let backgroundGradient = CAGradientLayer()
    /// 邊框 layer
    private let borderGradient = CAGradientLayer()
    /// 邊框遮罩
    private let borderMask = CAShapeLayer()

    var backgroundColors: [UIColor?] = [] {
        didSet {
            backgroundGradient.colors = backgroundColors.compactMap { $0 }.map(\.cgColor)
            setNeedsLayout()
        }
    }

    var borderColors: [UIColor?] = [] {
        didSet {
            borderGradient.colors = borderColors.compactMap { $0 }.map(\.cgColor)
            setNeedsLayout()
        }
    }

    var borderWidth: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            setNeedsLayout()
        }
    }

    init() {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundGradient.frame = bounds
        borderGradient.frame = bounds

        updateBorderMask()
    }
}

// MARK: - UI

extension GradientBorderView {
    private func setupUI() {
        backgroundGradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundGradient.endPoint = CGPoint(x: 0.5, y: 1.0)

        layer.insertSublayer(backgroundGradient, at: 0)

        borderGradient.startPoint = CGPoint(x: 0.5, y: 0)
        borderGradient.endPoint = CGPoint(x: 0.5, y: 1)

        layer.addSublayer(borderGradient)

        borderGradient.mask = borderMask
    }

    /// 建立邊框 path, 只留邊框線寬
    private func updateBorderMask() {
        let path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: borderWidth / 2, dy: borderWidth / 2),
            cornerRadius: layer.cornerRadius)

        borderMask.path = path.cgPath
        borderMask.lineWidth = borderWidth
        borderMask.strokeColor = UIColor.black.cgColor
        borderMask.fillColor = UIColor.clear.cgColor
        borderMask.frame = bounds
        borderMask.lineJoin = .round
    }
}
