import RxCocoa
import RxRelay
import RxSwift
import UIKit

extension SlideView: HasDelegate {
  public typealias Delegate = SlideViewDelegate
}

public class RxSlideViewDelegateProxy:
  DelegateProxy<SlideView, SlideViewDelegate>,
  DelegateProxyType,
  SlideViewDelegate
{
  public init(slide: SlideView) {
    super.init(parentObject: slide, delegateProxy: RxSlideViewDelegateProxy.self)
  }

  public static func registerKnownImplementations() {
    self.register {
      RxSlideViewDelegateProxy(slide: $0)
    }
  }

  public static func currentDelegate(for object: SlideView) -> SlideViewDelegate? {
    object.delegate
  }

  public static func setCurrentDelegate(_ delegate: SlideViewDelegate?, to object: SlideView) {
    object.delegate = delegate
  }
}

// MARK: - Observable

extension Reactive where Base: SlideView {
  public var delegate: DelegateProxy<SlideView, SlideViewDelegate> {
    RxSlideViewDelegateProxy.proxy(for: base)
  }

  public var switching: Observable<(fromIndex: Int, toIndex: Int, percentage: CGFloat)> {
    delegate
      .methodInvoked(#selector(SlideViewDelegate.switching(from:to:with:)))
      .map { a in
        (a[0] as! Int, a[1] as! Int, a[2] as! CGFloat)
      }
  }

  public var willSwitch: Observable<(index: Int, viewController: UIViewController)> {
    delegate
      .methodInvoked(#selector(SlideViewDelegate.willSwitch(to:viewController:)))
      .map { a in
        (a[0] as! Int, a[1] as! UIViewController)
      }
  }

  public var didSwitch: Observable<(index: Int, viewController: UIViewController)> {
    delegate
      .methodInvoked(#selector(SlideViewDelegate.didSwitch(to:viewController:)))
      .map { a in
        (a[0] as! Int, a[1] as! UIViewController)
      }
  }

  public var didCancelSwitch: Observable<(index: Int, viewController: UIViewController)> {
    delegate
      .methodInvoked(#selector(SlideViewDelegate.didCancelSwitch(to:viewController:)))
      .map { a in
        (a[0] as! Int, a[1] as! UIViewController)
      }
  }
}
