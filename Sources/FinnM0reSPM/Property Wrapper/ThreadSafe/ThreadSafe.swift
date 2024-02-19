// reference by https://github.com/geor-kasapidi/STS

@propertyWrapper
public final class ThreadSafe<T> {
    private let lock = UnfairLock()

    private var value: T

    public init(wrappedValue: T) {
        value = wrappedValue
    }

    public var projectedValue: ThreadSafe<T> { self }

    public var wrappedValue: T {
        get {
            lock.lock(); defer { self.lock.unlock() }
            return value
        }
        _modify {
            self.lock.lock(); defer { self.lock.unlock() }
            yield &self.value
        }
    }

    public func read<V>(_ f: (T) -> V) -> V {
        lock.lock(); defer { self.lock.unlock() }
        return f(value)
    }

    @discardableResult
    public func write<V>(_ f: (inout T) -> V) -> V {
        lock.lock(); defer { self.lock.unlock() }
        return f(&value)
    }
}
