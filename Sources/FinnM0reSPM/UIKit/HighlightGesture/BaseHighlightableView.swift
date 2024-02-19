import UIKit

public class BaseHighlightableView: SlideTabBar.Item {
    typealias UISettings = [Status: Setting]

    public enum Status {
        case normal
        case highlight
        case selected
        case disable
    }

    public struct Setting {
        var text: String?
        var textColor: UIColor?
        var backgroundColor: UIColor?
        var borderWidth: CGFloat?
        var borderColor: UIColor?
        var imageColor: UIColor?
    }

    private var settingDictionary: UISettings = [:]

    public var onTap: ((BaseHighlightableView) -> Void)?

    public var isHighlight = false {
        didSet {
            setupViewsFromStatus()
        }
    }

    public var isSelected = false {
        didSet {
            setupViewsFromStatus()
        }
    }

    public var isEnable = true {
        didSet {
            setupViewsFromStatus()
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commitInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commitInit()
    }

    public init(onTap: ((BaseHighlightableView) -> Void)?) {
        super.init(frame: .zero)
        self.onTap = onTap
        commitInit()
    }

    private func commitInit() {
        backgroundColor = .clear
    }

    public func setupGesture() {
        appendHighlightGesture(
            onHighlight: { [weak self] isHighlight in
                guard self?.isEnable == true else { return }
                self?.isHighlight = isHighlight
            },
            onClick: { [weak self] in
                guard
                    let self,
                    self.isEnable
                else { return }

                self.isHighlight = false
                self.onTap?(self)
            }
        )
    }

    /// Override this function to update UI
    public func setupViewsFromStatus() {}

    public func dispose() {
        removeAllSetting()
        onTap = nil
    }

    // MARK: - SlideTabBarItem

    override public func setSelected(_ isSelected: Bool, settings _: SlideTabBar.Settings) {
        isHighlight = false
        self.isSelected = isSelected
    }

    override public func setEnable(_ isEnable: Bool, settings _: SlideTabBar.Settings) {
        isHighlight = false
        self.isEnable = isEnable
    }

    override public func setTransformingColor(_: UIColor) {}

    deinit {
        dispose()
    }
}

// MARK: - Setting

public extension BaseHighlightableView {
    var currentStatus: Status {
        if isEnable == false {
            return .disable
        }

        if isHighlight {
            return .highlight
        }

        if isSelected {
            return .selected
        }

        return .normal
    }

    var currentSetting: Setting? {
        settingDictionary[currentStatus]
    }

    func addSetting(_ setting: Setting, at status: Status = .normal) {
        settingDictionary[status] = setting
        setupViewsFromStatus()
    }

    func getSetting(from status: Status) -> Setting? {
        if let setting = settingDictionary[status] {
            return setting
        }

        switch status {
        case .selected:
            return getSetting(from: .highlight)
        case .disable:
            return getSetting(from: .normal)
        default:
            return nil
        }
    }

    func setSettings(_ setting: [Status: Setting]) {
        settingDictionary = setting
        setupViewsFromStatus()
    }

    func removeAllSetting() {
        settingDictionary = [:]
    }
}
