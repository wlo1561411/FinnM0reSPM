import UIKit

public extension UIViewController {
    var isVisible: Bool {
        if isViewLoaded {
            return view.window != nil
        }
        return false
    }
}
