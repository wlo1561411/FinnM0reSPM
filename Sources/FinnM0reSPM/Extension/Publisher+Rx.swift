import Combine
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
}
