import Combine
import UIKit

@available(iOS 13.0, *)
extension UIButton: CombineCompatible { }

@available(iOS 13.0, *)
extension CombineCompatible where Self: UIButton {
    public func publisher(for events: UIControl.Event) -> UIControl.Publisher<Self> {
        UIControl.Publisher(control: self, events: events)
    }
}

@available(iOS 13.0, *)
extension UITextField: CombineCompatible { }

@available(iOS 13.0, *)
extension CombineCompatible where Self: UITextField {
    public func publisher(for events: UIControl.Event) -> UIControl.Publisher<Self> {
        UIControl.Publisher(control: self, events: events)
    }
}
