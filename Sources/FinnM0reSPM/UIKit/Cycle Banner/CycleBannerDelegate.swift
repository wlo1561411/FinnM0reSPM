import UIKit

@objc
public protocol CycleBannerDelegate: AnyObject {
    @objc
    optional func didSelected(at index: Int)
    @objc
    optional func didScroll(to index: Int)
}
