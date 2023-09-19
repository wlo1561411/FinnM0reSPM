import SwiftUI
import UIKit

protocol Previewable { }

extension Previewable where Self: UIView {
    func previewable() -> PreviewWrapper<Self> {
        .init(self)
    }
}

extension Previewable where Self: UIViewController {
    func previewable() -> PreviewWrapper<UIView> {
        .init(view)
    }
}

// MARK: - Example

class Label_Example: UILabel, Previewable { }

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
