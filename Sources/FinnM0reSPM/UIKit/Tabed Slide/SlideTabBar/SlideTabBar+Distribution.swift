import SnapKit
import UIKit

public protocol SlideTabBarDistribution {
  func update(_ stackView: UIStackView, _ fullConstraint: Constraint?)
}

extension SlideTabBarDistribution where Self == SlideTabBar.Content {
  public static var content: SlideTabBar.Content { .init() }
}

extension SlideTabBarDistribution where Self == SlideTabBar.Full {
  public static var full: SlideTabBar.Full { .init() }
}

extension SlideTabBarDistribution where Self == SlideTabBar.Width {
  public static func width(_ value: CGFloat) -> SlideTabBar.Width { .init(value: value) }
}

extension SlideTabBar {
  public struct Content: SlideTabBarDistribution {
    public func update(_ stackView: UIStackView, _ fullConstraint: SnapKit.Constraint?) {
      stackView.distribution = .equalSpacing
      fullConstraint?.deactivate()
    }
  }

  public struct Full: SlideTabBarDistribution {
    public func update(_ stackView: UIStackView, _ fullConstraint: SnapKit.Constraint?) {
      stackView.distribution = .fillEqually
      fullConstraint?.activate()
    }
  }

  public struct Width: SlideTabBarDistribution {
    let value: CGFloat

    public func update(_ stackView: UIStackView, _ fullConstraint: SnapKit.Constraint?) {
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
