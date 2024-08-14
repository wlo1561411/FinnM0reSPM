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
