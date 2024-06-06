import UIKit

/// 如果有需要 popover 功能
/// 直接遵從 **PopoverPresentable**
public protocol PopoverPresentable: PopoverContentViewControllerProtocol {
    associatedtype Parameters
    associatedtype ChangedValues

    /// 預設的 popover 策略
    var defaultStrategy: PopoverStrategy { get }

    /// - Parameters:
    ///   - parameters: controller 的 viewModel (或是任意需要帶的值)
    ///   - strategy: nil 的話會帶 defaultStrategy
    ///   - targetViewController: 從哪個 controller present
    ///   - onPresented: 第一次顯示完成後會觸發
    ///   - onClosed: 關閉時會觸發
    ///   - onValueChanged: controller 的 action callback, 要擴展可以把 ChangedValues 寫成 tuple
    func present(
        parameters: Parameters?,
        with strategy: PopoverStrategy?,
        at targetViewController: UIViewController,
        onPresented: (() -> Void)?,
        onClosed: (() -> Void)?,
        onValueChanged: ((ChangedValues) -> Void)?)
}

extension PopoverPresentable {
    /// 執行 present, 外部不應該執行這個
    public func performPresentation(
        with strategy: PopoverStrategy?,
        at targetViewController: UIViewController,
        onPresented: (() -> Void)?,
        onClosed: (() -> Void)?)
    {
        targetViewController.present(
            PopoverWrapperViewController(
                strategy: strategy,
                contentController: self,
                onPresented: onPresented,
                onClosed: onClosed),
            animated: false)
    }

    /// 主動更新高度, 但一樣會遵從 minimun, maximum 的規則
    /// - Parameters:
    ///   - height: 預設是 0, 會根據 content 高度更新
    public func manualUpdate(height: CGFloat = 0) {
        guard let wrapper = parent as? PopoverWrapperViewController else { return }
        wrapper.updateContentHeight(height)
    }
}

extension UIViewController {
    /// 用來方便使用
    /// 實際上在做什麼可以去實作 **PopoverPresentable** 的 controller 看
    /// - Parameters:
    ///   - parameters: controller 的 viewModel (或是任意需要帶的值)
    ///   - strategy: nil 的話會帶 defaultStrategy
    ///   - onPresented: 第一次顯示完成後會觸發
    ///   - onClosed: 關閉時會觸發
    ///   - onValueChanged: controller 的 action callback, 要擴展可以把 ChangedValues 寫成 tuple
    public func present<Popover: PopoverPresentable>(
        _ controller: Popover,
        parameters: Popover.Parameters? = nil,
        with strategy: PopoverStrategy? = nil,
        onPresented: (() -> Void)? = nil,
        onClosed: (() -> Void)? = nil,
        onValueChanged: ((Popover.ChangedValues) -> Void)? = nil)
    {
        controller.present(
            parameters: parameters,
            with: strategy,
            at: self,
            onPresented: onPresented,
            onClosed: onClosed,
            onValueChanged: onValueChanged)
    }
}
