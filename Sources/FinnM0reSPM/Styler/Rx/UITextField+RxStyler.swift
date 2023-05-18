import RxCocoa
import RxSwift
import UIKit

extension Styler where Base: UITextField {
  @discardableResult
  public func onText<T>(
    transform: (ControlProperty<String?>) -> Observable<T> = { $0.asObservable() },
    dispose: DisposeBag,
    _ closure: ((T) -> Void)?)
    -> Self
  {
    transform(base.rx.text)
      .subscribe(onNext: closure)
      .disposed(by: dispose)
    return self
  }
}
