import RxSwift
import RxCocoa

extension ObservableType {
  public func toDriver() -> Driver<Element> {
    asDriver { _ in
      Driver.empty()
    }
  }
}
