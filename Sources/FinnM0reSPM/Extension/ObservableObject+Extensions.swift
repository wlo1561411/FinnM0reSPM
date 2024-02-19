import RxSwift

public extension ObservableConvertibleType {
    func publish<Object: AnyObject, Value>(
        to object: Object,
        _ keyPath: ReferenceWritableKeyPath<Object, Value>
    )
        -> Observable<Element>
        where Element == Value
    {
        asObservable()
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak object] newValue in
                object?[keyPath: keyPath] = newValue
            })
    }

    func publish<Object: AnyObject, Value>(
        to object: Object,
        _ keyPath: ReferenceWritableKeyPath<Object, Value?>
    )
        -> Observable<Element>
        where Element == Value
    {
        asObservable()
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak object] newValue in
                object?[keyPath: keyPath] = newValue
            })
    }
}

public extension Completable {
    func complete<Object: AnyObject>(
        to object: Object,
        _ keyPath: ReferenceWritableKeyPath<Object, Bool>
    )
        -> Completable
    {
        observe(on: MainScheduler.instance)
            .do(onCompleted: { [weak object] in
                object?[keyPath: keyPath] = true
            })
    }
}
