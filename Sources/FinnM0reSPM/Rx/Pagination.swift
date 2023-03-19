import Foundation
import RxCocoa
import RxSwift

public class Pagination<T> {
  private let disposeBag = DisposeBag()

  public let refreshTrigger = PublishSubject<Void>()
  public let loadNextPageTrigger = PublishSubject<Void>()
  public let error = PublishSubject<Swift.Error>()
  public let loading = BehaviorRelay<Bool>(value: false)
  public let elements = BehaviorRelay<[T]>(value: [])

  private var pageIndex = 1
  private var startPageIndex = 0
  private var offset = 1
  private var isLastData = false

  public init(
    pageIndex: Int = 1,
    offset: Int = 1,
    observable: @escaping ((Int) -> Observable<[T]>),
    onLoading: ((Bool) -> Void)? = nil,
    onElementChanged: (([T]) -> Void)? = nil)
  {
    self.offset = offset
    self.startPageIndex = pageIndex

    if let onLoading {
      loading
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: {
          onLoading($0)
        })
        .disposed(by: disposeBag)
    }

    if let onElementChanged {
      elements
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: {
          onElementChanged($0)
        })
        .disposed(by: disposeBag)
    }

    let refreshRequest = loading.asObservable()
      .sample(refreshTrigger)
      .flatMap { [unowned self] loading -> Observable<Int> in
        if loading {
          return Observable.empty()
        }
        else {
          self.pageIndex = pageIndex
          return Observable<Int>.create { observer in
            observer.onNext(self.pageIndex)
            observer.onCompleted()
            return Disposables.create()
          }
        }
      }

    let nextPageRequest = loading.asObservable()
      .sample(loadNextPageTrigger)
      .flatMap { [unowned self] loading -> Observable<Int> in
        if loading {
          return Observable.empty()
        }
        else if self.isLastData {
          return Observable.empty()
        }
        else {
          return Observable<Int>.create { observer in
            self.pageIndex += self.offset
            observer.onNext(self.pageIndex)
            observer.onCompleted()
            return Disposables.create()
          }
        }
      }

    let request = Observable
      .of(refreshRequest, nextPageRequest)
      .merge()
      .share(replay: 1)

    let response = request
      .flatMap { page -> Observable<[T]> in
        observable(page)
      }
      .share(replay: 1)

    Observable
      .combineLatest(
        request,
        response,
        elements.asObservable())
      .map { [unowned self] _, response, elements in
        self.pageIndex == self.startPageIndex ? response : elements + response
      }
      .sample(response)
      .bind(to: elements)
      .disposed(by: disposeBag)

    Observable
      .of(
        request.map({ _ -> Bool in
          true
        }),
        response.map({ [unowned self] response -> Bool in
          self.isLastData = response.count == 0
          return false
        }),
        error.map({ _ -> Bool in
          false
        }))
      .merge()
      .bind(to: loading)
      .disposed(by: disposeBag)
  }
}
