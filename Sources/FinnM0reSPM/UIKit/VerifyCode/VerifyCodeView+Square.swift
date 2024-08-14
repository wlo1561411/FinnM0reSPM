import UIKit

extension VerifyCodeView {
    public final class Square: UIView {
        private let backgroundView = UIView()
        private let numberLabel = UILabel()
        private let lineLayer = CAShapeLayer()

        private let colorPattern: VerifyCodeView.ColorPattern

        public var isHighlighted = false {
            didSet {
                backgroundView.layer.borderColor = isHighlighted ?
                    colorPattern.borderHighlightColor.cgColor : colorPattern.borderColor.cgColor
                lineLayer.isHidden = !isHighlighted
            }
        }

        public init(_ colorPattern: VerifyCodeView.ColorPattern) {
            self.colorPattern = colorPattern

            super.init(frame: .zero)

            setupUI()

            isHighlighted = false
        }

        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override public func layoutSubviews() {
            super.layoutSubviews()

            let path = UIBezierPath(
                roundedRect: .init(
                    x: (frame.width / 2) - 1,
                    y: (frame.height / 2) / 2,
                    width: 1,
                    height: frame.height / 2),
                cornerRadius: 0)
            lineLayer.path = path.cgPath
        }
    }
}

// MARK: - UI

extension VerifyCodeView.Square {
    private func setupUI() {
        backgroundView.isUserInteractionEnabled = false
        backgroundView.backgroundColor = colorPattern.backgroundColor
        backgroundView.layer.borderColor = colorPattern.borderColor.cgColor
        backgroundView.layer.borderWidth = colorPattern.borderWidth
        backgroundView.layer.cornerRadius = colorPattern.cornerRadius

        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        numberLabel.isUserInteractionEnabled = false
        numberLabel.textColor = colorPattern.textColor
        numberLabel.textAlignment = .center
        numberLabel.font = colorPattern.textFont

        backgroundView.addSubview(numberLabel)
        numberLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        lineLayer.fillColor = colorPattern.cursorColor.cgColor
        lineLayer.isHidden = self.tag != 0

        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1
        animation.toValue = 0
        animation.duration = 0.9
        animation.repeatCount = .infinity
        animation.timingFunction = .init(name: .easeIn)

        lineLayer.add(animation, forKey: "opacity")

        backgroundView.layer.addSublayer(lineLayer)
    }

    public func updateUI(
        with text: String,
        isHighlighted: Bool)
    {
        numberLabel.text = text.capitalized
        self.isHighlighted = isHighlighted
    }
}
