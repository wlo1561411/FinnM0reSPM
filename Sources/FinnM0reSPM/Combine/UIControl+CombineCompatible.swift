import Combine
import UIKit

@available(iOS 13.0, *)
extension UIControl {
  final class Subscription<
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

    func request(_: Subscribers.Demand) { }

    func cancel() {
      subscriber = nil
    }

    @objc
    private func eventHandler() {
      _ = subscriber?.receive(control)
    }
  }

  struct Publisher<Control: UIControl>: Combine.Publisher {
    typealias Output = Control
    typealias Failure = Never

    let control: Control
    let controlEvents: UIControl.Event

    init(control: Control, events: UIControl.Event) {
      self.control = control
      self.controlEvents = events
    }

    func receive<S>(subscriber: S)
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

@available(iOS 13.0, *)
extension UIControl: CombineCompatible { }

@available(iOS 13.0, *)
extension CombineCompatible where Self: UIControl {
  func publisher(for events: UIControl.Event) -> UIControl.Publisher<Self> {
    UIControl.Publisher(control: self, events: events)
  }
}
