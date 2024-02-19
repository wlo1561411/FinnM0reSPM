import Combine
import UIKit

extension UIControl {
    public struct Publisher<Control: UIControl>: Combine.Publisher {
        public typealias Output = Control
        public typealias Failure = Never

        let control: Control
        let controlEvents: UIControl.Event

        init(control: Control, events: UIControl.Event) {
            self.control = control
            self.controlEvents = events
        }

        public func receive<S>(subscriber: S)
            where
            S: Subscriber,
            S.Failure == Publisher.Failure,
            S.Input == Publisher.Output
        {
            let subscription = Subscription(subscriber: subscriber, control: control, event: controlEvents)
            subscriber.receive(subscription: subscription)
        }
    }
}
