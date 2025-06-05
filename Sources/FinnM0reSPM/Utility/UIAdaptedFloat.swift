import UIKit

public extension CGFloat {
    typealias adapted = UIAdaptedFloat
}

public struct UIAdaptedFloat {
    public static var comparedFloat: CGFloat = 375

    /// UI 佈局相關的 value，需用此方法調用，達到螢幕調用效果
    public static func from(_ x: CGFloat) -> CGFloat {
        if abs(x) <= 1 {
            return x
        }
        /// 防止因為小數據點，導致失真狀況發生。
        let value = (x * min(UIDevice.current.width, UIDevice.current.height) / comparedFloat)
        return floor(value)
    }
}
