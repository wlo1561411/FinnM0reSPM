import UIKit

extension UIViewController {
    public var isVisible: Bool {
        if isViewLoaded {
            return view.window != nil
        }
        return false
    }
}
