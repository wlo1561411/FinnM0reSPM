import RxSwift
import RxCocoa
import UIKit

extension HasDataSource {
  /// Replace from ObservableType Extension  (DelegateProxyType.swift line 320)
  func subscribeProxyDataSource<
    DelegateProxy: DelegateProxyType,
    _ObservableType: ObservableType
  >(
    ofObject object: DelegateProxy.ParentObject,
    dataSource: DelegateProxy.Delegate,
    observable: _ObservableType,
    retainDataSource: Bool,
    binding: @escaping (DelegateProxy, Event<_ObservableType.Element>) -> Void)
    -> Disposable
    where
    DelegateProxy.ParentObject: UIView,
    DelegateProxy.Delegate: AnyObject
  {
    let proxy = DelegateProxy.proxy(for: object)
    let unregisterDelegate = DelegateProxy.installForwardDelegate(
      dataSource,
      retainDelegate: retainDataSource,
      onProxyForObject: object)

    if object.window != nil {
      object.layoutIfNeeded()
    }

    let subscription = observable.asObservable()
      .observe(on: MainScheduler())
      .catch { error in
        fatalError(error.localizedDescription)
      }
      .concat(Observable.never())
      .take(until: object.rx.deallocated)
      .subscribe { [weak object] (event: Event<_ObservableType.Element>) in

        if let object {
          assert(
            proxy === DelegateProxy.currentDelegate(for: object),
            "Proxy changed from the time it was first set.\nOriginal: \(proxy)\nExisting: \(String(describing: DelegateProxy.currentDelegate(for: object)))")
        }

        binding(proxy, event)

        switch event {
        case .error(let error):
          fatalError(error.localizedDescription)
        case .completed:
          unregisterDelegate.dispose()
        default:
          break
        }
      }

    return Disposables.create { [weak object] in
      subscription.dispose()

      if object?.window != nil {
        object?.layoutIfNeeded()
      }

      unregisterDelegate.dispose()
    }
  }
}
