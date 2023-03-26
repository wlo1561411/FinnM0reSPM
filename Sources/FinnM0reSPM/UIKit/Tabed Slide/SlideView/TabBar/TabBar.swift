import SnapKit
import UIKit

extension SlideView {
  public class TabBar: UIView {
    public enum Distribution: Equatable {
      /// Just follow the content
      case content
      /// Just fill the bonus, it will "not" adjust content
      case full
      /// Will set custom width to each item
      case width(CGFloat)
    }

    public enum TrackerStyle {
      case content
      case view
    }

    private(set) lazy var trackerView: UIView = {
      let view = UIView()
      view.isHidden = true
      view.backgroundColor = trackerColor
      view.sr.round(2)
      return view
    }()

    private lazy var scrollView: UIScrollView = {
      let scroll = UIScrollView()
      scroll.bounces = false
      return scroll
    }()

    private lazy var contentView = UIView()

    private lazy var itemsStackView = UIStackView()

    private lazy var bottomLineView = UIView()

    private var fullConstraint: Constraint?

    private var items: [Item] = []

    private var _selectedIndex: Int = -1 {
      willSet {
        switchTo(newValue)
      }
    }

    public var selectedIndex: Int {
      get {
        _selectedIndex
      }
      set {
        guard _selectedIndex != newValue, itemsCount > 0 else { return }
        _selectedIndex = newValue
      }
    }

    public weak var delegate: SlideTabBarDelegate?
    public weak var dataSource: SlideTabBarDataSource?

    public var numberOfItems: Int {
      dataSource?.numberOfItems(self) ?? 0
    }

    public var bottomLineHeight: CGFloat = 1
    public var bottomLineColor: UIColor = .clear

    public var itemModel = Item.Model()
    public var itemSpacing: CGFloat = 10

    public var itemsCount: Int {
      items.count
    }

    public var trackerHeight: CGFloat = 2

    public var trackerColor: UIColor = .blue {
      didSet {
        trackerView.backgroundColor = trackerColor
      }
    }
    
    public var distribution: Distribution = .content

    public var trackerStyle: TrackerStyle = .view

    // MARK: Initialize

    public init() {
      super.init(frame: .zero)
      self.commitInit()
    }

    override public init(frame: CGRect) {
      super.init(frame: frame)
      self.commitInit()
    }

    public required init?(coder: NSCoder) {
      super.init(coder: coder)
      self.commitInit()
    }

    private func commitInit() {
      addSubview(scrollView)
      scrollView.snp.makeConstraints { make in
        make.edges.equalToSuperview()
      }

      scrollView.addSubview(contentView)
      contentView.snp.makeConstraints { make in
        make.height.edges.equalToSuperview()
      }

      contentView.addSubview(itemsStackView)
      itemsStackView.snp.makeConstraints { make in
        make.edges.equalToSuperview()
        fullConstraint = make.width.equalTo(self.snp.width).constraint
      }

      fullConstraint?.deactivate()

      scrollView.addSubview(trackerView)
    }

    /// Datasource setup only
    public func reload() {
      guard dataSource != nil else { return }
      buildItemViews(titles: [])
      buildLine()
    }
  }
}

// MARK: UI

extension SlideView.TabBar {
  private func buildItemViews(titles: [String]) {
    /// For reset
    if items.count > 0 {
      reset()
    }

    let fixedCount = titles.isEmpty ? numberOfItems : titles.count

    guard fixedCount > 0 else { return }

    items = (0..<fixedCount)
      .map { index in
        let item = dataSource?.itemView(self, at: index) ?? Item()
        item.model = itemModel
        item.tag = index
        item.setSelected(false)

        if !titles.isEmpty {
          item.titleLabel.text = titles[index]
        }

        item.tapAction = { [weak self] in
          guard let self else { return }
          self.selectedIndex = item.tag
          self.delegate?.didSelected?(self, at: item.tag)
        }

        itemsStackView.addArrangedSubview(item)

        return item
      }

    itemsStackView.spacing = itemSpacing
    scrollView.contentInset = .init(top: 0, left: itemSpacing / 4, bottom: 0, right: itemSpacing / 4)

    switch distribution {
    case .width(let width):
      itemsStackView
        .arrangedSubviews
        .first?
        .snp
        .makeConstraints { make in
          make.width.equalTo(width)
        }

      itemsStackView.distribution = .fillEqually
      fullConstraint?.deactivate()

    case .full:
      itemsStackView.distribution = .fillEqually
      fullConstraint?.activate()

    default:
      itemsStackView.distribution = .equalSpacing
      fullConstraint?.deactivate()
    }

    selectedIndex = 0
  }

