import Combine

@available(iOS 14.0, *)
public protocol HasCancellable: AnyObject {
    var cancellable: Set<AnyCancellable> { get set }
}

@available(iOS 14.0, *)
extension HasCancellable {
    public func removeAllSubscriptions() {
        cancellable.forEach { $0.cancel() }
        cancellable.removeAll()
    }
}
