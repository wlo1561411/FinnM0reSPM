import Foundation

public final class Safety<T> {
    private let lock = UnfairLock()
    
    private var _value: T
    
    var value: T {
        get {
            self.lock.lock()
            defer { self.lock.unlock() }
            return self._value
        }
        
        _modify {
            self.lock.lock()
            defer { self.lock.unlock() }
            yield &self._value
        }
    }
    
    public init(_ wrappedValue: T) {
        self._value = wrappedValue
    }
    
    public func read<V>(_ f: (T) -> V) -> V {
        self.lock.lock(); defer { self.lock.unlock() }
        return f(self.value)
    }
    
    @discardableResult
    public func write<V>(_ f: (inout T) -> V) -> V {
        self.lock.lock(); defer { self.lock.unlock() }
        return f(&self.value)
    }
}
