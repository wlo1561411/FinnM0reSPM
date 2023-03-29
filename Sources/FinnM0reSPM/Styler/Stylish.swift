@propertyWrapper
public struct Stylish<Value: StylerCompatible> {
  public var wrappedValue: Value
  
  public var projectedValue: Styler<Value> { wrappedValue.sr }
  
  public init(wrappedValue: Value) {
    self.wrappedValue = wrappedValue
  }
}
