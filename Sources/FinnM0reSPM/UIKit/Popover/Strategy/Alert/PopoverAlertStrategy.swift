import UIKit

extension PopoverStrategy where Self == PopoverAlertStrategy {
    /// 方便點語法直接叫出來
    public static func alert(
        size: PopoverAlertStrategy.Size,
        cornerRadius: CGFloat = 16,
        backgroundColorAlpha: CGFloat = 0.4,
        contentBackgroundColor: UIColor = .white,
        dismissOnTappedBackground: Bool = true)
        -> PopoverAlertStrategy
    {
        .init(
            backgroundColorAlpha: backgroundColorAlpha,
            contentBackgroundColor: contentBackgroundColor,
            dismissOnTappedBackground: dismissOnTappedBackground,
            cornerRadius: cornerRadius,
            size: size)
    }
}

public struct PopoverAlertStrategy: PopoverStrategy {
    public enum Size {
        /// 整個螢幕
        case fullScreen
        /// 自定義 size
        /// isRestricted 是否被 maximumSize 控制
        case minimum(_ size: CGSize, isRestricted: Bool = true)

        var value: CGSize {
            switch self {
            case .fullScreen:
                return .init(width: UIDevice.current.width, height: UIDevice.current.height)
            case .minimum(let size, _):
                return size
            }
        }
    }

    public let backgroundColorAlpha: CGFloat
    public let contentBackgroundColor: UIColor
    public let dismissOnTappedBackground: Bool

    /// content 不能超過的 size, fullScreen 例外
    private let maximumSize: CGSize = .init(width: UIDevice.current.width * 0.95, height: UIDevice.current.height * 0.6)

    let animateDuration = 0.25
    let cornerRadius: CGFloat

    /// 呈現出來的 size
    let size: Size
}

// MARK: - UI

extension PopoverAlertStrategy {
    public func addContentView(
        with view: UIView,

        at controller: UIViewController)
    {
        view.clipsToBounds = true
        view.layer.cornerRadius = cornerRadius
        // 避免 maximum 會讓 UI 閃一下
        view.alpha = 0

        controller.view.addSubview(view)
        view.snp.makeConstraints { make in
            make.size.equalTo(size.value).priority(.low)

            switch size {
            case .fullScreen:
                make.edges.equalToSuperview()
            case .minimum(_, let isRestricted):
                make.center.equalToSuperview()
                if isRestricted {
                    make.size.lessThanOrEqualTo(maximumSize)
                }
            }
        }
    }
}

// MARK: - Presentation

extension PopoverAlertStrategy {
    public func presentContent(
        with view: UIView,

        at controller: UIViewController,
        onPresented: (() -> Void)?)
    {
        view.alpha = 1
        view.transform = CGAffineTransform(scaleX: 0, y: 0)

        UIView.animate(
            withDuration: animateDuration,
            delay: 0,
            options: .curveLinear,
            animations: { [weak controller] in
                guard let controller else { return }
                controller.view.backgroundColor = backgroundColorWithAlpha
                view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            },
            completion: { _ in
                onPresented?()
            })
    }

    public func dismissContent(
        with view: UIView,

        at controller: UIViewController,
        beforeClosed: (() -> Void)?,
        onClosed: (() -> Void)?)
    {
        UIView.animate(
            withDuration: animateDuration,
            animations: { [weak controller, weak view] in
                view?.alpha = 0.0
                controller?.view.backgroundColor = backgroundColor.withAlphaComponent(0.0)
            },
            completion: { [weak controller] _ in
                beforeClosed?()
                controller?.dismiss(animated: false) {
                    onClosed?()
                }
            })
    }
}
