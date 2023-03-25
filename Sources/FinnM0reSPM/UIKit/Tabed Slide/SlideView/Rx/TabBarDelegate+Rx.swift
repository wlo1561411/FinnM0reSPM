import RxCocoa
import RxSwift
import UIKit

extension SlideView.TabBar: HasDelegate {
  public typealias Delegate = SlideTabBarDelegate
}

public class RxSlideTabBarDelegateProxy:
  DelegateProxy<SlideView.TabBar, SlideTabBarDelegate>,
  DelegateProxyType,
  SlideTabBarDelegate
{
  public init(tabBar: SlideView.TabBar) {
    super.init(parentObject: tabBar, delegateProxy: RxSlideTabBarDelegateProxy.self)
  }

  public static func registerKnownImplementations() {
    self.register {
      RxSlideTabBarDelegateProxy(tabBar: $0)
    }
  }

  public static func currentDelegate(for object: SlideView.TabBar) -> SlideTabBarDelegate? {
    object.delegate
  }

  public static func setCurrentDelegate(_ delegate: SlideTabBarDelegate?, to object: SlideView.TabBar) {
    object.delegate = delegate
  }
}

// MARK: - Observable

extension Reactive where Base: SlideView.TabBar {
  public var delegate: DelegateProxy<SlideView.TabBar, SlideTabBarDelegate> {
    RxSlideTabBarDelegateProxy.proxy(for: base)
  }

  public var didSelected: Observable<(sender: SlideView.TabBar, index: Int)> {
    delegate
      .methodInvoked(#selector(SlideTabBarDelegate.didSelected(_:at:)))
      .map { a in
        (a[0] as! SlideView.TabBar, a[1] as! Int)
      }
  }
}
