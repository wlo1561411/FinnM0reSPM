import RxCocoa
import RxSwift

extension ObservableType {
    public func toDriver() -> Driver<Element> {
        asDriver { _ in
            Driver.empty()
        }
    }
}
