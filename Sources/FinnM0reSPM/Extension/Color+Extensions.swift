import SwiftUI

@available(iOS 14.0, *)
extension Color {
  public static func from(_ uiColor: UIColor, alpha: CGFloat = 1) -> Color {
    Color(uiColor.withAlphaComponent(alpha))
  }
}
