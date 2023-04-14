import RxCocoa
import RxSwift
import SnapKit
import UIKit

/// Item size will follow CycleBannerView's size
/// Set itemSpacing to arrange item's space
public class CycleBannerView: UIView {
  private let flowLayout = UICollectionViewFlowLayout()

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    collectionView.isPagingEnabled = true
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.backgroundColor = .clear
    collectionView.bounces = false
    collectionView.register(Cell.self, forCellWithReuseIdentifier: "Cell")
    return collectionView
  }()

  private let disposeBag = DisposeBag()

  private var collectionHeight: Constraint?

  private var timer: Timer?

  private var tempCount: Int {
    itemCount + 2
  }

  private var tempIndex = 1
  private var itemCount: Int {
    dataSource?.numberOfItems() ?? 0
  }

  private var currentIndex = 0

  private var startPoint: CGFloat = 0
  private var endPoint: CGFloat = 0

  private var isScrolling = false
  private var isScrollLeft: Bool {
    (endPoint - startPoint) < 0
  }

  public weak var delegate: CycleBannerViewDelegate?
  public weak var dataSource: CycleBannerViewDataSource?

  public var itemSpacing: CGFloat = 0

  public var slidingSeconds: TimeInterval = 5

  public var autoSliding = true {
    didSet {
      if autoSliding {
        setupTimer()
      }
      else {
        stopTimer()
      }
    }
  }

  public init() {
    super.init(frame: .zero)
    customInit()
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    customInit()
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    customInit()
  }
  
  private func customInit() {
    backgroundColor = .clear

    collectionView.delegate = self
    collectionView.dataSource = self

    flowLayout.scrollDirection = .horizontal
    flowLayout.minimumLineSpacing = 0
    flowLayout.minimumInteritemSpacing = 0

    addSubview(collectionView)
    collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      collectionHeight = make.height.equalTo(0).priority(.high).constraint
    }
    
    collectionView.rx
      .observe(\.contentSize)
      .observe(on: MainScheduler.instance)
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] in
        self?.collectionHeight?.update(offset: $0.height)
      })
      .disposed(by: disposeBag)

    DispatchQueue.main.async {
      self.collectionView.scrollToItem(at: [0, 1], at: .left, animated: false)
    }
  }

  public func reload() {
    stopTimer()
    
    guard itemCount > 0 else { return }
    
    /// UICollectionViewFlowLayout.automaticSize will cause error
    /// cellForItemAt will call twice at first time to swipe left
    /// Set itemSize as workaround
    layoutIfNeeded()
    flowLayout.itemSize = frame.size
    
    collectionView.reloadData()

    resetCalculation()

    if itemCount > 1 {
      collectionView.scrollToItem(at: [0, tempIndex], at: .left, animated: true)
    }

    let shouldStartCounting = (dataSource?.numberOfItems() ?? 0) > 1
    collectionView.isScrollEnabled = shouldStartCounting

    guard shouldStartCounting else { return }
    setupTimer()
  }

  deinit { stopTimer() }
}

// MARK: - Calculate Index

extension CycleBannerView {
  private func resetCalculation() {
    tempIndex = 1
    currentIndex = 0
    startPoint = 0
    endPoint = 0
  }

  private func calculateIndex(isTimer: Bool) {
    if !isScrollLeft || isTimer {
      currentIndex += 1
      tempIndex = currentIndex + 1
      if currentIndex == itemCount {
        currentIndex = 0
      }
    }
    else {
      currentIndex -= 1
      tempIndex = currentIndex - 1
      if currentIndex < 0 {
        currentIndex = itemCount - 1
      }
    }
    
    delegate?.didScroll?(to: currentIndex)
  }
}

// MARK: - Timer

extension CycleBannerView {
  private func setupTimer() {
    guard autoSliding else { return }
    timer = Timer(timeInterval: slidingSeconds, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    RunLoop.main.add(timer!, forMode: .common)
  }

  private func stopTimer() {
    if timer == nil {
      return
    }
    timer?.invalidate()
    timer = nil
  }

  @objc
  private func timerAction() {
    guard !isScrolling else { return }

    calculateIndex(isTimer: true)

    collectionView.scrollToItem(at: [0, tempIndex], at: .left, animated: true)
  }
}

// MARK: - Scroll

extension CycleBannerView {
  /// End scroll with timer
  public func scrollViewDidEndScrollingAnimation(_: UIScrollView) {
    if tempIndex == tempCount - 1 {
      collectionView.scrollToItem(at: [0, 1], at: .left, animated: false)
      tempIndex = 1
    }
  }

  public func scrollViewWillBeginDragging(_: UIScrollView) {
    isScrolling = true
    startPoint = collectionView.contentOffset.x
  }

  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    isScrolling = false
    endPoint = scrollView.contentOffset.x

    if abs(endPoint - startPoint) < collectionView.bounds.width / 2 { return }

    calculateIndex(isTimer: false)

    let pageFloat = (scrollView.contentOffset.x / scrollView.frame.size.width)
    let pageInt = Int(round(pageFloat))

    switch pageInt {
    case 0:
      collectionView.scrollToItem(at: [0, itemCount], at: .left, animated: false)
    case tempCount - 1:
      collectionView.scrollToItem(at: [0, 1], at: .left, animated: false)
    default:
      break
    }
  }
}

// MARK: - Collection

extension CycleBannerView:
  UICollectionViewDelegate,
  UICollectionViewDataSource,
  UICollectionViewDelegateFlowLayout
{
  public func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
    tempCount
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? Cell
    else { return .init() }

    var fixed = 0
    if indexPath.row == 0 {
      fixed = itemCount - 1
    }
    else if indexPath.row == tempCount - 1 {
      fixed = 0
    }
    else {
      fixed = indexPath.row - 1
    }

    cell.embed(
      itemCount == 0 ? nil : dataSource?.item(at: fixed),
      space: itemSpacing,
      size: collectionView.frame.size)

    return cell
  }

  public func collectionView(_: UICollectionView, didSelectItemAt _: IndexPath) {
    delegate?.didSelected?(at: currentIndex)
  }
}
