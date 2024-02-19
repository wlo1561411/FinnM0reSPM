import UIKit

@objc
public protocol SlideTabBarDelegate: AnyObject {
    @objc
    optional func didSelected(_ sender: SlideTabBar, at index: Int)
}
