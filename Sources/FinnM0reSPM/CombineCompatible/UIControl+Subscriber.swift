import Combine
import UIKit

extension UIControl {
    public final class Subscription<
        SubscriberType: Subscriber,
        Control: UIControl
    >: Combine.Subscription
        where SubscriberType.Input == Control
    {
        private var subscriber: SubscriberType?
        private let control: Control

        init(subscriber: SubscriberType, control: Control, event: UIControl.Event) {
            self.subscriber = subscriber
            self.control = control
            control.addTarget(self, action: #selector(eventHandler), for: event)
        }

        public func request(_: Subscribers.Demand) { }

        public func cancel() {
            subscriber = nil
        }

        @objc
        private func eventHandler() {
            _ = subscriber?.receive(control)
        }
    }
}
