import UIKit
import RxSwift
import RxCocoa

extension Styler where Base: UITextField {
  @discardableResult
  public func placeholder(_ text: String?, color: UIColor = .lightGray) -> Self {
    base.attributedPlaceholder = text?
      .attributed
      .textColor(color)
      .font(base.font ?? .systemFont(ofSize: 16))
    return self
  }

  public enum Padding {
    case horizontal
    case left
    case right
  }

  @discardableResult
  public func padding(_ padding: Padding, offset: CGFloat) -> Self {
    switch padding {
    case .horizontal:
      let lv = UIView(frame: .init(origin: .zero, size: .init(width: offset, height: 1)))
      let rv = UIView(frame: .init(origin: .zero, size: .init(width: offset, height: 1)))
      base.leftViewMode = .always
      base.rightViewMode = .always
      base.leftView = lv
      base.rightView = rv

    case .left:
      let lv = UIView(frame: .init(origin: .zero, size: .init(width: offset, height: 1)))
      base.leftViewMode = .always
      base.leftView = lv

    case .right:
      let rv = UIView(frame: .init(origin: .zero, size: .init(width: offset, height: 1)))
      base.rightViewMode = .always
      base.rightView = rv
    }
    return self
  }
  
  public func remainCursor(to new: String) {
    guard let selectedTextRange = base.selectedTextRange else { return }

    let currentCursorPosition = base.offset(from: base.beginningOfDocument, to: selectedTextRange.start)
    let selectedCount = base.offset(from: selectedTextRange.start, to: selectedTextRange.end)
    let differentCount = new.count - (base.text?.count ?? 0)

    let cursorOffset = currentCursorPosition + selectedCount + differentCount

    base.text = new

    if let newCursorPosition = base.position(from: base.beginningOfDocument, offset: cursorOffset) {
      DispatchQueue.main.async {
        base.selectedTextRange = base.textRange(from: newCursorPosition, to: newCursorPosition)
      }
    }
  }
}

// MARK: - Rx

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
