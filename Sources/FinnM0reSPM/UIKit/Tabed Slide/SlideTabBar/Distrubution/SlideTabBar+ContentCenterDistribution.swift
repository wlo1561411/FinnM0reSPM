import SnapKit
import UIKit

extension SlideTabBarDistribution {
    public static func contentCenter() -> Self where Self == SlideTabBar.ContentCenterDistribution { .init() }
}

extension SlideTabBar {
    public struct ContentCenterDistribution: SlideTabBarDistribution {
        public func update(
            _ scrollView: UIScrollView,
            _ contentInset: UIEdgeInsets,
            _ stackView: UIStackView,
            _ fullConstraint: Constraint?)
        {
            stackView.distribution = .equalSpacing
            fullConstraint?.deactivate()

            stackView.setNeedsLayout()
            stackView.layoutIfNeeded()

            if scrollView.frame.width > stackView.frame.width + (contentInset.left + contentInset.right) {
                let padding = (scrollView.frame.width - stackView.frame.width) / 2
                scrollView.contentInset = .init(top: 0, left: padding, bottom: 0, right: padding)
            }
            else {
                resetContentInset(scrollView: scrollView, contentInset: contentInset)
            }
        }
    }
}
