import UIKit

@objc
public protocol CycleBannerViewDataSource: AnyObject {
  @objc func item(at index: Int) -> UIView
  @objc func numberOfItems() -> Int
}
