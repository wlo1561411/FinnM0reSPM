import Combine
import UIKit

extension Styler where Base: UIScrollView {
    @discardableResult
    public func closeIndicator() -> Self {
        base.showsVerticalScrollIndicator = false
        base.showsHorizontalScrollIndicator = false
        return self
    }

    public var scrollablePublisher: AnyPublisher<Bool, Never> {
        base
            .publisher(for: \.contentSize)
            .receive(on: DispatchQueue.main)
            .map { [weak base] size -> Bool in
                guard let base else { return false }
                let height = size.height + base.contentInset.top + base.contentInset.bottom
                let width = size.width + base.contentInset.left + base.contentInset.right
                return height > base.frame.height || width > base.frame.width
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    @discardableResult
    public func automaticScrollable(storeIn: inout Set<AnyCancellable>) -> Self {
        scrollablePublisher
            .sink(receiveValue: { [weak base] in
                base?.isScrollEnabled = $0
            })
            .store(in: &storeIn)
        return self
    }
}
