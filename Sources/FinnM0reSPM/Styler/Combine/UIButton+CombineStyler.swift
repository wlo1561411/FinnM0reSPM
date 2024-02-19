import Combine
import UIKit

extension Styler where Base: UIButton {
    @discardableResult
    public func onTap(
        store: inout Set<AnyCancellable>,
        _ closure: @escaping (Base) -> Void)
        -> Self
    {
        base
            .publisher(for: .touchUpInside)
            .sink(receiveValue: closure)
            .store(in: &store)
        return self
    }
}
