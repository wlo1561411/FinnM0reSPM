import UIKit

public protocol SlideTabBarDataSource: AnyObject {
    func numberOfItems(_ sender: SlideTabBar) -> Int
    func itemView(_ sender: SlideTabBar, at index: Int) -> SlideTabBarItem
}
