import UIKit

@objc
public protocol SlideTabBarDataSource: AnyObject {
  @objc
  func numberOfItems(_ sender: SlideTabBar) -> Int
  @objc
  func itemView(_ sender: SlideTabBar, at index: Int) -> SlideTabBar.Item
}
