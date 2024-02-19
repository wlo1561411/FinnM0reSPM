import SnapKit
import UIKit

public protocol SlideTabBarDistribution {
    func update(
        _ scrollView: UIScrollView,
        _ contentInset: UIEdgeInsets,
        _ stackView: UIStackView,
        _ fullConstraint: Constraint?
    )
}

extension SlideTabBarDistribution {
    func resetContentInset(scrollView: UIScrollView, contentInset: UIEdgeInsets) {
        scrollView.contentInset = .init(top: 0, left: contentInset.left, bottom: 0, right: contentInset.right)
    }
}

public extension SlideTabBarDistribution where Self == SlideTabBar.ContentLeading {
    static var contentLeading: SlideTabBar.ContentLeading { .init() }
}

public extension SlideTabBarDistribution where Self == SlideTabBar.ContentCenter {
    static var contentCenter: SlideTabBar.ContentCenter { .init() }
}

public extension SlideTabBarDistribution where Self == SlideTabBar.Full {
    static var full: SlideTabBar.Full { .init() }
}

public extension SlideTabBarDistribution where Self == SlideTabBar.Width {
    static func width(_ value: CGFloat, alignToCenter: Bool) -> SlideTabBar
        .Width { .init(value: value, alignToCenter: alignToCenter) }
}

public extension SlideTabBar {
    struct ContentLeading: SlideTabBarDistribution {
        public func update(
            _ scrollView: UIScrollView,
            _ contentInset: UIEdgeInsets,
            _ stackView: UIStackView,
            _ fullConstraint: Constraint?
        ) {
            resetContentInset(scrollView: scrollView, contentInset: contentInset)
            stackView.distribution = .equalSpacing
            fullConstraint?.deactivate()
        }
    }

    struct ContentCenter: SlideTabBarDistribution {
        public func update(
            _ scrollView: UIScrollView,
            _ contentInset: UIEdgeInsets,
            _ stackView: UIStackView,
            _ fullConstraint: Constraint?
        ) {
            stackView.distribution = .equalSpacing
            fullConstraint?.deactivate()

            stackView.setNeedsLayout()
            stackView.layoutIfNeeded()

            if scrollView.frame.width > stackView.frame.width + (contentInset.left + contentInset.right) {
                let padding = (scrollView.frame.width - stackView.frame.width) / 2
                scrollView.contentInset = .init(top: 0, left: padding, bottom: 0, right: padding)
            } else {
                resetContentInset(scrollView: scrollView, contentInset: contentInset)
            }
        }
    }

    struct Full: SlideTabBarDistribution {
        public func update(
            _ scrollView: UIScrollView,
            _ contentInset: UIEdgeInsets,
            _ stackView: UIStackView,
            _ fullConstraint: Constraint?
        ) {
            resetContentInset(scrollView: scrollView, contentInset: contentInset)
            stackView.distribution = .fillEqually
            fullConstraint?.activate()
        }
    }

    struct Width: SlideTabBarDistribution {
        let value: CGFloat
        let alignToCenter: Bool

        public func update(
            _ scrollView: UIScrollView,
            _ contentInset: UIEdgeInsets,
            _ stackView: UIStackView,
            _ fullConstraint: Constraint?
        ) {
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
                        contentInset: .init(top: 0, left: padding, bottom: 0, right: padding)
                    )
                } else {
                    resetContentInset(scrollView: scrollView, contentInset: contentInset)
                }
            } else {
                resetContentInset(scrollView: scrollView, contentInset: contentInset)
            }
        }
    }
}
