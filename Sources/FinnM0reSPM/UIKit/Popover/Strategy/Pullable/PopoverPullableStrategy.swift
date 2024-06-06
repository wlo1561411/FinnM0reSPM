import UIKit

extension PopoverStrategy where Self == PopoverPullableStrategy {
    /// 方便點語法直接叫出來
    public static func pullable(
        _ type: PopoverPullableStrategy.`Type`,
        backgroundColorAlpha: CGFloat = 0.6,
        contentBackgroundColor: UIColor = .white,
        pannedDistanceShouldCollapse: CGFloat = 30,
        pannedDistanceShouldExpand: CGFloat = 30,
        isNeedPullBar: Bool = true,
        isMoveByKeyboard: Bool = true)
        -> PopoverPullableStrategy
    {
        .init(
            type: type,
            backgroundColorAlpha: backgroundColorAlpha,
            contentBackgroundColor: contentBackgroundColor,
            pannedDistanceShouldCollapse: pannedDistanceShouldCollapse,
            pannedDistanceShouldExpand: pannedDistanceShouldExpand,
            isNeedPullBar: isNeedPullBar,
            isMoveByKeyboard: isMoveByKeyboard)
    }
}

public final class PopoverPullableStrategy: PopoverStrategy {
    public enum `Type` {
        /// 可以自由拉動
        case freeform(_ height: Height)
        /// 只能往下拉
        case normal(_ height: Height)

        /// 初始高度, 為了要讓 manual update 正常運作
        func getInitialHeight(with controller: UIViewController) -> CGFloat {
            switch self {
            case .freeform(let height),
                 .normal(let height):
                if case Height.fullPage = height {
                    return getControllerSafeAreaMaxHeight(with: controller)
                }
            }
            return getMinimumHeight(with: controller)
        }

        /// 被限制最低高度
        func getMinimumHeight(with _: UIViewController) -> CGFloat {
            switch self {
            case .freeform(let height),
                 .normal(let height):
                switch height {
                case .percentage(let minimum, let maximum):
                    return UIDevice.current.height * (CGFloat(min(minimum, maximum)) / 100)
                case .value(let minimum, let maximum):
                    return min(minimum, maximum)
                default:
                    break
                }
            }
            return 0
        }

        /// 被限制最高高度
        func getMaximumHeight(with controller: UIViewController) -> CGFloat {
            let controllerSafeAreaMaxHeight = getControllerSafeAreaMaxHeight(with: controller)

            switch self {
            case .freeform(let height),
                 .normal(let height):
                switch height {
                case .percentage(let minimum, let maximum):
                    return min(UIDevice.current.height * (CGFloat(max(minimum, maximum)) / 100), controllerSafeAreaMaxHeight)
                case .value(let minimum, let maximum):
                    return min(controllerSafeAreaMaxHeight, max(minimum, maximum))
                default:
                    break
                }
            }
            return controllerSafeAreaMaxHeight
        }

        /// 整個畫面扣掉上方的保留高度
        /// 如果 controller 還沒 layout 完, 先拿 window 的邊距
        func getControllerSafeAreaMaxHeight(with controller: UIViewController) -> CGFloat {
            controller.view.frame.height - max(controller.view.safeAreaInsets.top, UIDevice.current.statusBarHeight)
        }
    }

    public enum Height {
        /// minimum: 以 **整個螢幕的高度** 計算出來的高度乘上百分比
        /// maximum: 會限制計算出來的高度就是最高高度, 但不會超過 controller 的 safe area
        case percentage(minimum: Int, maximum: Int)
        /// minimum: 最低高度
        /// maximum: 最高高度, 但不會超過 controller 的 safe area
        case value(minimum: CGFloat, maximum: CGFloat)
        /// 會推滿到整頁高度, 但不包含 controller 的 safe area top inset
        case fullPage
        /// content 的自適應高度
        case selfSizing

        /// 給不需要設定 maximum
        static func percentage(minimum: Int) -> Height {
            .percentage(minimum: minimum, maximum: 100)
        }

        /// 給不需要設定 maximum
        static func value(minimum: CGFloat) -> Height {
            .value(minimum: minimum, maximum: UIDevice.current.height)
        }
    }

    public let backgroundColorAlpha: CGFloat
    public let contentBackgroundColor: UIColor

