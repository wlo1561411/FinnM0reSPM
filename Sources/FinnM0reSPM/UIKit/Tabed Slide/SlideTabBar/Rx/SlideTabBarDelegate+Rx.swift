import RxCocoa
import RxSwift
import UIKit

extension SlideTabBar: HasDelegate {
  public typealias Delegate = SlideTabBarDelegate
}

public class RxSlideTabBarDelegateProxy:
  DelegateProxy<SlideTabBar, SlideTabBarDelegate>,
  DelegateProxyType,
  SlideTabBarDelegate
{
  public init(tabBar: SlideTabBar) {
    super.init(parentObject: tabBar, delegateProxy: RxSlideTabBarDelegateProxy.self)
  }

  public static func registerKnownImplementations() {
    self.register {
      RxSlideTabBarDelegateProxy(tabBar: $0)
    }
  }

  public static func currentDelegate(for object: SlideTabBar) -> SlideTabBarDelegate? {
    object.delegate
  }

  public static func setCurrentDelegate(_ delegate: SlideTabBarDelegate?, to object: SlideTabBar) {
    object.delegate = delegate
  }
}

// MARK: - Observable

extension Reactive where Base: SlideTabBar {
  public var delegate: DelegateProxy<SlideTabBar, SlideTabBarDelegate> {
    RxSlideTabBarDelegateProxy.proxy(for: base)
  }

  public var didSelected: Observable<(sender: SlideTabBar, index: Int)> {
    delegate
      .methodInvoked(#selector(SlideTabBarDelegate.didSelected(_:at:)))
      .map { a in
        (a[0] as! SlideTabBar, a[1] as! Int)
      }
  }
}
