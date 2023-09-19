import Combine
import Foundation

@available(iOS 14.0, *)
extension Publisher {
  public func `if`(_ closure: (AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure>)
    -> AnyPublisher<Output, Failure>
  {
    closure(eraseToAnyPublisher())
  }
}
