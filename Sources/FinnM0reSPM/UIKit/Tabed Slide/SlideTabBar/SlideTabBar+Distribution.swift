import SnapKit
import UIKit

public protocol SlideTabBarDistribution {
  func update(
    _ scrollView: UIScrollView,
    _ itemSpacing: CGFloat,
    _ stackView: UIStackView,
    _ fullConstraint: Constraint?)
}

extension SlideTabBarDistribution {
  func resetContentInset(scrollView: UIScrollView, itemSpacing: CGFloat) {
    scrollView.contentInset = .init(
      top: 0, left: itemSpacing / 4,
      bottom: 0, right: itemSpacing / 4)
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
      _ itemSpacing: CGFloat,
      _ stackView: UIStackView,
      _ fullConstraint: Constraint?)
    {
      resetContentInset(scrollView: scrollView, itemSpacing: itemSpacing)
      stackView.distribution = .equalSpacing
      fullConstraint?.deactivate()
    }
  }

  public struct ContentCenter: SlideTabBarDistribution {
    public func update(
      _ scrollView: UIScrollView,
      _ itemSpacing: CGFloat,
      _ stackView: UIStackView,
      _ fullConstraint: Constraint?)
    {
      stackView.distribution = .equalSpacing
      fullConstraint?.deactivate()

      DispatchQueue.main.async {
        if scrollView.frame.width > stackView.frame.width + (itemSpacing / 2) {
          let padding = (scrollView.frame.width - stackView.frame.width) / 2
          scrollView.contentInset = .init(top: 0, left: padding, bottom: 0, right: padding)
        }
        else {
          self.resetContentInset(scrollView: scrollView, itemSpacing: itemSpacing)
        }
      }
    }
  }

  public struct Full: SlideTabBarDistribution {
    public func update(
      _ scrollView: UIScrollView,
      _ itemSpacing: CGFloat,
      _ stackView: UIStackView,
      _ fullConstraint: Constraint?)
    {
      resetContentInset(scrollView: scrollView, itemSpacing: itemSpacing)
      stackView.distribution = .fillEqually
      fullConstraint?.activate()
    }
  }

  public struct Width: SlideTabBarDistribution {
    let value: CGFloat

    public func update(
      _ scrollView: UIScrollView,
      _ itemSpacing: CGFloat,
      _ stackView: UIStackView,
      _ fullConstraint: Constraint?)
    {
      resetContentInset(scrollView: scrollView, itemSpacing: itemSpacing)

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
