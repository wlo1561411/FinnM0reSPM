import RxCocoa
import RxSwift
import UIKit

extension SlideTabBar: HasDataSource {
  public typealias DataSource = SlideTabBarDataSource
}

// MARK: - Proxy

public class RxSlideTabBarDataSourceProxy:
  DelegateProxy<SlideTabBar, SlideTabBarDataSource>,
  DelegateProxyType
{
  public private(set) weak var tabBar: SlideTabBar?

  public init(tabBar: SlideTabBar) {
    self.tabBar = tabBar
    super.init(parentObject: tabBar, delegateProxy: RxSlideTabBarDataSourceProxy.self)
  }

  public static func currentDelegate(for object: SlideTabBar) -> SlideTabBarDataSource? {
    object.dataSource
  }

  public static func setCurrentDelegate(_ delegate: SlideTabBarDataSource?, to object: SlideTabBar) {
    object.dataSource = delegate
  }

  public static func registerKnownImplementations() {
    self.register { RxSlideTabBarDataSourceProxy(tabBar: $0) }
  }

  private weak var _requiredMethodsDataSource: SlideTabBarDataSource?

  override open func setForwardToDelegate(_ forwardToDelegate: SlideTabBarDataSource?, retainDelegate: Bool) {
    _requiredMethodsDataSource = forwardToDelegate ?? nil
    super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
  }
}

extension RxSlideTabBarDataSourceProxy: SlideTabBarDataSource {
  public func numberOfItems(_ sender: SlideTabBar) -> Int {
    _requiredMethodsDataSource?.numberOfItems(sender) ?? 0
  }

  public func itemView(_ sender: SlideTabBar, at index: Int) -> SlideTabBar.Item {
    _requiredMethodsDataSource?.itemView(sender, at: index) ?? .init()
  }
}

// MARK: - Wrapper

public protocol RxSlideTabBarDataSourceType {
  associatedtype Element
  func tabBar(_ tabBar: SlideTabBar, observedEvent: Event<Element>)
  func tabBar(_ tabBar: SlideTabBar, observedEvent: Event<[String]>)
}

class RxSlideTabBarDataSourceSequenceWrapper<Sequence: Swift.Sequence>:
  RxSlideTabBarDataSource,
  RxSlideTabBarDataSourceType
{
  typealias Element = Sequence

  override init(factory: @escaping Factory) {
    super.init(factory: factory)
  }

  override init() {
    super.init()
  }

  func tabBar(_ tabBar: SlideTabBar, observedEvent: Event<Sequence>) {
    Binder(self) { dataSource, items in
      let count = Array(items).count
      dataSource.tabBar(tabBar, observedElements: count)
      tabBar.reload()
    }
    .on(observedEvent)
  }

  func tabBar(_ tabBar: SlideTabBar, observedEvent: Event<[String]>) {
    Binder(self) { dataSource, items in
      dataSource.tabBar(tabBar, observedElements: items)
      tabBar.reload()
    }
    .on(observedEvent)
  }
}

class RxSlideTabBarDataSource: SlideTabBarDataSource {
  typealias Factory = (SlideTabBar, Int) -> SlideTabBar.Item

  var count: Int?

  var titles: [String]?

  var factory: Factory!

  init(factory: @escaping Factory) {
    self.factory = factory
  }

  init() {
    self.factory = { [weak self] tabBar, index in
      let item = SlideTabBar.DefaultItem(model: tabBar.itemModel)
      item.titleLabel.text = self?.titles?[index]
      return item
    }
  }

  func numberOfItems(_: SlideTabBar) -> Int {
    count ?? 0
  }

  func itemView(_ sender: SlideTabBar, at index: Int) -> SlideTabBar.Item {
    factory(sender, index)
  }

  func tabBar(_: SlideTabBar, observedElements: Int) {
    self.count = observedElements
  }

  func tabBar(_: SlideTabBar, observedElements: [String]) {
    self.titles = observedElements
    self.count = observedElements.count
  }
}

// MARK: - Binding

extension Reactive where Base: SlideTabBar {
  public func titles<Source: ObservableType>
  (_ source: Source)
    -> Disposable
    where Source.Element == [String]
  {
    let dataSource = RxSlideTabBarDataSourceSequenceWrapper<[String]>()
    return self.items(dataSource: dataSource)(source)
  }

  public func items<
    Sequence: Swift.Sequence,
    Source: ObservableType
  >
  (_ source: Source)
  -> (_ factory: @escaping (SlideTabBar, Int) -> SlideTabBar.Item)
    -> Disposable
    where Source.Element == Sequence
  {
    { factory in
      let dataSource = RxSlideTabBarDataSourceSequenceWrapper<Sequence>(factory: factory)
      return self.items(dataSource: dataSource)(source)
    }
  }

  public func items<
    DataSource: RxSlideTabBarDataSourceType & SlideTabBarDataSource,
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
        dataSource: dataSource as SlideTabBarDataSource,
        observable: source,
        retainDataSource: true)
      { [weak tabBar = self.base] (_: RxSlideTabBarDataSourceProxy, event) in
        guard let tabBar else { return }

        if let _event = event as? Event<[String]> {
          dataSource.tabBar(tabBar, observedEvent: _event)
        }
        else {
          dataSource.tabBar(tabBar, observedEvent: event)
        }
      }
    }
  }
}