  private func updateItemTitleColor(
    from fromItem: Item?,
    to toItem: Item? = nil,
    by percentage: CGFloat)
  {
    toItem?.titleLabel.textColor = SlideCalculator.color(by: 1 - percentage, between: itemModel.color, itemModel.selectedColor)
    fromItem?.titleLabel.textColor = SlideCalculator.color(by: percentage, between: itemModel.color, itemModel.selectedColor)
  }

  private func buildLine() {
    guard bottomLineColor != .clear, bottomLineHeight > 0, bottomLineView.superview == nil else { return }

    bottomLineView.backgroundColor = bottomLineColor

    scrollView.insertSubview(bottomLineView, belowSubview: trackerView)
    bottomLineView.snp.makeConstraints { make in
      make.height.equalTo(bottomLineHeight / 2)
      make.left.equalToSuperview().offset(itemsStackView.layoutMargins.left)
      make.right.equalToSuperview().offset(-itemsStackView.layoutMargins.right)
      make.centerY.equalTo(trackerView.snp.centerY)
    }
  }

  private func tabBarItem(at index: Int) -> Item? {
    if let item = itemsStackView.arrangedSubviews[index] as? Item {
      return item
    }
    return nil
  }

  private func trackerPlacement(with item: Item) -> (x: CGFloat, width: CGFloat) {
    let converted = scrollView.convert(item.bounds, from: item)

    switch trackerStyle {
    case .view:
      return (converted.origin.x - itemSpacing / 2, item.frame.width + itemSpacing)
    case .content:
      return (converted.origin.x, item.frame.width)
    }
  }

  private func reset() {
    selectedIndex = -1

    trackerView.isHidden = true

    itemsStackView.arrangedSubviews.forEach {
      if let item = $0 as? SlideView.TabBar.Item {
        item.prepareReinit()
      }
      itemsStackView.removeArrangedSubview($0)
      $0.removeFromSuperview()
    }

    items.removeAll()
  }
}

// MARK: Animate

extension SlideView.TabBar {
  private func switchTo(_ selectedIndex: Int) {
    guard itemsCount > 0 else { return }

    let preIndex = self.selectedIndex
    let toIndex = selectedIndex

    /// For Reset
    if preIndex >= 0 {
      tabBarItem(at: preIndex)?.setSelected(false)
    }

    if
      toIndex >= 0, toIndex < itemsCount,
      let toItem = tabBarItem(at: toIndex)
    {
      tabBarItem(at: toIndex)?.setSelected(true)

      DispatchQueue.main.async {
        /// Calculate scrollView center point with toItem
        let calced = CGRect(
          x: toItem.center.x - self.scrollView.bounds.width / 2,
          y: toItem.frame.origin.y,
          width: self.scrollView.bounds.width,
          height: self.scrollView.bounds.height)

        self.scrollView.scrollRectToVisible(calced, animated: calced.origin.x > 0 ? true : false)

        /// Configure tracker
        guard self.trackerHeight > 0 else { return }

        let trackPlacement = self.trackerPlacement(with: toItem)
        let trackFrame = CGRect(
          x: trackPlacement.x,
          y: self.bounds.height - self.trackerHeight,
          width: trackPlacement.width,
          height: self.trackerHeight)

        if self.trackerView.isHidden {
          self.trackerView.isHidden = false
          self.trackerView.frame = trackFrame
        }
        else {
          UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseIn,
            animations: {
              self.trackerView.frame = trackFrame
            },
            completion: nil)
        }
      }
    }
  }

  private func switching(from fromIndex: Int, to toIndex: Int, by percentage: CGFloat) {
    guard let fromItem = tabBarItem(at: fromIndex) else { return }

    let fromPlacement = trackerPlacement(with: fromItem)
    let fromX = fromPlacement.x
    let fromItemWidth = fromPlacement.width

    var toX: CGFloat = 0
    var toItemWidth: CGFloat = 0

    if
      toIndex >= 0, toIndex < itemsCount,
      let toItem = tabBarItem(at: toIndex)
    {
      let toPlacement = trackerPlacement(with: toItem)

      toItemWidth = toPlacement.width
      toX = toPlacement.x

      updateItemTitleColor(from: fromItem, to: toItem, by: percentage)
    }
    else {
      toItemWidth = fromItemWidth
      toX = toIndex > fromIndex ? fromX + fromItemWidth : fromX - fromItemWidth

      updateItemTitleColor(from: fromItem, by: percentage)
    }

    let calcedWidth: CGFloat = toItemWidth * percentage + fromItemWidth * (1 - percentage)
    let calcedX: CGFloat = fromX + (toX - fromX) * percentage

    trackerView.frame = CGRect(
      x: calcedX,
      y: trackerView.frame.origin.y,
      width: calcedWidth,
      height: trackerHeight)
  }
}
