import RxCocoa
import RxSwift
import UIKit

extension SlideView: HasDataSource {
  public typealias DataSource = SlideViewDataSource
}

// MARK: - Proxy

public class RxSlideViewDataSourceProxy:
  DelegateProxy<SlideView, SlideViewDataSource>,
  DelegateProxyType
{
  public private(set) weak var slideView: SlideView?

  public init(slideView: SlideView) {
    self.slideView = slideView
    super.init(parentObject: slideView, delegateProxy: RxSlideViewDataSourceProxy.self)
  }

  public static func currentDelegate(for object: SlideView) -> SlideViewDataSource? {
    object.dataSource
  }

  public static func setCurrentDelegate(_ delegate: SlideViewDataSource?, to object: SlideView) {
    object.dataSource = delegate
  }

  public static func registerKnownImplementations() {
    self.register { RxSlideViewDataSourceProxy(slideView: $0) }
  }

  private weak var _requiredMethodsDataSource: SlideViewDataSource?

  override open func setForwardToDelegate(_ forwardToDelegate: SlideViewDataSource?, retainDelegate: Bool) {
    _requiredMethodsDataSource = forwardToDelegate ?? nil
    super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
  }
}

extension RxSlideViewDataSourceProxy: SlideViewDataSource {
  public func numberOfViewController(_ slideView: SlideView) -> Int {
    _requiredMethodsDataSource?.numberOfViewController(slideView) ?? 0
  }

  public func viewController(_ slideView: SlideView, at index: Int) -> UIViewController {
    _requiredMethodsDataSource?.viewController(slideView, at: index) ?? .init()
  }
}

// MARK: - Wrapper

public protocol RxSlideViewDataSourceType {
  associatedtype Element
  func slideView(_ slideView: SlideView, observedEvent: Event<Element>, at baseController: UIViewController?)
}

class RxSlideViewDataSourceSequenceWrapper<Sequence: Swift.Sequence>:
  RxSlideViewDataSource,
  RxSlideViewDataSourceType
{
  typealias Element = Sequence

  override init(factory: @escaping Factory) {
    super.init(factory: factory)
  }

  func slideView(_ slideView: SlideView, observedEvent: Event<Sequence>, at baseController: UIViewController?) {
    Binder(self) { dataSource, items in
      let count = Array(items).count
      slideView.setup(cacheSize: count, at: baseController!)
      dataSource.slideView(slideView, observedElements: count)
    }
    .on(observedEvent)
  }
}

class RxSlideViewDataSource: SlideViewDataSource {
  typealias Factory = (SlideView, Int) -> UIViewController

  var count: Int?

  let factory: Factory

  init(factory: @escaping Factory) {
    self.factory = factory
  }

  func numberOfViewController(_: SlideView) -> Int {
    count ?? 0
  }

  func viewController(_ slideView: SlideView, at index: Int) -> UIViewController {
    factory(slideView, index)
  }

  func slideView(_: SlideView, observedElements: Int) {
    self.count = observedElements
  }
}

// MARK: - Binding
// TODO: Cache Size
extension Reactive where Base: SlideView {
  public func items<
    Sequence: Swift.Sequence,
    Source: ObservableType
  >
  (at baseController: UIViewController)
    -> (_ source: Source)
    -> (_ factory: @escaping (SlideView, Int) -> UIViewController)
    -> Disposable
    where Source.Element == Sequence
  {
    { source in
      { factory in
        let dataSource = RxSlideViewDataSourceSequenceWrapper<Sequence>(factory: factory)
        return self.items(dataSource: dataSource, at: baseController)(source)
      }
    }
  }

  public func items<
    DataSource: RxSlideViewDataSourceType & SlideViewDataSource,
    _ObservableType: ObservableType
  >(
    dataSource: DataSource,
    at baseController: UIViewController)
    -> (_ source: _ObservableType)
    -> Disposable
    where DataSource.Element == _ObservableType.Element
  {
    { source in

      _ = self.delegate

      return base.subscribeProxyDataSource(
        ofObject: self.base,
        dataSource: dataSource as SlideViewDataSource,
        observable: source,
        retainDataSource: true)
      { [weak slideView = self.base, weak baseController] (_: RxSlideViewDataSourceProxy, event) in
        guard let slideView, let baseController else { return }
        dataSource.slideView(slideView, observedEvent: event, at: baseController)
      }
    }
  }
}
