import UIKit

extension UIStackView {
    public convenience init(
        arrangedSubviews: [UIView] = [],
        spacing: CGFloat,
        axis: NSLayoutConstraint.Axis = .vertical,
        distribution: Distribution,
        alignment: Alignment)
    {
        self.init(arrangedSubviews: arrangedSubviews)
        self.axis = axis
        self.spacing = spacing
        self.distribution = distribution
        self.alignment = alignment
    }

    public func removeFully(_ view: UIView) {
        removeArrangedSubview(view)
        view.removeFromSuperview()
    }

    public func removeAllFully() {
        arrangedSubviews.forEach { removeFully($0) }
    }
}