    /// 拿來計算滑動距離
    private var lastPanLocation: CGPoint = .zero
    /// 一但設置就會先以該值做處理, 但一樣會遵從 minimun, maximum 的規則
    private var manualUpdateHeight: CGFloat?

    let animateDuration = 0.25

    let type: `Type`

    /// 向下滑的容許值, 超過會直接收縮
    let pannedDistanceShouldCollapse: CGFloat
    /// 向上滑的容許值, 超過會直接展開
    let pannedDistanceShouldExpand: CGFloat
    /// 是否需要顯示  PullBar
    let isNeedPullBar: Bool
    /// 是否需要跟著鍵盤移動
    let isMoveByKeyboard: Bool

    public init(
        type: `Type`,
        backgroundColorAlpha: CGFloat,
        contentBackgroundColor: UIColor,
        pannedDistanceShouldCollapse: CGFloat,
        pannedDistanceShouldExpand: CGFloat,
        isNeedPullBar: Bool,
        isMoveByKeyboard: Bool)
    {
        self.type = type
        self.backgroundColorAlpha = backgroundColorAlpha
        self.contentBackgroundColor = contentBackgroundColor
        self.pannedDistanceShouldCollapse = pannedDistanceShouldCollapse
        self.pannedDistanceShouldExpand = pannedDistanceShouldExpand
        self.isNeedPullBar = isNeedPullBar
        self.isMoveByKeyboard = isMoveByKeyboard
    }
}

// MARK: - UI

extension PopoverPullableStrategy {
    public func addContentView(
        with view: UIView,
        at controller: UIViewController)
    {
        view.sr.round(
            at: [.layerMaxXMinYCorner, .layerMinXMinYCorner],
            radius: 16)

        controller.view.addSubview(view)
        view.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.greaterThanOrEqualTo(type.getMinimumHeight(with: controller))
            make.height.lessThanOrEqualTo(type.getMaximumHeight(with: controller))
            make.height
                .equalTo(type.getInitialHeight(with: controller))
                .priority(.low)
            make.top.equalTo(controller.view.snp.bottom)
        }
    }

    public func addPanGestureIfNeeded(
        at view: UIView,
        target: UIViewController,
        selector: Selector)
    {
        let pan = UIPanGestureRecognizer(target: target, action: selector)
        view.addGestureRecognizer(pan)
    }

    public func addPullBarIfNeeded(to target: UIView) -> UIView? {
        guard isNeedPullBar else { return nil }

        let view = UIView(frame: .zero)
        view.backgroundColor = .lightGray
        view.clipsToBounds = true
        view.layer.cornerRadius = 4

        target.addSubview(view)
        view.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(8)
            make.height.equalTo(6)
            make.width.equalTo(50)
        }

        return view
    }

    public func observeKeyboardMovementIfNeeded(
        target: UIViewController,

        onBeginEditing: Selector,
        onEndEditing: Selector)
    {
        guard isMoveByKeyboard else { return }
        
        NotificationCenter.default.addObserver(
            target,
            selector: onBeginEditing,
            name: UIResponder.keyboardWillShowNotification,
            object: target)
        NotificationCenter.default.addObserver(
            target,
            selector: onEndEditing,
            name: UIResponder.keyboardWillHideNotification,
            object: target)
    }

    public func manualUpdate(
        height: CGFloat,

        with view: UIView,
        at controller: UIViewController)
    {
        manualUpdateHeight = height

        view.snp.updateConstraints { make in
            make.height
                .equalTo(height)
                .priority(.low)
        }

        UIView.animate(
            withDuration: animateDuration,
            animations: { [weak controller] in
                controller?.view.layoutIfNeeded()
            })
    }

    /// 用 remake 動畫才會是整個滑動
    /// - Parameters:
    ///   - shouldFindClosestRangeHeight: pan end 在用, 讓畫面正常移動
    private func remakeContentViewConstraint(
        with view: UIView,
        at controller: UIViewController,
        isExpand: Bool,
        shouldFindClosestRangeHeight: Bool = false)
    {
        let minimum = type.getMinimumHeight(with: controller)
        let maximum = type.getMaximumHeight(with: controller)
        let initial = type.getInitialHeight(with: controller)

        view.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.lessThanOrEqualTo(maximum)
            make.height.greaterThanOrEqualTo(minimum)

            // 找最靠近的去算高度
            var closestRangeHeight = initial
            if shouldFindClosestRangeHeight {
                closestRangeHeight = abs(initial - view.frame.height) > abs(maximum - view.frame.height) ? maximum : initial
            }
            make.height
                .equalTo(closestRangeHeight)
                .priority(.low)

            if isExpand {
                make.bottom.equalToSuperview()
            }
            else {
                make.top.equalTo(controller.view.snp.bottom)
            }
        }
    }
}

