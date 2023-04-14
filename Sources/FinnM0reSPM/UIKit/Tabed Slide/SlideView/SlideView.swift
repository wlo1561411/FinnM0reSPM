import UIKit

// TODO: Maybe can use UIPageViewController
public class SlideView: UIView {
  public weak var delegate: SlideViewDelegate?
  public weak var dataSource: SlideViewDataSource?

  public var currentViewController: UIViewController? { preViewController }

  public var isAnimation = true

  public lazy var swipeCancelMaxValue: CGFloat = self.frame.width / 2

  override public var isHidden: Bool {
    didSet {
      preViewController?.view.isHidden = isHidden
      toViewController?.view.isHidden = isHidden
    }
  }

  public var selectedIndex: Int {
    get {
      preIndex
    }
    set {
      if newValue == -1 { preIndex = newValue }
      prepareSwitch(to: newValue)
    }
  }

  public var switchable = true {
    didSet {
      panGestureRecognizer.isEnabled = switchable
    }
  }

  private weak var baseViewController: UIViewController?

  private var panGestureRecognizer: UIPanGestureRecognizer!

  private var preIndex: Int = -1
  private var toIndex: Int = -1
  private weak var preViewController: UIViewController?
  private weak var toViewController: UIViewController?

  private var isSwitching = false
  private var panStartPoint: CGPoint = .zero

  private var cache: LRUCache<UIViewController>?

  private var viewControllersCount: Int {
    dataSource?.numberOfViewController(self) ?? 0
  }

  // MARK: Initialize

  override public init(frame: CGRect) {
    super.init(frame: frame)
    commitInit()
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    commitInit()
  }

  private func commitInit() {
    panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panHandler(sender:)))
    addGestureRecognizer(panGestureRecognizer)
  }

  public func setup(cacheSize: Int = 0, at base: UIViewController) {
    reset()

    baseViewController = base

    if cacheSize != 0 {
      cache = .init(size: cacheSize)
    }
    prepareSwitch(to: 0)
  }
}

// MARK: Animation

extension SlideView {
  private func prepareSwitch(to index: Int) {
    if index == preIndex || index < 0 || isSwitching { return }

    if
      preViewController?.parent == baseViewController,
      let base = baseViewController,
      let pre = preViewController,
      let to = viewController(with: index)
    {
      isSwitching = true
      delegate?.willSwitch?(to: index, viewController: to)

      pre.willMove(toParent: nil)
      base.addChild(to)
      animate(from: pre, to: to, with: index)

      preIndex = index
      preViewController = to
    }
    else {
      show(at: index)
    }

    toViewController = nil
    toIndex = -1
  }

  private func show(at index: Int) {
    guard
      preIndex != index,
      let base = baseViewController,
      let to = viewController(with: index)
    else { return }

    delegate?.willSwitch?(to: index, viewController: to)
    removePreViewController()

    base.addChild(to)
    to.view.frame = self.bounds
    addSubview(to.view)
    to.didMove(toParent: base)

    preIndex = index
    preViewController = to

    delegate?.didSwitch?(to: index, viewController: to)
  }

  private func animate(
    from preViewController: UIViewController,
    to toViewController: UIViewController,
    with index: Int)
  {
    let preRect = preViewController.view.frame

    let leftRect = CGRect(
      x: preRect.origin.x - preRect.width,
      y: preRect.origin.y,
      width: preRect.width,
      height: preRect.height)
    let rightRect = CGRect(
      x: preRect.origin.x + preRect.width,
      y: preRect.origin.y,
      width: preRect.width,
      height: preRect.height)

    var startRect: CGRect = .zero
    var endRect: CGRect = .zero

    if index > preIndex {
      startRect = rightRect
      endRect = leftRect
    }
    else {
      startRect = leftRect
      endRect = rightRect
    }

    if isAnimation { toViewController.view.frame = startRect }

    toViewController.willMove(toParent: baseViewController)

    baseViewController?.transition(
      from: preViewController,
      to: toViewController,
      duration: isAnimation ? 0.4 : 0,
      animations: { [weak self] in
        toViewController.view.frame = preRect
        if self?.isAnimation ?? false { preViewController.view.frame = endRect }
      },
      completion: { [weak self] _ in
        preViewController.removeFromParent()
        toViewController.didMove(toParent: self?.baseViewController)

        self?.delegate?.didSwitch?(to: index, viewController: toViewController)
        self?.isSwitching = false
      })
  }

  private func animateBack(with _: CGFloat) {
    UIView.animate(
      withDuration: 0.3,
      delay: 0,
      options: .curveEaseIn)
    { [weak self] in
      self?.translate(with: 0)
    } completion: { [weak self] _ in
      guard let self else { return }

      if self.toIndex >= 0, self.toIndex != self.preIndex, self.toIndex < self.viewControllersCount {
        self.preViewController?.beginAppearanceTransition(true, animated: false)
        self.removeToViewController()
        self.preViewController?.endAppearanceTransition()

        if let pre = self.preViewController {
          self.delegate?.didCancelSwitch?(to: self.preIndex, viewController: pre)
        }
      }
    }
  }
}

