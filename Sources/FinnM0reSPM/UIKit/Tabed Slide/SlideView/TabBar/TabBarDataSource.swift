import UIKit

@objc
public protocol SlideTabBarDataSource: AnyObject {
  @objc
  func numberOfItems(_ sender: SlideView.TabBar) -> Int
  @objc
  func itemView(_ sender: SlideView.TabBar, at index: Int) -> SlideView.TabBar.Item
}
