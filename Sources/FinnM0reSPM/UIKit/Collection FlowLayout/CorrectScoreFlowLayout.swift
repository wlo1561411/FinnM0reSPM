import UIKit

// For example
public class CorrectScoreFlowLayout: BaseCollectionViewFlowLayout {
    public enum Supremacy: Int, CaseIterable {
        // 3-1-1
        case home
        // 2-1-2
        case draw
        // 1-1-3
        case away

        fileprivate var calculator: [CGFloat] {
            switch self {
            case .home:
                return [3, 1, 1]
            case .draw:
                return [2, 1, 2]
            case .away:
                return [1, 1, 3]
            }
        }
    }

    public enum Supply: String, CaseIterable {
        case header
        case footer
    }

    private let supplementaryHeight: CGFloat = 48
    private let cellHeight: CGFloat = 48
    private let spacing: CGFloat = 1

    private let numberOfColumn = 5

    private var supremacy: Supremacy?

    private var titleHeight: CGFloat
    private var shouldDisplayFooter: Bool

    private(set) var isTrimmed = false

    public init(
        supremacy: Supremacy? = nil,
        titleHeight: CGFloat,
        shouldDisplayFooter: Bool)
    {
        self.supremacy = supremacy
        self.titleHeight = titleHeight
        self.shouldDisplayFooter = shouldDisplayFooter
        super.init()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func prepare() {
        scrollDirection = .vertical
        register(Line.self, forDecorationViewOfKind: "Line")

        super.prepare()

        setupItemAttributes()
        setupSupplementary()
        setupTitleAttributes()
    }

    public func setSupremacy(_ supremacy: Supremacy) {
        self.supremacy = supremacy
        invalidateLayout()
    }

    public func toggleTrimmed() {
        isTrimmed.toggle()
        invalidateLayout()
    }
}

// MARK: - Setup

extension CorrectScoreFlowLayout {
    private var fractionalWidth: CGFloat {
        getFractionalWidth(numberOfColumn: numberOfColumn, spacing: spacing)
    }

    private func setupTitleAttributes() {
        guard let supremacy else { return }

        var x: CGFloat = 0

        supremacy.calculator
            .enumerated()
            .forEach { index, value in
                let width = (fractionalWidth + spacing) * value - spacing
                let indexPath = IndexPath(row: index, section: 0)

                let attributes = UICollectionViewLayoutAttributes(
                    forDecorationViewOfKind: "Line",
                    with: indexPath)

                attributes.frame = .init(
                    x: x,
                    y: supplementaryHeight,
                    width: width,
                    height: titleHeight)

                decorationAttributes[indexPath] = attributes

                // First title do not have line
                if index > 0 {
                    setupLineAttributes(x: x - spacing, at: index)
                }

                x += width + spacing
            }
    }

    private func setupLineAttributes(x: CGFloat, at index: Int) {
        let height = shouldDisplayFooter ?
            collectionViewContentSize.height :
            [collectionViewContentSize.height, collectionView?.frame.height ?? 0].max() ?? 0

        // draw, away count = 2
        let indexPath = IndexPath(row: index + 2, section: 0)
        let attributes = UICollectionViewLayoutAttributes(
            forDecorationViewOfKind: "Line",
            with: indexPath)

        attributes.zIndex = 5

        attributes.frame = .init(
            x: x,
            y: 0,
            width: 1,
            height: height)

        decorationAttributes[indexPath] = attributes
    }

