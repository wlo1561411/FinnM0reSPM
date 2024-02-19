import Combine

@available(iOS 13.0, *)
@propertyWrapper
public struct SealPublished<T> {
    public typealias Publisher = AnyPublisher<T, Never>
    
    private class Storage {
        var cancellable: AnyCancellable?
    }
    
    private let subject: CurrentValueSubject<T, Never>
    private let storage = Storage()
    
    private var modifyPublisher: ((Publisher) -> Publisher)?
        
    public var wrappedValue: T { subject.value }

    public var projectedValue: Publisher {
        let publisher = subject.dropFirst().eraseToAnyPublisher()
        return modifyPublisher?(publisher) ?? publisher
    }
    
    public init(wrappedValue: T) {
        self.subject = CurrentValueSubject(wrappedValue)
    }
    
    public init(defaultValue: T, modifyPublisher: ((Publisher) -> Publisher)? = nil) {
        self.subject = CurrentValueSubject(defaultValue)
        self.modifyPublisher = modifyPublisher
    }

    public func send(_ value: T) {
        subject.send(value)
    }
    
    public func sealSink(receiveValue: @escaping ((T) -> Void)) {
        storage.cancellable = projectedValue.sink(receiveValue: receiveValue)
    }
    
    public func cancelSealedSubscription() {
        storage.cancellable?.cancel()
        storage.cancellable = nil
    }
}
