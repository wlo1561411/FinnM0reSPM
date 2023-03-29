import RxSwift
import RxCocoa
import UIKit

extension Styler where Base: UIButton {
  @discardableResult
  public func font(_ font: UIFont) -> Self {
    base.titleLabel?.font = font
    return self
  }

  @discardableResult
  public func titleColor(_ color: UIColor, state: UIControl.State = .normal) -> Self {
    base.setTitleColor(color, for: state)
    return self
  }

  @discardableResult
  public func title(_ text: String?, state: UIControl.State = .normal) -> Self {
    base.setTitle(text, for: state)
    return self
  }

  @discardableResult
  public func enable(_ enable: Bool) -> Self {
    base.alpha = enable ? 1 : 0.2
    base.isEnabled = enable
    return self
  }
}

// MARK: - Rx

extension Styler where Base: UIButton {
  @discardableResult
  public func tap(on closure: ((ControlEvent<Void>.Element) -> Void)?, dispose: DisposeBag) -> Self {
    base.rx.tap
      .subscribe(onNext: closure)
      .disposed(by: dispose)
    return self
  }
}

extension Reactive where Base: UIButton {
  public var enable: Binder<Bool> {
    Binder(self.base) { button, enable in
      button.sr.enable(enable)
    }
  }
}
