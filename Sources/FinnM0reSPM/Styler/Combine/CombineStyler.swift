import Combine
import CombineExt
import Foundation

extension Styler where Base: AnyObject {
    @discardableResult
    public func assign<
        PublisherType: Publisher,
        Output
    >(
        from publisher: PublisherType,
        to keyPath: ReferenceWritableKeyPath<Base, Output>,
        cancellables: inout Set<AnyCancellable>)
        -> Self
        where
        PublisherType.Output == Output,
        PublisherType.Failure == Never
    {
        publisher
            .receive(on: DispatchQueue.main)
            .assign(to: keyPath, on: base, ownership: .weak)
            .store(in: &cancellables)

        return self
    }
}
