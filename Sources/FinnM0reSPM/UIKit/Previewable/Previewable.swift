import SwiftUI
import UIKit

@available(iOS 13.0, *)
protocol Previewable { }

@available(iOS 13.0, *)
extension Previewable where Self: UIView {
    func previewable() -> PreviewWrapper<Self> {
        .init(self)
    }
}

@available(iOS 13.0, *)
extension Previewable where Self: UIViewController {
    func previewable() -> PreviewWrapper<UIView> {
        .init(view)
    }
}

// MARK: - Example

@available(iOS 13.0, *)
class Label_Example: UILabel, Previewable { }

@available(iOS 13.0, *)
struct Label_Preview: PreviewProvider {
    static var previews: some View {
        let label = Label_Example()
        label.text = "Test"
        label.textAlignment = .center
        return label
            .previewable()
            .previewLayout(.fixed(width: 200, height: 200))
    }
}
