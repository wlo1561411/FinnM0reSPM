import Combine
import UIKit

extension UIButton: CombineCompatible { }

extension CombineCompatible where Self: UIButton {
    public func publisher(for events: UIControl.Event) -> UIControl.Publisher<Self> {
        UIControl.Publisher(control: self, events: events)
    }
}

extension UITextField: CombineCompatible { }

extension CombineCompatible where Self: UITextField {
    public func publisher(for events: UIControl.Event) -> UIControl.Publisher<Self> {
        UIControl.Publisher(control: self, events: events)
    }
}
