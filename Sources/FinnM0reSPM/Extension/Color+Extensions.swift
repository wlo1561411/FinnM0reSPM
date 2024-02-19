import SwiftUI

@available(iOS 14.0, *)
public extension Color {
    static func from(_ uiColor: UIColor, alpha: CGFloat = 1) -> Color {
        Color(uiColor.withAlphaComponent(alpha))
    }
}
