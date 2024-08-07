import SnapKit
import UIKit

public class SlideTabBar: UIView {
    private lazy var trackerView: UIView = {
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

    private var items: [SlideTabBarItem] = []
    private var itemsCount: Int {
        items.count
    }

    private var _selectedIndex: Int = -1 {
        willSet {
            guard _selectedIndex != newValue else { return }
            switchTo(newValue)
        }
    }

    private var selectedIndex: Int {
        get {
            _selectedIndex
        }
        set {
            guard
                _selectedIndex != newValue || configurations.contains(.duplicateTap(true)),
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

    private var getNumberOfItems: (() -> Int)?
    private var itemFactory: ((Int) -> SlideTabBarItem)?
    private var shouldAllowItemSelect: ((Int) -> Bool)?
    private var onItemSelected: ((Int) -> Void)?

    private var didFinishLayout = false
    private var isReloading = false

    private var numberOfItems: Int {
        getNumberOfItems?() ?? dataSource?.numberOfItems(self) ?? 0
    }

    public var numberOfTabs: Int {
        itemsCount
    }

    public var bottomLineHeight: CGFloat = 0
    public var bottomLineColor: UIColor = .clear

    public var itemSettings: SlideTabBarItem.Settings = [:]
    public var itemSpacing: CGFloat = 10

    public var contentInset: UIEdgeInsets = .zero {
        didSet {
            distribution.resetContentInset(scrollView: scrollView, contentInset: contentInset)
        }
    }

    public var trackerHeight: CGFloat = 0
    public var trackerColor: UIColor = .blue {
        didSet {
            trackerView.backgroundColor = trackerColor
        }
    }

    public var distribution: SlideTabBarDistribution = .contentLeading()
    public var trackerMode: SlideTabBarTrackerMode = .byView
    public var configurations: Set<Configuration> = [
        .duplicateTap(false),
        .selectionWithEvent(true)
    ]

    // MARK: Initialize

    public init() {
        super.init(frame: .zero)
        commitInit()
    }

    public init(
        numberOfItems: @escaping () -> Int,
        factory: @escaping (Int) -> SlideTabBarItem,
        onSelected: ((Int) -> Void)?)
    {
        super.init(frame: .zero)
        setup(numberOfItems: numberOfItems, factory: factory, onSelected: onSelected)
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
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview()

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
        factory: @escaping (Int) -> SlideTabBarItem,
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

    public func select(
        at index: Int?,
        animated: Bool,
        withEvent: Bool = false)
    {
        if let index {
            isReloading = !animated

            if withEvent {
                items.forEach { $0.setSelected(false, settings: itemSettings) }
                _selectedIndex = index
                items[safe: index]?.setSelected(true, settings: itemSettings)
            }
            else {
                selectedIndex = index
            }
        }
        else {
            selectedIndex = -1
            items.forEach { $0.setSelected(false, settings: itemSettings) }
        }
    }

    public func reloadUI() {
        for item in items {
            updateItem(item, isSelected: item.tag == selectedIndex)
        }
    }

    public func scrollToHead(animated: Bool) {
        guard scrollView.contentSize.width + contentInset.left + contentInset.right > scrollView.frame.width
        else { return }

        scrollView.setContentOffset(.init(x: -contentInset.left, y: 0), animated: animated)
    }
}

// MARK: UI

extension SlideTabBar {
    private func setupUI() {
        guard
            scrollView.frame.size != .zero,
            !didFinishLayout
        else { return }

        didFinishLayout = true
        distribution.update(scrollView, contentInset, itemsStackView, fullConstraint)

        if
            trackerHeight > 0,
            let item = tabBarItem(at: selectedIndex)
        {
            moveTracker(item, animated: false)
        }

        itemsStackView.snp.makeConstraints { make in
            make.top.equalTo(contentInset.top)
            make.bottom.equalTo(-contentInset.bottom)
        }
    }

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
        guard _index >= 0, !configurations.contains(.selectionWithEvent(false)) else { return }
        selectedIndex = _index
    }

    private func setupItem(at index: Int) -> SlideTabBarItem? {
        guard let item = itemFactory?(index) ?? dataSource?.itemView(self, at: index)
        else { return nil }

        item.tag = index
        updateItem(item, isSelected: false)

        let tap = UITapGestureRecognizer(target: self, action: #selector(onItemTapped(_:)))
        item.addGestureRecognizer(tap)

        return item
    }

    private func updateItem(_ item: SlideTabBarItem?, isSelected: Bool) {
        guard let item else { return }

        if
            let shouldAllowItemSelect,
            !shouldAllowItemSelect(item.tag)
        {
            item.setEnable(false, settings: itemSettings)
        }
        else {
            item.setSelected(isSelected, settings: itemSettings)
        }
    }

    @objc
    private func onItemTapped(_ sender: UITapGestureRecognizer) {
        guard let tag = sender.view?.tag else { return }
        isReloading = false
        selectedIndex = tag
    }

    private func updateItemTitleColor(
        from fromItem: SlideTabBarItem?,
        to toItem: SlideTabBarItem? = nil,
        by percentage: CGFloat)
    {
        toItem?.setTransformingColor(
            SlideCalculator
                .color(
                    by: 1 - percentage,
                    between: itemSettings[.normal]?.textColor ?? .clear,
                    itemSettings[.selected]?.textColor ?? .clear))

        fromItem?.setTransformingColor(
            SlideCalculator
                .color(
                    by: percentage,
                    between: itemSettings[.normal]?.textColor ?? .clear,
                    itemSettings[.selected]?.textColor ?? .clear))
    }

    private func tabBarItem(at index: Int) -> SlideTabBarItem? {
        if let item = itemsStackView.arrangedSubviews[safe: index] as? SlideTabBarItem {
            return item
        }
        return nil
    }

    private func buildLine() {
        guard bottomLineColor != .clear, bottomLineHeight > 0, bottomLineView.superview == nil else { return }

        bottomLineView.backgroundColor = bottomLineColor

        scrollView.insertSubview(bottomLineView, belowSubview: trackerView)
        bottomLineView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(self)
            make.height.equalTo(bottomLineHeight)
        }
    }

    private func reset() {
        _selectedIndex = -1

        trackerView.isHidden = true

        for arrangedSubview in itemsStackView.arrangedSubviews {
            itemsStackView.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        }

        items.removeAll()
    }

    private func findAvailableIndex(by index: Int) -> Int {
        guard
            let shouldAllowItemSelect,
            !shouldAllowItemSelect(index)
        else { return index }

        return (0..<itemsCount).first(where: { shouldAllowItemSelect($0) }) ?? -1
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
            updateItem(tabBarItem(at: preIndex), isSelected: false)
        }

        if
            toIndex >= 0, toIndex < itemsCount,
            let toItem = tabBarItem(at: toIndex)
        {
            updateItem(toItem, isSelected: true)

            DispatchQueue.main.async {
                self.scrollToMiddle(toItem, animated: !self.isReloading)
                self.moveTracker(toItem, animated: true)
            }
        }
    }

    private func scrollToMiddle(_ toItem: SlideTabBarItem, animated: Bool) {
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

    private func moveTracker(_ toItem: SlideTabBarItem, animated: Bool) {
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

// MARK: - Preview

#if swift(>=5.9)
    @available(iOS 17.0, *)
    #Preview {
        let title = (0...5).map { "This is Test \($0)" }

        return SlideTabBar()
            .sr
            .trackerHeight(5)
            .trackerColor(.blue)
            .bottomLineHeight(10)
            .bottomLineColor(.red)
            .distribution(.contentLeading())
            .contentInset(.init(top: 10, left: 16, bottom: 10, right: 16))
            .itemSpacing(40)
            .itemSettings([
                .normal : .init(
                    font: .systemFont(ofSize: 14),
                    textColor: .darkGray,
                    borderColor: .systemGreen,
                    borderWidth: 0,
                    backgroundColor: .systemGray5),
                .selected : .init(
                    font: .systemFont(ofSize: 14),
                    textColor: .systemGreen,
                    borderWidth: 1)
            ])
            .makeConstraints({ make in
                make.width.equalTo(300)
                make.height.equalTo(100)
            })
            .other { tabBar in
                tabBar.setup(
                    numberOfItems: { title.count },
                    factory: { index in
                        let item = SlideTabBar.DefaultItem()
                        item.backgroundColor = .lightGray
                        item.titleLabel.text = title[index]
                        return item
                    },
                    shouldAllowItemSelect: {
                        $0 != 1
                    },
                    onSelected: {
                        if $0 == 4 {
                            tabBar.reload(at: 2, animated: true)
                        }
                        print("Tap", $0)
                    })
                tabBar.reload(animated: true)
            }
            .unwrap()
    }
#endif
