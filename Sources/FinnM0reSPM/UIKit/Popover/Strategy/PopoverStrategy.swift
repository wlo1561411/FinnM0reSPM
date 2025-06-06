import SnapKit
import UIKit

/// **PopoverStrategy** 為抽象介面
/// 用來處理不同 strategy 裡的 UI 行為
public protocol PopoverStrategy {
    /// 整體背景色
    var backgroundColor: UIColor { get }
    /// 整體背景色透明度
    var backgroundColorAlpha: CGFloat { get }
    /// 點擊背景能不能執行 dismiss
    var dismissOnTappedBackground: Bool { get }
    /// contentView 背景色
    var contentBackgroundColor: UIColor { get }

    /// 展現 **PopoverWrapperViewController**
    func presentContent(
        with view: UIView,
        at controller: UIViewController,
        onPresented: (() -> Void)?)
    /// 關閉 **PopoverWrapperViewController**
    func dismissContent(
        with view: UIView,
        at controller: UIViewController,
        beforeClosed: (() -> Void)?,
        onClosed: (() -> Void)?)

    /// 新增放置 **PopoverContentViewController** 的 view
    func addContentView(
        with view: UIView,
        at controller: UIViewController)

    /// 新增 PanGesture, 有需要再實作
    func addPanGestureIfNeeded(
        at view: UIView,
        target: UIViewController,
        selector: Selector)

    /// 新增 pull bar, 有需要再實作
    func addPullBarIfNeeded(to target: UIView) -> UIView?

    /// 處理 pan 的行為, 有需要再實作
    func handlePan(
        gesture: UIPanGestureRecognizer,
        with view: UIView,
        at controller: UIViewController,
        onClosed: () -> Void)

    /// 監聽 keyboard 的移動, 有需要再實作
    func observeKeyboardMovementIfNeeded(
        target: UIViewController,
        onBeginEditing: Selector,
        onEndEditing: Selector)

    /// 手動更新高度, 有需要再實作
    func manualUpdate(
        height: CGFloat,
        with view: UIView,
        at controller: UIViewController)
}

// MARK: - Default Implement

extension PopoverStrategy {
    public var backgroundColor: UIColor {
        .black
    }

    public var backgroundColorWithAlpha: UIColor {
        backgroundColor.withAlphaComponent(backgroundColorAlpha)
    }

    public var dismissOnTappedBackground: Bool {
        true
    }

    public func addPanGestureIfNeeded(
        at _: UIView,
        target _: UIViewController,
        selector _: Selector) { }

    public func addPullBarIfNeeded(to _: UIView) -> UIView? { nil }

    public func handlePan(
        gesture _: UIPanGestureRecognizer,
        with _: UIView,
        at _: UIViewController,
        onClosed _: () -> Void) { }

    public func observeKeyboardMovementIfNeeded(
        target _: UIViewController,
        onBeginEditing _: Selector,
        onEndEditing _: Selector) { }

    /// 手動更新高度, 有需要再實作
    public func manualUpdate(
        height _: CGFloat,
        with _: UIView,
        at _: UIViewController) { }
}
