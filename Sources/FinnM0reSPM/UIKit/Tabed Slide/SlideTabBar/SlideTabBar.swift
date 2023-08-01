import SnapKit
import UIKit

public class SlideTabBar: UIView {
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
    scroll.showsHorizontalScrollIndicator = false
    return scroll
  }()

  private lazy var contentView = UIView()
  private lazy var itemsStackView = UIStackView()
  private lazy var bottomLineView = UIView()

  private var fullConstraint: Constraint?

  private var items: [Item] = []
  private var itemsCount: Int {
    items.count
  }

  private var getNumberOfItems: (() -> Int)?
  private var itemFactory: ((Int) -> SlideTabBar.Item)?
  private var shouldAllowItemSelect: ((Int) -> Bool)?
  private var onItemSelected: ((Int) -> Void)?

  private var didFinishLayout = false
  private var isReloading = false

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
      guard
        _selectedIndex != newValue,
        itemsCount > 0,
        shouldAllowItemSelect?(newValue) ?? true
      else { return }

      _selectedIndex = newValue

      guard _selectedIndex >= 0 else { return }
      onItemSelected?(_selectedIndex)
      delegate?.didSelected?(self, at: _selectedIndex)
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

  public var trackerHeight: CGFloat = 2
  public var trackerColor: UIColor = .blue {
    didSet {
      trackerView.backgroundColor = trackerColor
    }
  }

  public var contentInset: UIEdgeInsets = .zero {
    didSet {
      scrollView.contentInset = contentInset
    }
  }

  public var alignment: UIStackView.Alignment = .fill {
    didSet {
      itemsStackView.alignment = alignment
    }
  }

  public var distribution: SlideTabBarDistribution = .contentLeading
  public var trackerMode: SlideTabBarTrackerMode = .byView

  // MARK: Initialize

  public init() {
    super.init(frame: .zero)
    commitInit()
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    commitInit()
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    commitInit()
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

  override public func layoutSubviews() {
    super.layoutSubviews()
    setupUI()
  }

  public func setup(
    numberOfItems: @escaping () -> Int,
    factory: @escaping (Int) -> SlideTabBar.Item,
    shouldAllowItemSelect: ((Int) -> Bool)? = nil,
    onSelected: ((Int) -> Void)? = nil)
  {
    getNumberOfItems = numberOfItems
    itemFactory = factory
    self.shouldAllowItemSelect = shouldAllowItemSelect
    onItemSelected = onSelected
  }

  public func reload(at index: Int = 0, animated: Bool) {
    didFinishLayout = false
    isReloading = !animated
    buildItemViews(at: index)
    buildLine()
  }
}

// MARK: UI

extension SlideTabBar {
  private func buildItemViews(at index: Int) {
    /// For reset
    if items.count > 0 {
      reset()
    }

    guard numberOfItems > 0 else { return }

    items = (0..<numberOfItems)
      .compactMap { index in
        guard let item = setupItem(at: index) else { return nil }
        itemsStackView.addArrangedSubview(item)
        return item
      }

    itemsStackView.spacing = itemSpacing

    setNeedsLayout()
    layoutIfNeeded()

    let _index = findAvailableIndex(by: index)
    guard _index >= 0 else { return }
    selectedIndex = _index
  }

