import UIKit

/// 如果有需要 popover 功能
/// 直接遵從 **PopoverPresentable**
public protocol PopoverPresentable: PopoverContentViewControllerProtocol {
    /// 預設的 popover 策略
    var defaultStrategy: PopoverStrategy { get }

    /// - Parameters:
    ///   - strategy: nil 的話會帶 defaultStrategy
    ///   - targetViewController: 從哪個 controller present
    ///   - onPresented: 第一次顯示完成後會觸發
    ///   - onClosed: 關閉時會觸發
    func present(
        with strategy: PopoverStrategy?,
        at targetViewController: UIViewController,
        onPresented: (() -> Void)?,
        onClosed: (() -> Void)?)
}

extension PopoverPresentable {
    public func present(
        with strategy: PopoverStrategy?,
        at targetViewController: UIViewController,
        onPresented: (() -> Void)?,
        onClosed: (() -> Void)?)
    {
        targetViewController.present(
            PopoverWrapperViewController(
                strategy: strategy ?? defaultStrategy,
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
    ///   - strategy: nil 的話會帶 defaultStrategy
    ///   - onPresented: 第一次顯示完成後會觸發
    ///   - onClosed: 關閉時會觸發
    public func present(
        _ controller: some PopoverPresentable,
        with strategy: PopoverStrategy? = nil,
        onPresented: (() -> Void)? = nil,
        onClosed: (() -> Void)? = nil)
    {
        controller.present(
            with: strategy,
            at: self,
            onPresented: onPresented,
            onClosed: onClosed)
    }
}

#if swift(>=5.9)
    import Combine

    private class PopoverPresentableDemo: UIViewController, PopoverPresentable {
        private var cancellables: Set<AnyCancellable> = []

        var defaultStrategy: PopoverStrategy { .alert(size: .minimum(.init(width: 200, height: 200))) }

        override func viewDidLoad() {
            UIButton().sr
                .title("Alert")
                .titleColor(.white)
                .backgroundColor(.gray)
                .add(to: view)
                .makeConstraints { make in
                    make.size.equalTo(50)
                    make.center.equalToSuperview()
                }
                .onTap(store: &cancellables) { [weak self] _ in
                    self?.present(AlertPopoverDemo())
                }

            UIButton().sr
                .title("Pullable")
                .titleColor(.white)
                .backgroundColor(.gray)
                .add(to: view)
                .makeConstraints { make in
                    make.size.equalTo(100)
                    make.centerX.equalToSuperview()
                    make.centerY.equalToSuperview().offset(150)
                }
                .onTap(store: &cancellables) { [weak self] _ in
                    self?.present(PullablePopoverDemo())
                }
        }
    }

    private class PullablePopoverDemo: PopoverContentViewController, PopoverPresentable {
        var defaultStrategy: PopoverStrategy { .pullable(.freeform(.percentage(minimum: 20))) }

        override func viewDidLoad() {
            super.viewDidLoad()

            view.backgroundColor = .systemPink

            UITextView().sr
                .text("Hello, World!")
                .textAlignment(.center)
                .textColor(.white)
                .backgroundColor(.clear)
                .round(10)
                .add(to: view)
                .makeConstraints { make in
//                    make.height.equalTo(500)
                    make.top.equalToSuperview().inset(20)
                    make.bottom.leading.trailing.equalToSuperview()
                }
        }
    }

    private class AlertPopoverDemo: PopoverContentViewController, PopoverPresentable {
        var defaultStrategy: PopoverStrategy { .alert(size: .minimum(.init(width: 200, height: 200))) }

        override func viewDidLoad() {
            super.viewDidLoad()

            view.backgroundColor = .systemPink

            UITextView().sr
                .text("Hello, World!")
                .textAlignment(.center)
                .textColor(.white)
                .backgroundColor(.clear)
                .round(10)
                .add(to: view)
                .makeConstraints { make in
                    make.size.equalTo(500)
                    make.edges.equalToSuperview()
                }
        }
    }

    @available(iOS 17.0, *)
    #Preview {
        PopoverPresentableDemo()
    }
#endif
