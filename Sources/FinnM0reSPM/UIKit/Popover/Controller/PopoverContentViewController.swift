import UIKit

/// 用來處理 controller 如果沒辦法繼承 **PopoverContentViewController**
/// 遵從這個 protocol, 但原生的 present, dismiss 還是要寫上去
public protocol PopoverContentViewControllerProtocol: UIViewController {
    func shouldPresentFromWrapper(
        _ controller: UIViewController,
        animated: Bool,
        completion: (() -> Void)?)
        -> Bool

    func shouldDismissFromWrapper(
        animated: Bool,
        completion: (() -> Void)?)
        -> Bool
}

// MARK: - Default Implement

extension PopoverContentViewControllerProtocol {
    public func shouldPresentFromWrapper(
        _ controller: UIViewController,
        animated: Bool,
        completion: (() -> Void)?)
        -> Bool
    {
        if let wrapper = findPopoverWrapper() {
            wrapper.present(controller, animated: animated, completion: completion)
            return true
        }
        return false
    }

    public func shouldDismissFromWrapper(
        animated _: Bool,
        completion: (() -> Void)?)
        -> Bool
    {
        if let wrapper = findPopoverWrapper() {
            wrapper.dismissContent(onClosed: completion)
            return true
        }
        return false
    }

    private func findPopoverWrapper() -> PopoverWrapperViewController? {
        // 如果 parent 是 PopoverContentViewController
        // 代表要往上再找到 wrapper
        if parent is PopoverContentViewController {
            // 預防一直找不到會卡畫面
            var count = 3
            var wrapper: PopoverWrapperViewController?
            var current: UIViewController? = self

            while count > 0, wrapper == nil {
                if let found = current?.parent as? PopoverWrapperViewController {
                    wrapper = found
                }
                current = current?.parent
                count -= 1
            }

            return wrapper
        }
        // 一般單層結構
        else if let parent = parent as? PopoverWrapperViewController {
            return parent
        }

        return nil
    }
}

/// Popover 容器內的 child class
/// 需要覆寫 present, dismiss, 讓 controller 的堆疊是正常的也方便使用
public class PopoverContentViewController: UIViewController, PopoverContentViewControllerProtocol {
    override public func present(
        _ viewControllerToPresent: UIViewController,
        animated flag: Bool,
        completion: (() -> Void)? = nil)
    {
        guard !shouldPresentFromWrapper(
            viewControllerToPresent,
            animated: flag,
            completion: completion)
        else { return }

        super.present(
            viewControllerToPresent,
            animated: flag,
            completion: completion)
    }

    override public func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        guard !shouldDismissFromWrapper(
            animated: flag,
            completion: completion)
        else { return }

        super.dismiss(
            animated: flag,
            completion: completion)
    }
}