  private func setupItem(at index: Int) -> Item? {
    guard let item = itemFactory?(index) ?? dataSource?.itemView(self, at: index)
    else { return nil }

    item.tag = index
    item.setSelected(false)

    let tap = UITapGestureRecognizer(target: self, action: #selector(onItemTapped(_:)))
    item.addGestureRecognizer(tap)

    return item
  }

  @objc
  private func onItemTapped(_ sender: UITapGestureRecognizer) {
    guard let tag = sender.view?.tag else { return }
    isReloading = false
    selectedIndex = tag
  }

  private func updateItemTitleColor(
    from fromItem: Item?,
    to toItem: Item? = nil,
    by percentage: CGFloat)
  {
    toItem?.setTransformingColor(
      SlideCalculator
        .color(
          by: 1 - percentage,
          between: itemModel.color, itemModel.selectedColor))
    fromItem?.setTransformingColor(
      SlideCalculator
        .color(
          by: percentage,
          between: itemModel.color, itemModel.selectedColor))
  }

  private func tabBarItem(at index: Int) -> Item? {
    if let item = itemsStackView.arrangedSubviews[index] as? Item {
      return item
    }
    return nil
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

  private func reset() {
    selectedIndex = -1

    trackerView.isHidden = true

    itemsStackView.arrangedSubviews.forEach {
      itemsStackView.removeArrangedSubview($0)
      $0.removeFromSuperview()
    }

    items.removeAll()
  }

  func select(at index: Int, animated: Bool) {
    isReloading = !animated
    selectedIndex = index
  }

  private func findAvailableIndex(by index: Int) -> Int {
    guard
      let shouldAllowItemSelect,
      !shouldAllowItemSelect(index)
    else { return index }

    return (0..<itemsCount).first(where: { shouldAllowItemSelect($0) }) ?? -1
  }

  private func setupUI() {
    guard
      scrollView.frame.size != .zero,
      itemsStackView.frame.size != .zero,
      !didFinishLayout
    else { return }

    didFinishLayout = true
    distribution.update(scrollView, contentInset, itemsStackView, fullConstraint)

    guard
      trackerHeight > 0,
      let item = tabBarItem(at: selectedIndex)
    else { return }

    moveTracker(item, animated: false)
  }
}

// MARK: Animate

extension SlideTabBar {
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
        self.scrollToMiddle(toItem, animated: !self.isReloading)
        self.moveTracker(toItem, animated: true)
      }
    }
  }

  private func scrollToMiddle(_ toItem: Item, animated: Bool) {
    guard scrollView.contentSize.width + contentInset.left + contentInset.right > scrollView.frame.width
    else { return }

    if contentInset == .zero {
      /// Calculate scrollView center point with toItem
      let calced = CGRect(
        x: toItem.center.x - scrollView.bounds.width / 2,
        y: toItem.frame.origin.y,
        width: scrollView.bounds.width,
        height: scrollView.bounds.height)

      scrollView.scrollRectToVisible(calced, animated: animated)
    }

    var offsetX = toItem.center.x - (scrollView.bounds.width / 2)

    /// If item is the first, scroll to the start
    if selectedIndex == 0 {
      offsetX = -scrollView.contentInset.left
    }
    /// If item is the last, scroll to the end
    else if selectedIndex == numberOfItems - 1 {
      offsetX = scrollView.contentSize.width - scrollView.bounds.width + scrollView.contentInset.right
    }
    /// If item can be displayed in the middle, adjust offsetX to center item
    else {
      offsetX = min(
        max(offsetX, -scrollView.contentInset.left),
        scrollView.contentSize.width - scrollView.bounds.width + scrollView.contentInset.right)
    }

    let offsetPoint = CGPoint(x: offsetX, y: 0)
    scrollView.setContentOffset(offsetPoint, animated: animated)
  }

  private func moveTracker(_ toItem: Item, animated: Bool) {
    guard trackerHeight > 0 else { return }

    let location = trackerMode.location(
      with: toItem,
      spacing: itemSpacing,
      at: scrollView)

    let frame = CGRect(
      x: location.x,
      y: bounds.height - trackerHeight,
      width: location.width,
      height: trackerHeight)

    if trackerView.isHidden {
      trackerView.isHidden = false
      trackerView.frame = frame
    }
    else {
      guard animated
      else {
        trackerView.frame = frame
        return
      }

      UIView.animate(
        withDuration: 0.3,
        delay: 0,
        options: .curveEaseIn,
        animations: { [weak trackerView] in
          trackerView?.frame = frame
        },
        completion: nil)
    }
  }

  private func switching(from fromIndex: Int, to toIndex: Int, by percentage: CGFloat) {
    guard let fromItem = tabBarItem(at: fromIndex) else { return }

    let fromLocation = trackerMode.location(with: fromItem, spacing: itemSpacing, at: scrollView)
    let fromX = fromLocation.x
    let fromItemWidth = fromLocation.width

    var toX: CGFloat = 0
    var toItemWidth: CGFloat = 0

    if
      toIndex >= 0, toIndex < itemsCount,
      let toItem = tabBarItem(at: toIndex)
    {
      let toLocation = trackerMode.location(with: toItem, spacing: itemSpacing, at: scrollView)

      toItemWidth = toLocation.width
      toX = toLocation.x

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
