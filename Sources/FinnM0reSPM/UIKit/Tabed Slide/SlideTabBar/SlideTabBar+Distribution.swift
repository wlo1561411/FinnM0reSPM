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
    scrollView.contentInset = contentInset
  }
}

extension SlideTabBarDistribution where Self == SlideTabBar.ContentLeading {
  public static var contentLeading: SlideTabBar.ContentLeading { .init() }
}

extension SlideTabBarDistribution where Self == SlideTabBar.ContentCenter {
  public static var contentCenter: SlideTabBar.ContentCenter { .init() }
}

extension SlideTabBarDistribution where Self == SlideTabBar.Full {
  public static var full: SlideTabBar.Full { .init() }
}

extension SlideTabBarDistribution where Self == SlideTabBar.Width {
  public static func width(_ value: CGFloat) -> SlideTabBar.Width { .init(value: value) }
}

extension SlideTabBar {
  public struct ContentLeading: SlideTabBarDistribution {
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

  public struct ContentCenter: SlideTabBarDistribution {
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

  public struct Full: SlideTabBarDistribution {
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

  public struct Width: SlideTabBarDistribution {
    let value: CGFloat

    public func update(
      _ scrollView: UIScrollView,
      _ contentInset: UIEdgeInsets,
      _ stackView: UIStackView,
      _ fullConstraint: Constraint?)
    {
      resetContentInset(scrollView: scrollView, contentInset: contentInset)

      stackView
        .arrangedSubviews
        .first?
        .snp
        .makeConstraints { make in
          make.width.equalTo(value)
        }

      stackView.distribution = .fillEqually
      fullConstraint?.deactivate()
    }
  }
}
