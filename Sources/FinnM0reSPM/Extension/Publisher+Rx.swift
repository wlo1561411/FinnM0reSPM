import Combine
import Foundation
import RxCocoa
import RxSwift

@available(iOS 14.0, *)
extension Publisher {
  public func asObservable() -> Observable<Output> {
    Observable<Output>.create { observer in
      let cancel = self
        .sink(
          receiveCompletion: { completion in
            switch completion {
            case .finished:
              observer.onCompleted()
            case .failure(let error):
              observer.onError(error)
            }
          },
          receiveValue: { value in
            observer.onNext(value)
          })

      return Disposables.create { cancel.cancel() }
    }
  }

  public func asDriver() -> Driver<Output> {
    receive(on: RunLoop.main)
      .asObservable()
      .toDriver()
  }

  public func `if`(_ closure: (AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure>)
    -> AnyPublisher<Output, Failure>
  {
    closure(eraseToAnyPublisher())
  }

  public func receiveOnMain() -> AnyPublisher<Output, Failure> {
    if Thread.isMainThread {
      return eraseToAnyPublisher()
    }
    else {
      return receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
  }
}
