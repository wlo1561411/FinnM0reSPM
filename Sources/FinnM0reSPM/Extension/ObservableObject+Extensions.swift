import RxSwift

extension ObservableConvertibleType {
  public func publish<Object: AnyObject, Value>(
    to object: Object,
    _ keyPath: ReferenceWritableKeyPath<Object, Value>)
    -> Observable<Element>
    where Element == Value
  {
    self.asObservable()
      .observe(on: MainScheduler.instance)
      .do(onNext: { [weak object] newValue in
        object?[keyPath: keyPath] = newValue
      })
  }

  public func publish<Object: AnyObject, Value>(
    to object: Object,
    _ keyPath: ReferenceWritableKeyPath<Object, Value?>)
    -> Observable<Element>
    where Element == Value
  {
    self.asObservable()
      .observe(on: MainScheduler.instance)
      .do(onNext: { [weak object] newValue in
        object?[keyPath: keyPath] = newValue
      })
  }
}

extension Completable {
  public func complete<Object: AnyObject>(
    to object: Object,
    _ keyPath: ReferenceWritableKeyPath<Object, Bool>)
    -> Completable
  {
    self.observe(on: MainScheduler.instance)
      .do(onCompleted: { [weak object] in
        object?[keyPath: keyPath] = true
      })
  }
}
