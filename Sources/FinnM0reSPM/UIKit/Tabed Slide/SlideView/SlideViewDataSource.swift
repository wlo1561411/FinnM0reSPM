import UIKit

@objc
public protocol SlideViewDataSource: AnyObject {
  @objc
  func numberOfViewController(_ slideView: SlideView) -> Int
  @objc
  func viewController(_ slideView: SlideView, at index: Int) -> UIViewController
}
