import SwiftUI
import UIKit

protocol Previewable: UIView { }

extension Previewable {
    func toPreview() -> PreviewWrapper<Self> {
        .init(self)
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
            .toPreview()
            .previewLayout(.fixed(width: 200, height: 200))
    }
}
