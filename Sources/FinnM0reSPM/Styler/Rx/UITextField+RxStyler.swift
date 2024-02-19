import RxCocoa
import RxSwift
import UIKit

public extension Styler where Base: UITextField {
    @discardableResult
    func onTextChanged<T>(
        transform: (ControlProperty<String?>) -> Observable<T> = { $0.asObservable() },
        dispose: DisposeBag,
        _ closure: ((T) -> Void)?
    )
        -> Self
    {
        transform(base.rx.text)
            .subscribe(onNext: closure)
            .disposed(by: dispose)
        return self
    }
}
