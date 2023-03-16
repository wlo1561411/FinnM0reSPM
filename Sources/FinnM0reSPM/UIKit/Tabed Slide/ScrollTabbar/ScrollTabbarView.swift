import UIKit

protocol ScrollTabbarDelegate: AnyObject {
  func didSelect(_ sender: ScrollTabbarView, at index: Int)
}

protocol ScrollTabbarDataSource: AnyObject {
  func numberOfItems(_ sender: ScrollTabbarView) -> Int
  func itemView(_ sender: ScrollTabbarView, at index: Int) -> ScrollTabbarView.Item
}

// TODO: It could be better
class ScrollTabbarView: UIView {
  // TODO: Small width will have problem
  enum Distribution: Equatable {
    /// Auto, if size small than bonus, the adjust width to full
    case auto
    /// Just follow the content
    case content
    /// Just fill the bonus, it will "not" adjust content
    case full
    /// Will set custom width to each item
    case width(CGFloat)
  }

  enum TrackerStyle {
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
    scroll.showsHorizontalScrollIndicator = false
    scroll.bounces = false
    scroll.translatesAutoresizingMaskIntoConstraints = false
    return scroll
  }()

  private lazy var contentView: UIView = {
    let content = UIView()
    content.translatesAutoresizingMaskIntoConstraints = false
    return content
  }()

  private lazy var itemsStackView: UIStackView = {
    let stack = UIStackView()
    stack.alignment = .fill
    stack.axis = .horizontal
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }()

  private lazy var itemStackViewCenterXConst: NSLayoutConstraint = itemsStackView.centerXAnchor
    .constraint(equalTo: self.centerXAnchor)

  private lazy var bottomLineView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  private var distribution: Distribution = .auto

  private var trackerStyle: TrackerStyle = .view

  private var items: [Item] = []

  private var _selectedIndex: Int = -1 {
    willSet {
      switchTo(newValue)
    }
  }

  var selectedIndex: Int {
    get {
      _selectedIndex
    }
    set {
      guard _selectedIndex != newValue, itemsCount > 0 else { return }
      _selectedIndex = newValue
    }
  }

  weak var delegate: ScrollTabbarDelegate?
  weak var dataSource: ScrollTabbarDataSource?

  var numberOfItems: Int {
    dataSource?.numberOfItems(self) ?? 0
  }

  var bottomLineHeight: CGFloat = 1
  var bottomLineColor: UIColor = .clear

  var itemModel = Item.Model()
  var itemSpace: CGFloat = 10

  var itemsCount: Int {
    items.count
  }

  var trackerHeight: CGFloat = 2

  var trackerColor: UIColor = .blue {
    didSet {
      trackerView.backgroundColor = trackerColor
    }
  }

  // MARK: Initialize

  init() {
    super.init(frame: .zero)
    self.commitInit()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.commitInit()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.commitInit()
  }

  private func commitInit() {
    addSubview(scrollView)
    NSLayoutConstraint.activate(
      [
        scrollView.topAnchor.constraint(equalTo: self.topAnchor),
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        scrollView.leftAnchor.constraint(equalTo: self.leftAnchor),
        scrollView.rightAnchor.constraint(equalTo: self.rightAnchor)
      ])

    scrollView.addSubview(contentView)
    NSLayoutConstraint.activate(
      [
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        contentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
        contentView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
        contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
      ])

    contentView.addSubview(itemsStackView)
    NSLayoutConstraint.activate(
      [
        itemsStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
        itemsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        itemsStackView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
        itemsStackView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
      ])

    scrollView.addSubview(trackerView)
  }

  func dataSourceSetup(
    distribution: Distribution = .auto,
    trackerStyle: TrackerStyle = .view,
    padding: UIEdgeInsets? = nil)
  {
    if let padding {
      itemsStackView.isLayoutMarginsRelativeArrangement = true
      itemsStackView.layoutMargins = padding
    }

    self.distribution = distribution
    self.trackerStyle = trackerStyle

    guard numberOfItems > 0 else { return }

    self.buildItemViews(titles: [])
    self.buildLine()
  }

  func defaultSetup(
    titles: [String],
    distribution: Distribution = .auto,
    trackerStyle: TrackerStyle = .view,
    padding: UIEdgeInsets? = nil)
  {
    guard !titles.isEmpty else { return }

    if let padding {
      itemsStackView.isLayoutMarginsRelativeArrangement = true
      itemsStackView.layoutMargins = padding
    }

    self.distribution = distribution
    self.trackerStyle = trackerStyle

    self.buildItemViews(titles: titles)
    self.buildLine()
  }

