import SnapKit
import UIKit

public protocol SlideTabBarDistribution {
    func update(
        _ scrollView: UIScrollView,
        _ contentInset: UIEdgeInsets,
        _ stackView: UIStackView,
        _ fullConstraint: Constraint?)
}

extension SlideTabBarDistribution {
    func resetContentInset(scrollView: UIScrollView, contentInset: UIEdgeInsets) {
        scrollView.contentInset = .init(top: 0, left: contentInset.left, bottom: 0, right: contentInset.right)
    }
}

extension SlideTabBarDistribution {
    public static func contentLeading() -> Self where Self == SlideTabBar.ContentLeadingDistribution { .init() }
}

extension SlideTabBarDistribution {
    public static func contentCenter() -> Self where Self == SlideTabBar.ContentCenterDistribution { .init() }
}

extension SlideTabBarDistribution {
    public static func full() -> Self where Self == SlideTabBar.FullDistribution { .init() }
}

extension SlideTabBarDistribution where Self == SlideTabBar.WidthDistribution {
    public static func width(_ value: CGFloat, alignToCenter: Bool) -> Self where Self == SlideTabBar.WidthDistribution {
        .init(
            value: value,
            alignToCenter: alignToCenter)
    }
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

    public struct FullDistribution: SlideTabBarDistribution {
        public func update(
            _ scrollView: UIScrollView,
            _ contentInset: UIEdgeInsets,
            _ stackView: UIStackView,
            _ fullConstraint: Constraint?)
        {
            resetContentInset(scrollView: scrollView, contentInset: contentInset)
            stackView.distribution = .fillEqually
            fullConstraint?.activate()
        }
    }

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
