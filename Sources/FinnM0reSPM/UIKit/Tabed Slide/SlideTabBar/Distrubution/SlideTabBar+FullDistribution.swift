import SnapKit
import UIKit

extension SlideTabBarDistribution {
    public static func full() -> Self where Self == SlideTabBar.FullDistribution { .init() }
}

extension SlideTabBar {
    public struct FullDistribution: SlideTabBarDistribution {
        public func update(
            _ scrollView: UIScrollView,
            _ contentInset: UIEdgeInsets,
            _ stackView: UIStackView,
            _ fullConstraint: Constraint?)
        {
            resetContentInset(scrollView: scrollView, contentInset: contentInset)
            stackView.distribution = .fillEqually
            fullConstraint?.update(offset: scrollView.frame.width - contentInset.left - contentInset.right)
            fullConstraint?.activate()
        }
    }
}
