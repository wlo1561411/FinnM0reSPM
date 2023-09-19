import Combine

@propertyWrapper
public struct SealPublished<T> {
    public typealias Publisher = AnyPublisher<T, Never>
    
    private let subject: CurrentValueSubject<T, Never>
    
    private let configure: ((Publisher) -> Publisher)?
    
    public var wrappedValue: T { subject.value }
    
    public var projectedValue: Publisher {
        let publisher = subject.dropFirst().eraseToAnyPublisher()
        return configure?(publisher) ?? publisher
    }
    
    public init(wrappedValue: T, configure: ((Publisher) -> Publisher)? = nil) {
        self.subject = CurrentValueSubject(wrappedValue)
        self.configure = configure
    }
    
    public func send(_ value: T) {
        subject.send(value)
    }
}