// MARK: - Pan Gesture

extension PopoverPullableStrategy {
    public func handlePan(
        gesture: UIPanGestureRecognizer,
        with view: UIView,
        at controller: UIViewController,
        onClosed: () -> Void)
    {
        let translation = gesture.translation(in: view)

        switch gesture.state {
        case .changed:
            handlePanChanged(translation: translation, with: view, at: controller)
        case .ended:
            handlePanEnded(translation: translation, with: view, at: controller, onClosed: onClosed)
        default:
            break
        }
    }

    private func handlePanChanged(
        translation: CGPoint,
        with view: UIView,
        at controller: UIViewController)
    {
        switch type {
        case .freeform:
            if translation.y < 0 {
                // 整個畫面扣掉上方的保留高度
                let controllerSafeAreaHeight = type.getControllerSafeAreaMaxHeight(with: controller)

                // 算出距離後直接更新高度
                let distance = abs(translation.y) - abs(lastPanLocation.y)
                let changedHeight = min(controllerSafeAreaHeight, view.frame.height + distance)

                // 檢查有沒有超過最高高度
                if changedHeight > type.getMaximumHeight(with: controller) {
                    return
                }
                else {
                    view.snp.updateConstraints { make in
                        make.height.equalTo(changedHeight).priority(.low)
                    }

                    lastPanLocation = translation
                }
            }
            else {
                // 往下執行檢查下拉
                fallthrough
            }
        case .normal:
            // 只處理下拉
            guard translation.y > 0 else { return }
            view.snp.updateConstraints { make in
                make.bottom.equalToSuperview().offset(translation.y)
            }
        }
    }

    private func handlePanEnded(
        translation: CGPoint,
        with view: UIView,
        at controller: UIViewController,
        onClosed: () -> Void)
    {
        switch type {
        case .freeform:
            // 上拉超過容許值就直接全部展開
            if translation.y < 0 {
                if abs(translation.y) > pannedDistanceShouldExpand {
                    let updateHeight = type.getMaximumHeight(with: controller)
                    view.snp.updateConstraints { make in
                        make.height.equalTo(updateHeight).priority(.low)
                    }
                }
                // 回去初始點
                else {
                    remakeContentViewConstraint(with: view, at: controller, isExpand: true, shouldFindClosestRangeHeight: true)
                }
            }
            // 往下執行檢查下拉, 或跑動畫
            fallthrough

        case .normal:
            guard translation.y > 0 else { break }
            // 下拉超過容許值就要準備 dismiss
            if translation.y > pannedDistanceShouldCollapse {
                onClosed()
                return
            }
            // 回去初始點
            else {
                remakeContentViewConstraint(with: view, at: controller, isExpand: true, shouldFindClosestRangeHeight: true)
            }
        }

        UIView.animate(
            withDuration: animateDuration,
            animations: { [weak controller] in
                controller?.view.layoutIfNeeded()
            })
    }
}

// MARK: - Presentation

extension PopoverPullableStrategy {
    public func presentContent(
        with view: UIView,
        at controller: UIViewController,
        onPresented: (() -> Void)?)
    {
        remakeContentViewConstraint(with: view, at: controller, isExpand: true)

        UIView.animate(
            withDuration: animateDuration,
            animations: { [weak self, weak controller] in
                guard let self, let controller else { return }
                controller.view.backgroundColor = backgroundColorWithAlpha
                controller.view.layoutIfNeeded()
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
        remakeContentViewConstraint(with: view, at: controller, isExpand: false)

        UIView.animate(
            withDuration: animateDuration,
            animations: { [weak self, weak controller, weak view] in
                guard let self else { return }
                view?.alpha = 0.0
                controller?.view.backgroundColor = backgroundColor.withAlphaComponent(0.0)
                controller?.view.layoutIfNeeded()
            },
            completion: { [weak controller] _ in
                beforeClosed?()
                controller?.dismiss(animated: false) {
                    onClosed?()
                }
            })
    }
}
