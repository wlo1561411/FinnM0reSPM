import Foundation

@propertyWrapper
public class Bindable<T> {
    private var onChanged: ((T) -> Void)?
    private let queue: DispatchQueue

    public var wrappedValue: T {
        didSet {
            queue.async { [weak self] in
                guard let self else { return }
                onChanged?(wrappedValue)
            }
        }
    }

    public var projectedValue: ((T) -> Void)? {
        get {
            onChanged
        }
        set {
            onChanged = newValue
        }
    }

    public init(wrappedValue: T, queue: DispatchQueue = .main) {
        self.wrappedValue = wrappedValue
        self.queue = queue
    }

    deinit {
        onChanged = nil
    }
}