  /// Datasource setup only
  func reload() {
    guard dataSource != nil else { return }
    buildItemViews(titles: [])
  }
}

// MARK: UI

extension ScrollTabbarView {
  private func buildItemViews(titles: [String]) {
    /// For reset
    if items.count > 0 {
      reset()
    }

    let fixedCount = titles.isEmpty ? numberOfItems : titles.count

    guard fixedCount > 0 else { return }

    items = (0..<fixedCount).map { index in
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
        self.delegate?.didSelect(self, at: item.tag)
      }

      itemsStackView.addArrangedSubview(item)

      return item
    }

    switch distribution {
    case .auto:
      let itemsEstimatedWidth = items
        .map { $0.contentWidth + itemSpace * 2 }

      let sum = itemsEstimatedWidth.reduce(0, +)
      let _itemCount = CGFloat(itemsCount)
      let calc = (
        bounds.width - sum - itemsStackView.layoutMargins.left - itemsStackView.layoutMargins
          .right - (itemSpace * (_itemCount - 1))) / _itemCount
      let extraSpace: CGFloat = sum < bounds.width ? calc : 0

      itemsStackView.arrangedSubviews.enumerated()
        .forEach { index, value in
          value.widthAnchor.constraint(equalToConstant: itemsEstimatedWidth[index] + extraSpace).isActive = true
        }
      updateStackView(.auto)

    case .content:
      let itemsEstimatedWidth = items
        .map { $0.contentWidth + itemSpace * 2 }

      itemsStackView.arrangedSubviews.enumerated()
        .forEach { index, value in
          value.widthAnchor.constraint(equalToConstant: itemsEstimatedWidth[index]).isActive = true
        }

      scrollView.contentInset = .init(top: 0, left: 0, bottom: 0, right: -itemSpace)
      itemsStackView.addArrangedSubview(.init())

      updateStackView(.content)

    case .full:
      updateStackView(.full)

    case .width(let width):
      itemsStackView.arrangedSubviews.forEach { $0.widthAnchor.constraint(equalToConstant: width).isActive = true }

      scrollView.contentInset = .init(top: 0, left: 0, bottom: 0, right: -itemSpace)
      itemsStackView.addArrangedSubview(.init())

      updateStackView(.width(width))
    }

    scrollView.layoutIfNeeded()

    selectedIndex = 0
  }

  private func updateStackView(_ distribution: Distribution) {
    switch distribution {
    case .full:
      itemsStackView.distribution = .fillEqually
      itemStackViewCenterXConst.isActive = true

    case .auto,
         .content,
         .width:
      itemsStackView.distribution = .equalSpacing
      itemStackViewCenterXConst.isActive = false
    }

    itemsStackView.spacing = itemSpace
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

  private func tabbarItem(at index: Int) -> Item? {
    if let item = itemsStackView.arrangedSubviews[index] as? Item {
      return item
    }
    return nil
  }

  private func trackerPlacement(with item: Item) -> (x: CGFloat, width: CGFloat) {
    switch trackerStyle {
    case .view:
      let converted = scrollView.convert(item.bounds, from: item)
      return (converted.origin.x, item.frame.width)
    case .content:
      let converted = scrollView.convert(item.contentView.bounds, from: item.contentView)
      return (converted.origin.x, item.contentWidth)
    }
  }

  func reset() {
    selectedIndex = -1

    trackerView.isHidden = true

    itemsStackView.arrangedSubviews.forEach {
      if let item = $0 as? ScrollTabbarView.Item {
        item.prepareDeinit()
      }
      itemsStackView.removeArrangedSubview($0)
      $0.removeFromSuperview()
    }

    items.removeAll()
  }
}

// MARK: Animate

extension ScrollTabbarView {
  private func switchTo(_ selectedIndex: Int) {
    guard itemsCount > 0 else { return }

    let preIndex = self.selectedIndex
    let toIndex = selectedIndex

    /// For Reset
    if preIndex >= 0 {
      tabbarItem(at: preIndex)?.setSelected(false)
    }

    if
      toIndex >= 0, toIndex < itemsCount,
      let toItem = tabbarItem(at: toIndex)
    {
      tabbarItem(at: toIndex)?.setSelected(true)

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

  func switching(from fromIndex: Int, to toIndex: Int, by percentage: CGFloat) {
    guard let fromItem = tabbarItem(at: fromIndex) else { return }

    let fromPlacement = trackerPlacement(with: fromItem)
    let fromX = fromPlacement.x
    let fromItemWidth = fromPlacement.width

    var toX: CGFloat = 0
    var toItemWidth: CGFloat = 0

    if
      toIndex >= 0, toIndex < itemsCount,
      let toItem = tabbarItem(at: toIndex)
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
