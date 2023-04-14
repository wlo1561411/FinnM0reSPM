import UIKit

public protocol SlideTabBarTrackerMode {
  func location(
    with item: SlideTabBar.Item,
    spacing: CGFloat,
    at scrollView: UIScrollView) -> (x: CGFloat, width: CGFloat)
}

extension SlideTabBarTrackerMode where Self == SlideTabBar.ByView {
  public static var byView: SlideTabBar.ByView { .init() }
}

extension SlideTabBarTrackerMode where Self == SlideTabBar.ByContent {
  public static var byContent: SlideTabBar.ByContent { .init() }
}

extension SlideTabBar {
  public struct ByView: SlideTabBarTrackerMode {
    public func location(
      with item: SlideTabBar.Item,
      spacing: CGFloat,
      at scrollView: UIScrollView) -> (x: CGFloat, width: CGFloat)
    {
      let converted = scrollView.convert(item.bounds, from: item)
      return (converted.origin.x - spacing / 2, item.frame.width + spacing)
    }
  }

  public struct ByContent: SlideTabBarTrackerMode {
    public func location(
      with item: SlideTabBar.Item,
      spacing _: CGFloat,
      at scrollView: UIScrollView) -> (x: CGFloat, width: CGFloat)
    {
      let converted = scrollView.convert(item.bounds, from: item)
      return (converted.origin.x, item.frame.width)
    }
  }
}
