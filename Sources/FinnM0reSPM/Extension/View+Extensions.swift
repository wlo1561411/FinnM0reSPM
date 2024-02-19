import SwiftUI

@available(iOS 14.0, *)
public enum Visibility {
    case visible
    case invisible
    case gone
}

@available(iOS 14.0, *)
public extension View {
    func strokeBorder(color: UIColor, cornerRadius: CGFloat, lineWidth: CGFloat = 1) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(lineWidth: lineWidth)
                .foregroundColor(.from(color)))
    }

    func backgroundColor(_ color: UIColor, alpha: CGFloat = 1) -> some View {
        background(
            Color.from(color, alpha: alpha))
    }

    func pageBackgroundColor(_ color: UIColor, alpha: CGFloat = 1) -> some View {
        background(
            Color.from(color, alpha: alpha).ignoresSafeArea())
    }

    @ViewBuilder
    func visibility(_ visibility: Visibility) -> some View {
        switch visibility {
        case .visible:
            self
        case .invisible:
            hidden()
        case .gone:
            EmptyView()
        }
    }

    @ViewBuilder
    func `if`
    (_ condition: Bool, transform: (Self) -> some View)
        -> some View
    {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
