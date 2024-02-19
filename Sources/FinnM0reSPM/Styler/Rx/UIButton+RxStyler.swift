import RxCocoa
import RxSwift
import UIKit

public extension Styler where Base: UIButton {
    @discardableResult
    func onTap(
        dispose: DisposeBag,
        _ closure: ((ControlEvent<Void>.Element) -> Void)?
    )
        -> Self
    {
        base.rx.tap
            .subscribe(onNext: closure)
            .disposed(by: dispose)
        return self
    }
}

public extension Reactive where Base: UIButton {
    var enable: Binder<Bool> {
        Binder(base) { button, enable in
            button.sr.enable(enable)
        }
    }
}
