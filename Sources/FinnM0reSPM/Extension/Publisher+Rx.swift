import Combine
import Foundation

@available(iOS 14.0, *)
extension Publisher {
  public func `if`(_ closure: (AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure>)
    -> AnyPublisher<Output, Failure>
  {
    closure(eraseToAnyPublisher())
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
