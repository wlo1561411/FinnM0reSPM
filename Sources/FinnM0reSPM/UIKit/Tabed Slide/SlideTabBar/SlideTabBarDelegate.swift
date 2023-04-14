import UIKit

// TODO: The first time select maybe can fire didSelected() too, currently not.
@objc
public protocol SlideTabBarDelegate: AnyObject {
  @objc
  optional func didSelected(_ sender: SlideTabBar, at index: Int)
}
