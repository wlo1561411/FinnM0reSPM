import Combine
import Foundation
import RxCocoa
import RxSwift

@available(iOS 14.0, *)
public extension Publisher {
    func asObservable() -> Observable<Output> {
        Observable<Output>.create { observer in
            let cancel = self
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            observer.onCompleted()
                        case let .failure(error):
                            observer.onError(error)
                        }
                    },
                    receiveValue: { value in
                        observer.onNext(value)
                    }
                )

            return Disposables.create { cancel.cancel() }
        }
    }

    func asDriver() -> Driver<Output> {
        receive(on: RunLoop.main)
            .asObservable()
            .toDriver()
    }

    func `if`(
        _ condition: Bool,
        _ closure: (AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure>
    )
        -> AnyPublisher<Output, Failure>
    {
        if condition {
            closure(eraseToAnyPublisher())
        } else {
            eraseToAnyPublisher()
        }
    }

    func receiveOnMain() -> AnyPublisher<Output, Failure> {
        if Thread.isMainThread {
            return eraseToAnyPublisher()
        } else {
            return receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    }
}
