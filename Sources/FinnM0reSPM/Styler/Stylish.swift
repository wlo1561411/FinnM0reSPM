@propertyWrapper
public struct Stylish<Value: StylerCompatible> {
    private let _wrappedValue: Value
    public var wrappedValue: Value { _wrappedValue }

    public var projectedValue: Styler<Value> { wrappedValue.sr }

    public init(wrappedValue: Value) {
        self._wrappedValue = wrappedValue
    }
}
