import UIKit

class BaseHighlightableView: UIView {
  typealias UISettings = [Status: Setting]

  enum Status {
    case normal
    case highlight
    case selected
    case disable
  }

  struct Setting {
    var text: String?
    var textColor: UIColor?
    var backgroundColor: UIColor?
    var borderWidth: CGFloat?
    var borderColor: UIColor?
    var imageColor: UIColor?
  }

  private var settingDictionary: UISettings = [:]

  var onTap: ((BaseHighlightableView) -> Void)?

  var isHighlight = false {
    didSet {
      setupViewsFromStatus()
    }
  }

  var isSelected = false {
    didSet {
      setupViewsFromStatus()
    }
  }

  var isEnable = true {
    didSet {
      setupViewsFromStatus()
    }
  }

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

  override init(frame: CGRect) {
    super.init(frame: frame)
    commitInit()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commitInit()
  }

  init(onTap: ((BaseHighlightableView) -> Void)?) {
    super.init(frame: .zero)
    self.onTap = onTap
    commitInit()
  }

  private func commitInit() {
    backgroundColor = .clear
  }

  func setupGesture() {
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
      })
  }

  func addSetting(_ setting: Setting, at status: Status = .normal) {
    settingDictionary[status] = setting
    setupViewsFromStatus()
  }

  func setupViewsFromStatus() { }

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

  func dispose() {
    removeAllSetting()
    onTap = nil
  }

  deinit {
    dispose()
  }
}

extension BaseHighlightableView: SlideTabBarItem {
  func setSelected(_ isSelected: Bool, settings _: Settings) {
    isHighlight = false
    self.isSelected = isSelected
  }

  func setEnable(_ isEnable: Bool, settings _: Settings) {
    isHighlight = false
    self.isEnable = isEnable
  }

  func setTransformingColor(_: UIColor) { }
}
