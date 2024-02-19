import RxCocoa
import RxSwift
import UIKit

extension CycleBannerView: HasDelegate {
    public typealias Delegate = CycleBannerViewDelegate
}

public class RxCycleBannerViewDelegateProxy:
    DelegateProxy<CycleBannerView, CycleBannerViewDelegate>,
    DelegateProxyType,
    CycleBannerViewDelegate
{
    public init(bannerView: CycleBannerView) {
        super.init(parentObject: bannerView, delegateProxy: RxCycleBannerViewDelegateProxy.self)
    }

    public static func registerKnownImplementations() {
        register {
            RxCycleBannerViewDelegateProxy(bannerView: $0)
        }
    }

    public static func currentDelegate(for object: CycleBannerView) -> CycleBannerViewDelegate? {
        object.delegate
    }

    public static func setCurrentDelegate(_ delegate: CycleBannerViewDelegate?, to object: CycleBannerView) {
        object.delegate = delegate
    }
}

// MARK: - Observable

public extension Reactive where Base: CycleBannerView {
    var delegate: DelegateProxy<CycleBannerView, CycleBannerViewDelegate> {
        RxCycleBannerViewDelegateProxy.proxy(for: base)
    }

    var didSelected: Observable<Int> {
        delegate
            .methodInvoked(#selector(CycleBannerViewDelegate.didSelected(at:)))
            .map { a in
                (a[0] as! Int)
            }
    }

    var didScroll: Observable<Int> {
        delegate
            .methodInvoked(#selector(CycleBannerViewDelegate.didScroll(to:)))
            .map { a in
                (a[0] as! Int)
            }
    }
}
