import UIKit

/// 包裝 **PopoverContentViewController**
/// 個別 UI 行為相關邏輯應該在 **PopoverStrategy** 完成
/// 如果有新增 strategy 理應不需要更改這邊
public final class PopoverWrapperViewController: UIViewController {
    private let strategy: PopoverStrategy

    private lazy var backgroundView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tap)
        return view
    }()

    private lazy var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = strategy.contentBackgroundColor
        return view
    }()

    private var pullBar: UIView?

    private var onPresented: (() -> Void)?
    private var onClosed: (() -> Void)?

    private var contentController: UIViewController?

    private(set) var isPresented = false

    init(
        strategy: PopoverStrategy?,
        contentController: some PopoverPresentable,
        onPresented: (() -> Void)?,
        onClosed: (() -> Void)?)
    {
        self.contentController = contentController
        self.strategy = strategy ?? contentController.defaultStrategy
        self.onPresented = onPresented
        self.onClosed = onClosed
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        addChildController()

        strategy.observeKeyboardMovementIfNeeded(
            target: self,
            onBeginEditing: #selector(keyboardWillShow(notification:)),
            onEndEditing: #selector(keyboardWillHide(notification:)))
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 避免多重 popover 會多次觸發
        guard !isPresented else { return }
        presentContent()
    }

    override public func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        // 外部主動執行時
        if isPresented {
            // 讓動畫漂亮一點
            // 如果是 content 也是 wrapper, completion 應該執行在 content 身上
            if let contentWrapper = contentController?.presentedViewController as? PopoverWrapperViewController {
                contentWrapper.dismissContent(onClosed: completion)
                dismissContent()
            }
            else {
                dismissContent(onClosed: completion)
            }
        }
        else {
            super.dismiss(animated: flag, completion: completion)
        }
    }
}

// MARK: - UI

extension PopoverWrapperViewController {
    private func setupUI() {
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        pullBar = strategy.addPullBarIfNeeded(to: contentView)

        strategy.addContentView(with: contentView, at: self)
        strategy.addPanGestureIfNeeded(at: contentView, target: self, selector: #selector(handlePan(sender:)))
    }

    private func addChildController() {
        guard let contentController else { return }

        addChild(contentController)

        contentView.addSubview(contentController.view)
        contentController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentController.didMove(toParent: self)

        if let pullBar {
            contentView.bringSubviewToFront(pullBar)
        }
    }

    private func clear() {
        setEditing(false, animated: true)

        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }

    public func updateContentHeight(_ value: CGFloat) {
        guard value != contentView.frame.height else { return }
        strategy.manualUpdate(height: value, with: contentView, at: self)
    }
}

// MARK: - Presentation

extension PopoverWrapperViewController {
    private func presentContent() {
        strategy.presentContent(
            with: contentView,
            at: self,
            onPresented: { [weak self] in
                guard self?.isPresented == false else { return }
                self?.onPresented?()
                self?.isPresented = true
            })
    }

    func dismissContent(onClosed: (() -> Void)? = nil) {
        strategy.dismissContent(
            with: contentView,
            at: self,
            beforeClosed: { [weak self] in
                self?.isPresented = false
            },
            onClosed: { [weak self] in
                self?.clear()

                // function 帶進來的是主動執行 dismiss 的 completion
                onClosed?()
                // **PopoverPresentable** present 的 onClose
                self?.onClosed?()
            })
    }
}

// MARK: - Gestures

extension PopoverWrapperViewController {
    @objc
    private func handleTap(_: UITapGestureRecognizer) {
        guard strategy.dismissOnTappedBackground else { return }
        dismissContent()
    }

    @objc
    private func handlePan(sender: UIPanGestureRecognizer) {
        strategy.handlePan(
            gesture: sender,
            with: contentView,
            at: self,
            onClosed: { [weak self] in
                self?.dismissContent()
            })
    }
}

// MARK: - Keyboard Movement

extension PopoverWrapperViewController {
    @objc
    private func keyboardWillShow(notification: NSNotification) {
        // 確保收到的 object 是自己才移動
        guard
            let popover = notification.object as? Self,
            popover === self,
            view.frame.origin.y == 0 else { return }
        let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
        view.frame.origin.y -= keyboardSize.height
    }

    @objc
    private func keyboardWillHide(notification: NSNotification) {
        // 確保收到的 object 是自己才移動
        guard
            let popover = notification.object as? Self,
            popover === self,
            view.frame.origin.y != 0 else { return }
        view.frame.origin.y = 0
    }
}
