import UIKit

public protocol CycleBannerViewDataSource: AnyObject {
    func item(at index: Int) -> UIView
    func numberOfItems() -> Int
}
