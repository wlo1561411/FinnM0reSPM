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
  public func axis(_ axis: NSLayoutConstraint.Axis) -> Self {
    base.axis = axis
    return self
  }
}
