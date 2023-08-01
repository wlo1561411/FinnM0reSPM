import Foundation

@propertyWrapper
public class ThreadSafe<Value> {
  private let queue = DispatchQueue(label: "com.threadSafe.\(UUID().uuidString)", attributes: .concurrent)
  private var value: Value

  public init(wrappedValue: Value) {
    self.value = wrappedValue
  }

  public var wrappedValue: Value {
    get {
      queue.sync { value }
    }
    set {
      queue.async(flags: .barrier, execute: {
        self.value = newValue
      })
    }
  }

  /// Array 或 Dictionary 的設值操作，最好都使用它
  /// 這樣才能保證較深層的資料指定，也是在同個Thread來進行
  public func mutate(_ mutation: @escaping (inout Value) -> Void) {
    queue.async(flags: .barrier, execute: {
      mutation(&self.value)
    })
  }
}
