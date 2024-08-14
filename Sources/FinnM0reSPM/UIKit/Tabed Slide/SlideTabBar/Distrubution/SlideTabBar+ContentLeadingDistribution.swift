import SnapKit
import UIKit

extension SlideTabBarDistribution {
    public static func contentLeading() -> Self where Self == SlideTabBar.ContentLeadingDistribution { .init() }
}

extension SlideTabBar {
    public struct ContentLeadingDistribution: SlideTabBarDistribution {
        public func update(
            _ scrollView: UIScrollView,
            _ contentInset: UIEdgeInsets,
            _ stackView: UIStackView,
            _ fullConstraint: Constraint?)
        {
            resetContentInset(scrollView: scrollView, contentInset: contentInset)
            stackView.distribution = .equalSpacing
            fullConstraint?.deactivate()
        }
    }
}
