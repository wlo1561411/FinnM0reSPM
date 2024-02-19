import Combine

@available(iOS 14.0, *)
public protocol HasCancellable: AnyObject {
    var cancellable: Set<AnyCancellable> { get set }
}

@available(iOS 14.0, *)
public extension HasCancellable {
    func removeAllSubscriptions() {
        cancellable.forEach { $0.cancel() }
        cancellable.removeAll()
    }
}
