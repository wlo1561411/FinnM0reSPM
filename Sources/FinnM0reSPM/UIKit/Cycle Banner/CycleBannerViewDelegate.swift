import UIKit

@objc
public protocol CycleBannerViewDelegate: AnyObject {
    @objc
    optional func didSelected(at index: Int)
    @objc
    optional func didScroll(to index: Int)
}
