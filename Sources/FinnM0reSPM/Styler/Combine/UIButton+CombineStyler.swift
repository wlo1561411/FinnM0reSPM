import Combine
import UIKit

@available(iOS 13.0, *)
public extension Styler where Base: UIButton {
    @discardableResult
    func onTap(
        store: inout Set<AnyCancellable>,
        _ closure: @escaping (Base) -> Void
    )
        -> Self
    {
        base
            .publisher(for: .touchUpInside)
            .sink(receiveValue: closure)
            .store(in: &store)
        return self
    }
}
