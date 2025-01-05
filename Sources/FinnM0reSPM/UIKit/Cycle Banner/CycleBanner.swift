import UIKit
import SnapKit

public class CycleBanner: UIView {
    private let flowLayout = CycleBannerScaledFlowLayout()
    
    private var collectionView: UICollectionView!

    private var timer: Timer?
    
    /// 前後各+1
    private var itemsCount: Int {
        var count = dataSource?.numberOfItems() ?? 0
        count += count > 1 ? 2 : 0
        return count
    }

    private var isOnFirst = false
    private var isOnLast = false

    public var autoScrollInterval: TimeInterval = 5

    public var itemSize: CGSize = .zero {
        didSet {
            flowLayout.itemSize = itemSize
        }
    }

    public var currentIndex: Int {
        calculateCurrentIndex()
    }

    weak var dataSource: CycleBannerDataSource?
    weak var delegate: CycleBannerDelegate?

    public init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        } else {
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
        guard itemsCount > 0 else { return }

        collectionView.scrollToItem(
            at: [0, index],
            at: .centeredHorizontally,
            animated: animated
        )
    }
}

// MARK: - Timer

extension CycleBanner {
    private func startTimer() {
        guard itemsCount > 1, timer == nil else { return }

        timer = Timer.scheduledTimer(
            timeInterval: autoScrollInterval,
            target: self,
            selector: #selector(autoScroll),
            userInfo: nil,
            repeats: true
        )

        RunLoop.main.add(timer!, forMode: .common)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    @objc 
    private func autoScroll() {
        scroll(at: currentIndex + 1, animated: true)
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
        } else if index >= itemsCount - 1 {
            scrollView.contentOffset.x -= CGFloat(itemsCount - 2) * itemSize.width
            isOnFirst = scrollView.isDecelerating
        }
    }

    /// 處理快速滾動停止後的偏移校正
    private func adjustForDecelerating(_ scrollView: UIScrollView) {
        let tolerances: CGFloat = 10
        let lastOffset = CGFloat(itemsCount - 2) * itemSize.width
        let firstOffset = itemSize.width

        if isOnLast,
           scrollView.contentOffset.x < lastOffset + tolerances {
            scrollView.setContentOffset(CGPoint(x: lastOffset, y: 0), animated: true)
            isOnLast = false
        }

        if isOnFirst,
           scrollView.contentOffset.x > firstOffset - tolerances {
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
}

// MARK: - CollectionView

extension CycleBanner:
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
{
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopTimer()
        isOnFirst = false
        isOnLast = false
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        startTimer()
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard itemsCount > 1 else { return }

        adjustOffset(scrollView, with: currentIndex)

        delegate?.didScroll?(to: currentIndex)

        if scrollView.isDecelerating {
            adjustForDecelerating(scrollView)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        itemsCount
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = convert(indexPath: indexPath)
        return dataSource?.item(collectionView: collectionView, at: index) ?? .init()
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private final class Test: UIView, CycleBannerDataSource {
    let banner = CycleBanner()

    init() {
        super.init(frame: .zero)

        addSubview(banner)
        banner.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(100)
        }

        banner.itemSize = .init(width: UIScreen.main.bounds.width - 100, height: 100)
        banner.register(Cell.self, forCellWithReuseIdentifier: "cell")
        banner.dataSource = self

        banner.reload()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func item(collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        (cell as? Cell)?.label.text = "\(indexPath.row)"
        return cell
    }

    func numberOfItems() -> Int {
        5
    }
}

@available(iOS 17.0, *)
#Preview {
    Test()
}
#endif
