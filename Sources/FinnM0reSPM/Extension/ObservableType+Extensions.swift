import RxCocoa
import RxSwift

public extension ObservableType {
    func toDriver() -> Driver<Element> {
        asDriver { _ in
            Driver.empty()
        }
    }
}
