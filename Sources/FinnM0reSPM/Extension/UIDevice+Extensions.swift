import UIKit

extension UIDevice {
    var statusBarHeight: CGFloat {
        UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
    }

    var width: CGFloat {
        UIScreen.main.bounds.size.width
    }

    var height: CGFloat {
        UIScreen.main.bounds.size.height
    }
}
