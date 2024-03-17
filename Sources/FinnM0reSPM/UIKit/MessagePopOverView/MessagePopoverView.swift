import Combine
import SnapKit
import UIKit

public class MessagePopoverView: UIView {
    public enum Style {
        case reply
        case report
        case ban
        case removeMessage

        var localizedText: String {
            "\(self)"
        }
    }

    private let selectorView = UIView()

    private let flowLayout = UICollectionViewFlowLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)

    private let viewModel = ViewModel()

    private var onItemSelected: ((_ style: Style) -> Void)?
    private var onDismiss: (() -> Void)?

    private var cancellables = Set<AnyCancellable>()

    public init() {
        super.init(frame: .zero)
        
        setupUI()

        bindUpdate()
        bindCollectionViewWidth()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let pointInCollectionView = collectionView.convert(point, from: self)

        // 只有允許 collectionView 的點擊事件, 其他就穿透下去
        if collectionView.bounds.contains(pointInCollectionView) {
            return collectionView.hitTest(pointInCollectionView, with: event)
        }
        // 避免重複點擊同個 cell 穿透下去又跳出來
        else if viewModel.isHitCurrentCell(in: point) {
            dismiss(resetIndex: false)
            return self
        }
        else {
            dismiss()
            return nil
        }
    }

    /// 跳出 PopOver
    /// - Parameters:
    ///   - styles: 按鈕資料來源
    ///   - tableView: 用來計算 cell 位置
    ///   - indexPath: 用來計算 cell 位置, 紀錄當下點擊 cell
    ///   - onItemSelected: Selector callback
    ///   - onDismiss: Dismiss callback
    public func pop(
        _ styles: [Style],
        to tableView: UITableView,
        from indexPath: IndexPath,
        onItemSelected: ((_ style: Style) -> Void)?,
        onDismiss: (() -> Void)?)
    {
        // 避免穿透後還是同一個 cell, 導致怪異行為
        guard viewModel.isAllowPopOver(at: indexPath)
        else {
            dismiss()
            return
        }

        self.onItemSelected = onItemSelected
        self.onDismiss = onDismiss

        DispatchQueue.main.async {
            tableView.window?.addSubview(self)
            self.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            let rect = self.getCellAbsolutePosition(tableView: tableView, indexPath: indexPath)
            let position = self.getSelectorPosition(cellRect: rect)
            // 使用 constraint 不能改 frame, 用這個替代
            self.selectorView.transform = CGAffineTransform(translationX: position.x, y: position.y)

            self.viewModel.currentCellRect = rect
            self.viewModel.currentIndex = indexPath

            self.viewModel.update(styles: styles)
        }
    }

    func dismiss(resetIndex: Bool = true) {
        removeFromSuperview()
        onDismiss?()

        if resetIndex {
            viewModel.currentIndex = nil
        }

        onItemSelected = nil
        onDismiss = nil
    }
}

// MARK: - UI

extension MessagePopoverView {
    private func setupUI() {
        let triangleSize = CGSize(width: 5, height: 3)
        let triangleView = createTriangleView(with: triangleSize, color: .black)

        selectorView.addSubview(triangleView)
        triangleView.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.top.equalToSuperview()
            make.size.equalTo(triangleSize)
        }

        setupCollectionView()

        selectorView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(triangleView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        addSubview(selectorView)
        selectorView.snp.makeConstraints { make in
            make.height.equalTo(38 + 3)
            make.width.equalTo(0)
            // 這個沒有意義, 只是讓他可以完成佈局
            make.top.leading.equalToSuperview()
        }
    }

    private func setupCollectionView() {
        collectionView.clipsToBounds = true
        collectionView.layer.cornerRadius = 8
        collectionView.bounces = false
        collectionView.backgroundColor = .black
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SeparatorCell.self, forCellWithReuseIdentifier: "SeparatorCell")
        collectionView.register(ItemCell.self, forCellWithReuseIdentifier: "ItemCell")

        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = .leastNonzeroMagnitude
        flowLayout.minimumInteritemSpacing = .leastNonzeroMagnitude
    }

    private func bindUpdate() {
        viewModel.bind(didUpdatedData: { [weak self] in
            guard let self else { return }
            collectionView.reloadData()
        })
    }

    private func bindCollectionViewWidth() {
        collectionView.publisher(for: \.contentSize)
            .map(\.width)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] width in
                guard let self else { return }
                self.selectorView.snp.updateConstraints { make in
                    make.width.equalTo(width)
                }
            }
            .store(in: &cancellables)
    }

    /// 換算 selector 的 position
    private func getSelectorPosition(cellRect rect: CGRect) -> CGPoint {
        let leftPadding: CGFloat = 16
        let topPadding: CGFloat = 2
        return .init(x: rect.origin.x + leftPadding, y: rect.origin.y + rect.height + topPadding)
    }

    /// 換算 cell 在 window 的絕對位置
    private func getCellAbsolutePosition(
        tableView: UITableView,
        indexPath: IndexPath)
        -> CGRect
    {
        let cellRect = tableView.rectForRow(at: indexPath)
        return tableView.convert(cellRect, to: tableView.window)
    }

    /// 對話框三角形
    private func createTriangleView(
        with size: CGSize,
        color: UIColor)
        -> UIView
    {
        let triangleView = UIView(frame: CGRect(origin: .zero, size: size))
        triangleView.backgroundColor = .clear

        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = triangleView.bounds

        let path = UIBezierPath()
        path.move(to: CGPoint(x: size.width / 2, y: 0))
        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.addLine(to: CGPoint(x: 0, y: size.height))
        path.close()

        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = color.cgColor

        triangleView.layer.addSublayer(shapeLayer)
        return triangleView
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension MessagePopoverView: UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
{
    public func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        viewModel.getNumberOfItems()
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let style = viewModel.getStyle(at: indexPath)

        var cell: UICollectionViewCell?

        if
            let style,
            let itemCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ItemCell",
                for: indexPath) as? ItemCell
        {
            cell = itemCell
            itemCell.config(style)
        }
        else {
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "SeparatorCell",
                for: indexPath)
        }

        guard let cell else { return .init() }
        return cell
    }

    public func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let style = viewModel.getStyle(at: indexPath) else { return }
        onItemSelected?(style)
        dismiss()
    }
}

#if swift(>=5.9)
    private class Demo: UIViewController {
        let tableView = UITableView()

        let messagePopoverView = MessagePopoverView()

        override func viewDidLoad() {
            super.viewDidLoad()

            view.backgroundColor = .systemGray

            tableView.sr
                .dataSource(self)
                .delegate(self)
                .register(UITableViewCell.self)
                .add(to: view)
                .makeConstraints { make in
                    make.top.equalTo(200)
                    make.left.right.bottom.equalToSuperview()
                }
        }
    }

    extension Demo: UITableViewDelegate, UITableViewDataSource {
        func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
            100
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
            cell?.textLabel?.text = "I'm row \(indexPath.row)"
            return cell!
        }

        func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
            40
        }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            messagePopoverView.pop(
                [.reply, .removeMessage, .report],
                to: tableView,
                from: indexPath,
                onItemSelected: {
                    print($0.localizedText)
                },
                onDismiss: nil)
        }
    }

    @available(iOS 17.0, *)
    #Preview {
        Demo()
    }
#endif
