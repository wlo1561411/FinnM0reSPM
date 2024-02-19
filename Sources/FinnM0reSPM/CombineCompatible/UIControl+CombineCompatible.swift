import Combine
import UIKit

@available(iOS 13.0, *)
extension UIButton: CombineCompatible {}

@available(iOS 13.0, *)
public extension CombineCompatible where Self: UIButton {
    func publisher(for events: UIControl.Event) -> UIControl.Publisher<Self> {
        UIControl.Publisher(control: self, events: events)
    }
}

@available(iOS 13.0, *)
extension UITextField: CombineCompatible {}

@available(iOS 13.0, *)
public extension CombineCompatible where Self: UITextField {
    func publisher(for events: UIControl.Event) -> UIControl.Publisher<Self> {
        UIControl.Publisher(control: self, events: events)
    }
}
