import SwiftUI

@available(iOS 14.0, *)
public struct ViewDidLoadModifier: ViewModifier {
    @State
    private var viewDidLoad = false
    let action: (() -> Void)?

    public func body(content: Content) -> some View {
        content
            .onAppear {
                if !viewDidLoad {
                    viewDidLoad = true
                    action?()
                }
            }
    }
}

@available(iOS 14.0, *)
extension View {
    public func onViewDidLoad(_ perform: @escaping (() -> Void)) -> some View {
        self.modifier(ViewDidLoadModifier(action: perform))
    }
}
