import Combine

@available(iOS 13.0, *)
@propertyWrapper
public struct SealPublished<T> {
    public typealias Publisher = AnyPublisher<T, Never>
    
    public class PublisherHandler {
        fileprivate weak var subject: CurrentValueSubject<T, Never>?
        fileprivate var modifyPublisher: ((Publisher) -> Publisher)?
        
        private var cancellable: AnyCancellable?
        
        /// Default publisher will drop first value
        public func publisher(dropFirst: Bool = true) -> Publisher {
            let publisher = subject?
                .if(dropFirst) {
                    $0.dropFirst().eraseToAnyPublisher()
                }
                .eraseToAnyPublisher() ?? Empty().eraseToAnyPublisher()
            
            return modifyPublisher?(publisher) ?? publisher
        }
        
        /// Default publisher will drop first value
        public func sealSink(dropFirst: Bool = true, receiveValue: @escaping ((T) -> Void)) {
            cancellable = publisher(dropFirst: dropFirst)
                .sink(receiveValue: receiveValue)
        }
        
        public func cancelSealedSubscription() {
            cancellable?.cancel()
            cancellable = nil
        }
        
        deinit {
            cancelSealedSubscription()
        }
    }
    
    private let subject: CurrentValueSubject<T, Never>
    private let publisherHandler = PublisherHandler()
    
    public var wrappedValue: T {
        get {
            subject.value
        }
        set {
            subject.send(newValue)
        }
    }

    public var projectedValue: PublisherHandler {
        publisherHandler
    }
    
    public init(wrappedValue: T) {
        self.subject = CurrentValueSubject(wrappedValue)
        self.publisherHandler.subject = subject
    }
    
    /// The modifyPublisher can not omitted if needed
    public init(defaultValue: T, modifyPublisher: ((Publisher) -> Publisher)? = nil) {
        self.subject = CurrentValueSubject(defaultValue)
        self.publisherHandler.subject = subject
        self.publisherHandler.modifyPublisher = modifyPublisher
    }
}
