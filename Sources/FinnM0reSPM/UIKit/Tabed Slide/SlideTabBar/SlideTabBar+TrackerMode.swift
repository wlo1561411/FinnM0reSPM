import UIKit

public protocol SlideTabBarTrackerMode {
    func location(
        with item: SlideTabBar.Item,
        spacing: CGFloat,
        at scrollView: UIScrollView
    ) -> (x: CGFloat, width: CGFloat)
}

public extension SlideTabBarTrackerMode where Self == SlideTabBar.ByView {
    static var byView: SlideTabBar.ByView { .init() }
}

public extension SlideTabBarTrackerMode where Self == SlideTabBar.ByContent {
    static var byContent: SlideTabBar.ByContent { .init() }
}

public extension SlideTabBar {
    struct ByView: SlideTabBarTrackerMode {
        public func location(
            with item: SlideTabBar.Item,
            spacing: CGFloat,
            at scrollView: UIScrollView
        ) -> (x: CGFloat, width: CGFloat) {
            let converted = scrollView.convert(item.bounds, from: item)
            return (converted.origin.x - spacing / 2, item.frame.width + spacing)
        }
    }

    struct ByContent: SlideTabBarTrackerMode {
        public func location(
            with item: SlideTabBar.Item,
            spacing _: CGFloat,
            at scrollView: UIScrollView
        ) -> (x: CGFloat, width: CGFloat) {
            let converted = scrollView.convert(item.bounds, from: item)
            return (converted.origin.x, item.frame.width)
        }
    }
}