    private func setupItemAttributes() {
        let count = isTrimmed ? ([itemsCount, 10].min() ?? 0) : itemsCount

        for item in 0..<count {
            let indexPath = IndexPath(row: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = getOddsFrame(at: indexPath)

            itemAttributes[indexPath] = attributes
        }
    }

    private func setupSupplementary() {
        Supply.allCases.forEach {
            let attributes = UICollectionViewLayoutAttributes(
                forSupplementaryViewOfKind: $0.rawValue,
                with: [0, 0])

            attributes.zIndex = 10

            switch $0 {
            case .header:
                attributes.frame = .init(
                    x: 0,
                    y: 0,
                    width: collectionViewSize.width,
                    height: supplementaryHeight)

            case .footer:
                guard shouldDisplayFooter else { return }
                attributes.frame = .init(
                    x: 0,
                    y: itemAttributes.values
                        .map(\.frame.maxY)
                        .max() ?? 0,
                    width: collectionViewSize.width,
                    height: supplementaryHeight)
            }

            supplementaryAttributes[$0.rawValue] = attributes
        }
    }

    private func getOddsFrame(at indexPath: IndexPath) -> CGRect {
        let fixedIndex = indexPath.row

        // Need to plus title row
        let row = CGFloat(fixedIndex / numberOfColumn) + 1
        let column = CGFloat(fixedIndex % numberOfColumn)

        let width = fractionalWidth
        let height = cellHeight

        let x = column * (width + spacing)

        // Adjust y for odds first row
        let y = row * (height + spacing) + (titleHeight - height) + supplementaryHeight - spacing

        return .init(
            x: x,
            y: y,
            width: width,
            height: height)
    }
}

// MARK: - Decoration

extension CorrectScoreFlowLayout {
    class Line: UICollectionReusableView {
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .systemGreen
        }

        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

#if swift(>=5.9)
    @available(iOS 14.0, *)
    private class CorrectScoreFlowLayoutDemo: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
        typealias Supply = CorrectScoreFlowLayout.Supply

        lazy var collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: flowLayout)

        let flowLayout = CorrectScoreFlowLayout(
            supremacy: .home,
            titleHeight: 24,
            shouldDisplayFooter: true)

        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, String>.init { cell, indexPath, _ in
            cell.backgroundColor = .gray
            cell.contentView.tag = indexPath.row
        }

        lazy var headerRegistration = collectionView.sr
            .supplementaryRegistration(type: .custom(Supply.header.rawValue)) {
                $0.backgroundColor = .systemPink
                return $0
            }

        lazy var footerRegistration = collectionView.sr
            .supplementaryRegistration(type: .custom(Supply.footer.rawValue)) {
                $0.backgroundColor = .systemBlue
                return $0
            }

        override func viewDidLoad() {
            super.viewDidLoad()

            view.backgroundColor = .white

            _ = headerRegistration
            _ = footerRegistration

            collectionView.sr
                .dataSource(self)
                .delegate(self)
                .add(to: view)
                .makeConstraints { make in
                    make.top.equalTo(view.snp.topMargin)
                    make.bottom.equalTo(view.snp.bottomMargin)
                    make.right.left.equalToSuperview()
                }

            setOption()
        }

        func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
            31
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: "")
        }

        func collectionView(
            _ collectionView: UICollectionView,
            viewForSupplementaryElementOfKind kind: String,
            at indexPath: IndexPath)
            -> UICollectionReusableView
        {
            switch Supply(rawValue: kind) {
            case .header:
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            case .footer:
                return collectionView.dequeueConfiguredReusableSupplementary(using: footerRegistration, for: indexPath)
            default:
                return .init()
            }
        }

        func setOption() {
            navigationItem.rightBarButtonItem = .init(
                title: "Supremacy",
                style: .plain,
                target: self,
                action: #selector(alert))
        }

        @objc
        func alert() {
            let actionSheet = UIAlertController(title: "Choose Option", message: nil, preferredStyle: .actionSheet)

            actionSheet.addAction(UIAlertAction(title: "Home", style: .default, handler: { [weak self] _ in
                self?.flowLayout.setSupremacy(.home)
            }))

            actionSheet.addAction(UIAlertAction(title: "Draw", style: .default, handler: { [weak self] _ in
                self?.flowLayout.setSupremacy(.draw)
            }))

            actionSheet.addAction(UIAlertAction(title: "Away", style: .default, handler: { [weak self] _ in
                self?.flowLayout.setSupremacy(.away)
            }))

            actionSheet.addAction(UIAlertAction(title: "Trimmed", style: .default, handler: { [weak self] _ in
                self?.flowLayout.toggleTrimmed()
            }))

            present(actionSheet, animated: true, completion: nil)
        }
    }

    @available(iOS 17.0, *)
    #Preview {
        UINavigationController(rootViewController: CorrectScoreFlowLayoutDemo())
    }
#endif
