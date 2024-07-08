import Combine
import UIKit

public protocol KeyboardMovement { }

extension KeyboardMovement {
    private var keyboardAboveSpacing: CGFloat { 20 }

    private var keyboardWillShow: AnyPublisher<CGFloat, Never> {
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .compactMap { ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height }
            .eraseToAnyPublisher()
    }

    private var keyboardWillChangeFrame: AnyPublisher<CGFloat, Never> {
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .compactMap { ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height }
            .eraseToAnyPublisher()
    }

    private var keyboardWillHide: AnyPublisher<CGFloat, Never> {
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .compactMap { _ in 0 }
            .eraseToAnyPublisher()
    }

    public var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        Publishers.Merge3(keyboardWillHide, keyboardWillShow, keyboardWillChangeFrame)
            .eraseToAnyPublisher()
    }
}

extension KeyboardMovement where Self: UIViewController {
    public var viewMovementPublisher: AnyPublisher<CGFloat?, Never> {
        keyboardHeightPublisher
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
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

@available(iOS 14.0, *)
extension KeyboardMovement where Self: UIViewController, Self: HasCancellable {
    func handleKeyboardInteraction() {
        view.appendHighlightGesture(
            onClick: { [weak self] in
                self?.view.endEditing(true)
            })

        viewMovementPublisher
            .sink(receiveValue: { [weak self] value in
                UIView.animate(withDuration: 0.2, animations: {
                    self?.view.frame.origin.y = -(value ?? 0)
                })
            })
            .store(in: &cancellable)
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
