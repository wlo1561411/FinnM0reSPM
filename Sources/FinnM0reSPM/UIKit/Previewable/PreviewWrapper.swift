import SwiftUI
import UIKit

struct PreviewWrapper<T: UIView>: UIViewRepresentable {
    let target: T

    init(_ target: T) {
        self.target = target
    }

    func makeUIView(context _: Context) -> T {
        target
    }

    func updateUIView(_: T, context _: Context) { }
}

