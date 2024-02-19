import UIKit

extension Styler where Base: UIStackView {
    @discardableResult
    public func config(
        spacing: CGFloat = 0,
        alignment: UIStackView.Alignment = .fill,
        distribution: UIStackView.Distribution = .fill)
        -> Self
    {
        base.spacing = spacing
        base.alignment = alignment
        base.distribution = distribution
        return self
    }

    @discardableResult
    public func addArranged(_ view: [UIView]) -> Self {
        for item in view {
            base.addArrangedSubview(item)
        }
        return self
    }
}
