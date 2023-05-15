import UIKit

@objc
public protocol SlideViewDelegate: AnyObject {
    @objc
    optional func switching(from fromIndex: Int, to toIndex: Int, with percentage: CGFloat)
    @objc
    optional func willSwitch(to index: Int, viewController: UIViewController)
    @objc
    optional func didSwitch(to index: Int, viewController: UIViewController)
    @objc
    optional func didCancelSwitch(to index: Int, viewController: UIViewController)
}
