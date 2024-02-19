import RxSwift

public extension Styler {
    @discardableResult
    func observe<
        Observable: ObservableType,
        Element
    >(
        from observable: Observable,
        to transform: (Reactive<Base>) -> Binder<Element>,
        dispose: DisposeBag
    )
        -> Self
        where
        Observable.Element == Element,
        Base: ReactiveCompatible
    {
        observable
            .bind(to: transform(base.rx))
            .disposed(by: dispose)
        return self
    }
}
