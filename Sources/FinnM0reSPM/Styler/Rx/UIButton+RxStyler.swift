import RxCocoa
import RxSwift
import UIKit

extension Styler where Base: UIButton {
    @discardableResult
    public func onTap(
        dispose: DisposeBag,
        _ closure: ((ControlEvent<Void>.Element) -> Void)?)
        -> Self
    {
        base.rx.tap
            .subscribe(onNext: closure)
            .disposed(by: dispose)
        return self
    }
}

extension Reactive where Base: UIButton {
    public var enable: Binder<Bool> {
        Binder(base) { button, enable in
            button.sr.enable(enable)
        }
    }
}
