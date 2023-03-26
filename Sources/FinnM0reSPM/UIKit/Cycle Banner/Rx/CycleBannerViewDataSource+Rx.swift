import RxCocoa
import RxSwift
import UIKit

extension CycleBannerView: HasDataSource {
  public typealias DataSource = CycleBannerViewDataSource
}

// MARK: - Proxy

public class RxCycleBannerViewDataSourceProxy:
  DelegateProxy<CycleBannerView, CycleBannerViewDataSource>,
  DelegateProxyType
{
  public private(set) weak var bannerView: CycleBannerView?

  public init(bannerView: CycleBannerView) {
    self.bannerView = bannerView
    super.init(parentObject: bannerView, delegateProxy: RxCycleBannerViewDataSourceProxy.self)
  }

  public static func currentDelegate(for object: CycleBannerView) -> CycleBannerViewDataSource? {
    object.dataSource
  }

  public static func setCurrentDelegate(_ delegate: CycleBannerViewDataSource?, to object: CycleBannerView) {
    object.dataSource = delegate
  }

  public static func registerKnownImplementations() {
    self.register { RxCycleBannerViewDataSourceProxy(bannerView: $0) }
  }

  private weak var _requiredMethodsDataSource: CycleBannerViewDataSource?

  override open func setForwardToDelegate(_ forwardToDelegate: CycleBannerViewDataSource?, retainDelegate: Bool) {
    _requiredMethodsDataSource = forwardToDelegate ?? nil
    super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
  }
}

extension RxCycleBannerViewDataSourceProxy: CycleBannerViewDataSource {
  public func item(at index: Int) -> UIView {
    _requiredMethodsDataSource?.item(at: index) ?? .init()
  }

  public func numberOfItems() -> Int {
    _requiredMethodsDataSource?.numberOfItems() ?? 0
  }
}

// MARK: - Wrapper

public protocol RxCycleBannerViewDataSourceType {
  associatedtype Element
  func bannerView(_ bannerView: CycleBannerView, observedEvent: Event<Element>)
}

class RxCycleBannerViewDataSourceSequenceWrapper<Sequence: Swift.Sequence>:
  RxCycleBannerViewDataSource,
  RxCycleBannerViewDataSourceType
{
  typealias Element = Sequence

  override init(factory: @escaping Factory) {
    super.init(factory: factory)
  }

  func bannerView(_ bannerView: CycleBannerView, observedEvent: RxSwift.Event<Sequence>) {
    Binder(self) { dataSource, items in
      let count = Array(items).count
      dataSource.bannerView(bannerView, observedElements: count)
      bannerView.reload()
    }
    .on(observedEvent)
  }
}

class RxCycleBannerViewDataSource: CycleBannerViewDataSource {
  typealias Factory = (Int) -> UIView

  var count: Int?

  let factory: Factory

  init(factory: @escaping Factory) {
    self.factory = factory
  }

  func item(at index: Int) -> UIView {
    factory(index)
  }

  func numberOfItems() -> Int {
    count ?? 0
  }

  func bannerView(_: CycleBannerView, observedElements: Int) {
    self.count = observedElements
  }
}

// MARK: - Binding

extension Reactive where Base: CycleBannerView {
  public func items<
    Sequence: Swift.Sequence,
    Source: ObservableType
  >
  (_ source: Source)
    -> (_ factory: @escaping (Int) -> UIView)
    -> Disposable
    where Source.Element == Sequence
  {
    { factory in
      let dataSource = RxCycleBannerViewDataSourceSequenceWrapper<Sequence>(factory: factory)
      return self.items(dataSource: dataSource)(source)
    }
  }

  public func items<
    DataSource: RxCycleBannerViewDataSourceType & CycleBannerViewDataSource,
    _ObservableType: ObservableType
  >
  (dataSource: DataSource)
    -> (_ source: _ObservableType)
    -> Disposable
    where DataSource.Element == _ObservableType.Element
  {
    { source in

      _ = self.delegate

      return base.subscribeProxyDataSource(
        ofObject: self.base,
        dataSource: dataSource as CycleBannerViewDataSource,
        observable: source,
        retainDataSource: true)
      { [weak bannerView = self.base] (_: RxCycleBannerViewDataSourceProxy, event) in
        guard let bannerView else { return }
        dataSource.bannerView(bannerView, observedEvent: event)
      }
    }
  }
}