// MARK: Pan Handle

extension SlideView {
  private func translate(with offset: CGFloat) {
    var x: CGFloat = 0

    if toIndex < preIndex {
      x = bounds.origin.x - bounds.width + offset
    }
    else if toIndex > preIndex {
      x = bounds.origin.x + bounds.width + offset
    }

    preViewController?.view.frame = CGRect(
      x: bounds.origin.x + offset,
      y: bounds.origin.y,
      width: bounds.width,
      height: bounds.height)

    if toIndex >= 0, toIndex < viewControllersCount {
      toViewController?.view.frame = CGRect(
        x: x,
        y: bounds.origin.y,
        width: bounds.width,
        height: bounds.height)
    }
    delegate?.switching?(from: preIndex, to: toIndex, with: abs(offset / bounds.width))
  }

  @objc
  private func panHandler(sender: UIPanGestureRecognizer) {
    if preIndex < 0 { return }

    let touchPoint = sender.translation(in: self)
    let offset = touchPoint.x - panStartPoint.x

    switch sender.state {
    case .began:
      panStartPoint = touchPoint
      preViewController?.beginAppearanceTransition(false, animated: true)

    case .changed:
      panChanged(offset)

    case .ended:
      panEnded(offset)

    case .cancelled,
         .failed,
         .possible:
      break

    @unknown default:
      fatalError("Pan Hander Error")
    }
  }

  private func panChanged(_ offset: CGFloat) {
    var panToIndex = -1

    if offset > 0 {
      panToIndex = preIndex - 1
    }
    else if offset < 0 {
      panToIndex = preIndex + 1
    }

    if panToIndex != toIndex {
      removeToViewController()
    }

    if panToIndex < 0 || panToIndex >= viewControllersCount {
      toIndex = panToIndex
      translate(with: offset / 2)
    }
    else {
      if
        panToIndex != toIndex,
        let to = viewController(with: panToIndex)
      {
        delegate?.willSwitch?(to: panToIndex, viewController: to)

        toViewController = to
        baseViewController?.addChild(to)
        toViewController?.willMove(toParent: baseViewController)
        toViewController?.beginAppearanceTransition(true, animated: true)
        addSubview(to.view)

        toIndex = panToIndex
      }
      translate(with: offset)
    }
  }

  private func panEnded(_ offset: CGFloat) {
    guard
      toIndex >= 0,
      toIndex != preIndex,
      toIndex < viewControllersCount,
      abs(offset) > swipeCancelMaxValue
    else {
      animateBack(with: offset)
      return
    }

    let animationTime = TimeInterval((abs(frame.width) - abs(offset)) / frame.width * 0.3)

    UIView.animate(
      withDuration: animationTime,
      delay: 0,
      options: .curveEaseIn)
    { [weak self] in
      self?.translate(with: offset > 0 ? self?.bounds.width ?? 0 : -(self?.bounds.width ?? 0))
    }
              completion: { [weak self] _ in
      guard let self else { return }

      self.removePreViewController()

      if self.toIndex >= 0, self.toIndex < self.viewControllersCount {
        self.toViewController?.endAppearanceTransition()
        self.toViewController?.didMove(toParent: self.baseViewController)

        self.preIndex = self.toIndex
        self.preViewController = self.toViewController
        self.toViewController = nil
        self.toIndex = -1
      }

      if let pre = self.preViewController {
        self.delegate?.didSwitch?(to: self.preIndex, viewController: pre)
      }
    }
  }
}

// MARK: DataSource Handle

extension SlideView {
  private func viewController(with index: Int) -> UIViewController? {
    if let cache = self.cache {
      if let cachedObject = cache.object(for: "\(index)") {
        return cachedObject
      }
      else {
        guard let object = dataSource?.viewController(self, at: index) else { return nil }
        cache.set(object: object, for: "\(index)")
        return object
      }
    }
    else {
      return dataSource?.viewController(self, at: index)
    }
  }

  private func removePreViewController() {
    if preViewController != nil {
      remove(with: preViewController)
      preViewController?.endAppearanceTransition()
      preViewController = nil
      preIndex = -1
    }
  }

  private func removeToViewController() {
    if toViewController != nil {
      toViewController?.beginAppearanceTransition(false, animated: false)
      remove(with: toViewController)
      toViewController?.endAppearanceTransition()
      toViewController = nil
      toIndex = -1
    }
  }

  func reset() {
    selectedIndex = -1

    preViewController?.view.removeFromSuperview()
    preViewController?.removeFromParent()
    preViewController = nil

    toViewController?.view.removeFromSuperview()
    toViewController?.removeFromParent()
    toViewController = nil

    cache?.removeAll()
  }

  func preload(at index: Int) {
    guard
      let cache,
      cache.capacity > 0,
      let viewController = dataSource?.viewController(self, at: index)
    else { return }

    viewController.loadViewIfNeeded()
    cache.set(object: viewController, for: "\(index)")
  }

  private func remove(with viewController: UIViewController?) {
    viewController?.willMove(toParent: nil)
    viewController?.view.removeFromSuperview()
    viewController?.removeFromParent()
  }
}
