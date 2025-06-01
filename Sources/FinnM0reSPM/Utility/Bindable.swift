import Foundation

@propertyWrapper
public class Bindable<T> {
    public class Handler {
        fileprivate var onChanged: ((T) -> Void)?
        fileprivate var setter: ((T) -> Void)?

        func observe(_ onChanged: ((T) -> Void)?) {
            self.onChanged = onChanged
        }

        func setWithoutEvent(_ value: T) {
            let currentOnChanged = self.onChanged
            onChanged = nil
            setter?(value)
            onChanged = currentOnChanged
        }
    }

    private let queue: DispatchQueue
    private let shouldTriggerChange: ((T, T) -> Bool)?
    private let handler = Handler()

    private var _wrappedValue: T
    public var wrappedValue: T {
        get { _wrappedValue }
        set {
            let oldValue = _wrappedValue

            _wrappedValue = newValue

            queue.async { [weak self] in
                guard
                    let self,
                    self.shouldTriggerChange?(oldValue, newValue) ?? true
                else { return }
                self.handler.onChanged?(newValue)
            }
        }
    }

    public var projectedValue: Handler {
        handler
    }

    public init(
        wrappedValue: T,
        queue: DispatchQueue = .main,
        shouldTriggerChange: ((_ old: T, _ new: T) -> Bool)? = nil)
    {
        self._wrappedValue = wrappedValue
        self.queue = queue
        self.shouldTriggerChange = shouldTriggerChange
        self.handler.setter = { [weak self] in
            self?._wrappedValue = $0
        }
    }

    public convenience init(
        queue: DispatchQueue = .main,
        shouldTriggerChange: ((T, T) -> Bool)? = nil)
        where T: ExpressibleByNilLiteral
    {
        self.init(wrappedValue: nil, queue: queue, shouldTriggerChange: shouldTriggerChange)
    }

    deinit {
        handler.onChanged = nil
        handler.setter = nil
    }
}
