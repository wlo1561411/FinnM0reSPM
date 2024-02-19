import Combine
import Foundation

@available(iOS 13.0, *)
public extension Styler {
    @discardableResult
    func assign<
        PublisherType: Publisher,
        Output
    >(
        from publisher: PublisherType,
        to keyPath: ReferenceWritableKeyPath<Base, Output>,
        cancellables: inout Set<AnyCancellable>
    )
        -> Self
        where
        PublisherType.Output == Output,
        PublisherType.Failure == Never
    {
        publisher
            .receive(on: DispatchQueue.main)
            .assign(to: keyPath, on: base)
            .store(in: &cancellables)

        return self
    }
}
