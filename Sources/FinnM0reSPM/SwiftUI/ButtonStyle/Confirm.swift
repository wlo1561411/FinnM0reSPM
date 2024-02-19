import SwiftUI

@available(iOS 14.0, *)
public struct Confirm: ButtonStyle {
    @Environment(\.isEnabled)
    var isEnabled

    var size: CGFloat = 14

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(isEnabled ? .from(.white) : .from(.white, alpha: 0.4))
            .font(.system(size: size))
            .padding(10)
            .frame(maxWidth: .infinity)
            .lineLimit(1)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .frame(height: 48)
                    .foregroundColor(isEnabled ? .from(.systemBlue) : .from(.systemBlue, alpha: 0.3)))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

@available(iOS 14.0, *)
extension ButtonStyle where Self == Confirm {
    public static func confirm(_ size: CGFloat) -> Confirm {
        Confirm(size: size)
    }
}
