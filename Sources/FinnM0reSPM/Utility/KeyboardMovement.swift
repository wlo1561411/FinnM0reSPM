import RxCocoa
import RxSwift
import UIKit

public protocol KeyboardMovement { }

extension KeyboardMovement {
  private var keyboardAboveSpacing: CGFloat { 20 }
  
  private var keyboardWillShow: Observable<CGFloat> {
    NotificationCenter.default.rx
      .notification(UIResponder.keyboardWillChangeFrameNotification)
      .compactMap { ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height }
      .asObservable()
  }

  private var keyboardWillChangeFrame: Observable<CGFloat> {
    NotificationCenter.default.rx
      .notification(UIResponder.keyboardWillChangeFrameNotification)
      .compactMap { ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height }
      .asObservable()
  }

  private var keyboardWillHide: Observable<CGFloat> {
    NotificationCenter.default.rx
      .notification(UIResponder.keyboardWillHideNotification)
      .compactMap { _ in 0 }
      .asObservable()
  }

  public var keyboardHeightObservable: Observable<CGFloat> {
    Observable.merge([keyboardWillShow, keyboardWillHide, keyboardWillChangeFrame])
      .asObservable()
  }
}

extension KeyboardMovement where Self: UIViewController {
  public var viewMovementDriver: Driver<CGFloat?> {
    keyboardHeightObservable
      .map { [weak self] height in
        guard
          let self,
          self.isVisible,
          let textfield = UIApplication.shared.firstResponder as? UITextField,
          height > 0
        else { return nil }
        
        let keyboardFrame = CGRect(
          origin: .init(x: 0, y: UIScreen.main.bounds.height - height),
          size: .init(width: UIScreen.main.bounds.width, height: height))

        let origin = textfield.superview?
          .convert(textfield.frame, to: nil)
          .origin ?? .zero

        let maxYminXOrigin = CGPoint(
          x: origin.x,
          y: origin.y + textfield.frame.height + self.keyboardAboveSpacing)

        let estimated = origin.y - keyboardFrame.origin.y + textfield.frame.height + self.keyboardAboveSpacing

        if keyboardFrame.contains(maxYminXOrigin) {
          return estimated
        }
        else if maxYminXOrigin.y > keyboardFrame.maxY {
          return estimated - (maxYminXOrigin.y - keyboardFrame.maxY)
        }
        else {
          return 0
        }
      }
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: nil)
  }
}

extension UIApplication {
  fileprivate var firstResponder: UIResponder? {
    var _firstResponder: UIResponder?

    let reportAsFirstHandler = { (responder: UIResponder) in
      _firstResponder = responder
    }

    sendAction(
      #selector(UIResponder.reportAsFirst),
      to: nil,
      from:
      reportAsFirstHandler,
      for: nil)
    return _firstResponder
  }
}

extension UIResponder {
  @objc
  fileprivate func reportAsFirst(_ sender: Any) {
    if let handler = sender as? (UIResponder) -> Void {
      handler(self)
    }
  }
}
