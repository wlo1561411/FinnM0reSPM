import UIKit

public extension UIStackView {
    convenience init(
        arrangedSubviews: [UIView] = [],
        spacing: CGFloat,
        axis: NSLayoutConstraint.Axis = .vertical,
        distribution: Distribution,
        alignment: Alignment
    ) {
        self.init(arrangedSubviews: arrangedSubviews)
        self.axis = axis
        self.spacing = spacing
        self.distribution = distribution
        self.alignment = alignment
    }

    func removeFully(_ view: UIView) {
        removeArrangedSubview(view)
        view.removeFromSuperview()
    }

    func removeAllFully() {
        arrangedSubviews.forEach { removeFully($0) }
    }
}
