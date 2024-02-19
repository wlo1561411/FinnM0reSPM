import Combine
import Foundation

@available(iOS 13.0, *)
extension Publisher {
    public func `if`(
        _ condition: Bool,
        _ closure: (AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure>)
        -> AnyPublisher<Output, Failure>
    {
        if condition {
            closure(eraseToAnyPublisher())
        }
        else {
            eraseToAnyPublisher()
        }
    }

    public func receiveOnMainIfNeeded() -> AnyPublisher<Output, Failure> {
        if Thread.isMainThread {
            return eraseToAnyPublisher()
        }
        else {
            return receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    }
}
