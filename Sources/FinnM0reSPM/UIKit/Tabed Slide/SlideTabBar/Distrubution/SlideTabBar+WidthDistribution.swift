import SnapKit
import UIKit

extension SlideTabBarDistribution {
    public static func width(_ value: CGFloat, alignToCenter: Bool) -> Self where Self == SlideTabBar.WidthDistribution {
        .init(
            value: value,
            alignToCenter: alignToCenter)
    }
}

extension SlideTabBar {
    public struct WidthDistribution: SlideTabBarDistribution {
        let value: CGFloat
        let alignToCenter: Bool

        public func update(
            _ scrollView: UIScrollView,
            _ contentInset: UIEdgeInsets,
            _ stackView: UIStackView,
            _ fullConstraint: Constraint?)
        {
            stackView.distribution = .fillEqually
            stackView
                .arrangedSubviews
                .first?
                .snp
                .makeConstraints { make in
                    make.width.equalTo(value)
                }

            fullConstraint?.deactivate()

            if alignToCenter {
                stackView.setNeedsLayout()
                stackView.layoutIfNeeded()

                if scrollView.frame.width > stackView.frame.width + (contentInset.left + contentInset.right) {
                    let padding = (scrollView.frame.width - stackView.frame.width) / 2
                    resetContentInset(
                        scrollView: scrollView,
                        contentInset: .init(top: 0, left: padding, bottom: 0, right: padding))
                }
                else {
                    resetContentInset(scrollView: scrollView, contentInset: contentInset)
                }
            }
            else {
                resetContentInset(scrollView: scrollView, contentInset: contentInset)
            }
        }
    }
}
