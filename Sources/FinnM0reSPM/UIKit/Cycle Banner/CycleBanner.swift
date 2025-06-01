import SnapKit
import UIKit

public protocol CycleBannerFlowLayout: UICollectionViewFlowLayout { }

public class CycleBanner: UIView {
    private var flowLayout: CycleBannerFlowLayout = CycleBannerScaledFlowLayout(
        itemSize: .init(width: 300, height: 100),
        itemSpacing: 20)

    private var collectionView: UICollectionView!

    private var timer: Timer?

    private var itemSize: CGSize {
        flowLayout.itemSize
    }

    /// 前後各+1
    private var itemsCount: Int {
        var count = dataSource?.numberOfItems() ?? 0
        count += count > 1 ? 2 : 0
        return count
    }

    private var isOnFirst = false
    private var isOnLast = false

    /// 前後各+1
    private var _currentIndex: Int {
        calculateCurrentIndex()
    }

    /// 真正的 index
    public var currentIndex: Int {
        let index = _currentIndex
        return index > 0 ? index - 1 : itemsCount - 2
    }

    public var autoScrollInterval: TimeInterval = 5

    weak var dataSource: CycleBannerDataSource?
    weak var delegate: CycleBannerDelegate?

    public init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        stopTimer()
    }

    public func config(flowLayout: CycleBannerFlowLayout) {
        self.flowLayout = flowLayout
        self.collectionView.collectionViewLayout = flowLayout
        self.flowLayout.invalidateLayout()
    }

    public func reload() {
        collectionView.layoutIfNeeded()
        collectionView.reloadData()

        DispatchQueue.main.async {
            let inset = (self.bounds.size.width - self.itemSize.width) / 2
            self.flowLayout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
            self.scroll(at: 1, animated: false)
        }

        if itemsCount <= 1 {
            stopTimer()
        }
        else {
            startTimer()
        }
    }

    public func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
}

// MARK: - UI

extension CycleBanner {
    private func setupUI() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)

        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        collectionView.decelerationRate = .fast
        collectionView.scrollsToTop = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false

        collectionView.dataSource = self
        collectionView.delegate = self
    }

    private func scroll(at index: Int, animated: Bool) {
        guard itemsCount > 1 else { return }

        collectionView.scrollToItem(
            at: [0, index],
            at: .centeredHorizontally,
            animated: animated)
    }
}

// MARK: - Timer

extension CycleBanner {
    private func startTimer() {
        guard
            itemsCount > 1,
            timer == nil,
            autoScrollInterval > 0
        else { return }

        timer = Timer.scheduledTimer(
            timeInterval: autoScrollInterval,
            target: self,
            selector: #selector(autoScroll),
            userInfo: nil,
            repeats: true)

        RunLoop.main.add(timer!, forMode: .common)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    @objc
    private func autoScroll() {
        scroll(at: _currentIndex + 1, animated: true)
    }
}

// MARK: - Data Handle

extension CycleBanner {
    private func calculateCurrentIndex() -> Int {
        let inset = (bounds.size.width - itemSize.width) / 2
        let offsetX = collectionView.contentOffset.x + bounds.size.width / 2 - inset
        return Int(floor(offsetX / itemSize.width))
    }

    /// 處理無縫循環滾動的邏輯
    /// 滑動到 前後各 +1 的假頁面時
    private func adjustOffset(_ scrollView: UIScrollView, with index: Int) {
        if index < 1 {
            scrollView.contentOffset.x += CGFloat(itemsCount - 2) * itemSize.width
            isOnLast = scrollView.isDecelerating
        }
        else if index >= itemsCount - 1 {
            scrollView.contentOffset.x -= CGFloat(itemsCount - 2) * itemSize.width
            isOnFirst = scrollView.isDecelerating
        }
    }

    /// 處理快速滾動停止後的偏移校正
    private func adjustForDecelerating(_ scrollView: UIScrollView) {
        let tolerances: CGFloat = 10
        let lastOffset = CGFloat(itemsCount - 2) * itemSize.width
        let firstOffset = itemSize.width

        if
            isOnLast,
            scrollView.contentOffset.x < lastOffset + tolerances
        {
            scrollView.setContentOffset(CGPoint(x: lastOffset, y: 0), animated: true)
            isOnLast = false
        }

        if
            isOnFirst,
            scrollView.contentOffset.x > firstOffset - tolerances
        {
            scrollView.setContentOffset(CGPoint(x: firstOffset, y: 0), animated: true)
            isOnFirst = false
        }
    }

    private func convert(indexPath: IndexPath) -> IndexPath {
        guard itemsCount > 1 else { return indexPath }

        switch indexPath.item {
        case 0:
            return [0, itemsCount - 3]
        case itemsCount - 1:
            return [0, 0]
        default:
            return [0, indexPath.item - 1]
        }
    }

    private func performDidScroll() {
        guard
            let minX = flowLayout
                .layoutAttributesForItem(at: [0, _currentIndex])?
                .frame
                .minX,
            minX == collectionView.contentOffset.x
        else { return }

        delegate?.didScroll?(to: currentIndex)
    }
}

// MARK: - CollectionView

extension CycleBanner:
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
{
    public func scrollViewWillBeginDragging(_: UIScrollView) {
        stopTimer()
        isOnFirst = false
        isOnLast = false
    }

    public func scrollViewDidEndDragging(_: UIScrollView, willDecelerate _: Bool) {
        startTimer()
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard itemsCount > 1 else { return }

        adjustOffset(scrollView, with: _currentIndex)

        performDidScroll()

        if scrollView.isDecelerating {
            adjustForDecelerating(scrollView)
        }
    }

    public func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        itemsCount
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = convert(indexPath: indexPath)
        return dataSource?.item(collectionView: collectionView, at: index) ?? .init()
    }

    public func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = convert(indexPath: indexPath)
        delegate?.didSelected?(at: index.item)
    }
}

// MARK: - Preview

#if swift(>=5.9)

    private final class Cell: UICollectionViewCell {
        let label = UILabel()

        override init(frame: CGRect) {
            super.init(frame: frame)

            label.textAlignment = .center
            label.backgroundColor = .systemPink

            contentView.addSubview(label)
            label.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    private final class CycleBannerTest: UIView, CycleBannerDataSource, CycleBannerDelegate {
        let banner = CycleBanner()

        init() {
            super.init(frame: .zero)

            addSubview(banner)
            banner.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(100)
            }

            banner.autoScrollInterval = 0
            banner.register(Cell.self, forCellWithReuseIdentifier: "cell")
            banner.dataSource = self
            banner.delegate = self

//            banner.config(
//                flowLayout: CycleBannerScaledFlowLayout(
//                    itemSize: .init(width: UIScreen.main.bounds.width - 40, height: 100),
//                    itemSpacing: 20))

            banner.config(
                flowLayout: CycleBannerFullFlowLayout(
                    itemSize: .init(width: UIScreen.main.bounds.width, height: 100)))

            banner.reload()
        }
    
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func item(collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            (cell as? Cell)?.label.text = "\(indexPath.row)"
            return cell
        }

        func didScroll(to index: Int) {
            print(index)
        }

        func didSelected(at _: Int) {
//            print(index)
        }

        func numberOfItems() -> Int {
            3
        }
    }

    @available(iOS 17.0, *)
    #Preview {
        CycleBannerTest()
    }
#endif
