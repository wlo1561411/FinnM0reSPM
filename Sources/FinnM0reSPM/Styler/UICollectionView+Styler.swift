import Combine
import UIKit

extension Styler where Base: UICollectionView {
    public enum SupplementType {
        case header
        case footer
        case custom(String)

        var kind: String {
            switch self {
            case .header:
                return UICollectionView.elementKindSectionHeader
            case .footer:
                return UICollectionView.elementKindSectionFooter
            case .custom(let value):
                return value
            }
        }
    }

    @discardableResult
    public func register<Cell: UICollectionViewCell>(
        _ cell: Cell.Type,
        identifier: String = "\(Cell.self)")
        -> Self
    {
        base.register(cell.self, forCellWithReuseIdentifier: identifier)
        return self
    }

    @discardableResult
    public func register<Supplementary: UICollectionReusableView>(
        _ supplementary: Supplementary.Type,
        type: SupplementType,
        identifier: String = "")
        -> Self
    {
        let _identifier = identifier.isEmpty ? "\(type.kind)\(Supplementary.self)" : identifier
        base.register(
            supplementary.self,
            forSupplementaryViewOfKind: type.kind,
            withReuseIdentifier: _identifier)
        return self
    }
}

// MARK: - Layout

extension Styler where Base: UICollectionView {
    @available(iOS 14.0, *)
    public func justTitleRegistration(
        type: SupplementType,
        viewTag: Int = 99,
        initialize: @escaping (UILabel) -> Void,
        configure: ((UILabel) -> Void)? = nil)
        -> UICollectionView.SupplementaryRegistration<UICollectionReusableView>
    {
        supplementaryRegistration(
            type: type,
            viewTag: viewTag)
        { reusable in
            let label = UILabel()
            label.sr
                .add(to: reusable)
                .makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            initialize(label)
            return label

        } configure: { view in
            guard let label = view as? UILabel else { return }
            configure?(label)
        }
    }

    @available(iOS 14.0, *)
    public func supplementaryRegistration(
        type: SupplementType,
        viewTag: Int = 99,
        initialize: @escaping (UICollectionReusableView) -> UIView,
        configure: ((UIView) -> Void)? = nil)
        -> UICollectionView.SupplementaryRegistration<UICollectionReusableView>
    {
        .init(
            elementKind: type.kind)
        { supplementaryView, _, _ in
            if let tagView = supplementaryView.subviews.first(where: { $0.tag == viewTag }) {
                configure?(tagView)
            }
            else {
                let tagView = initialize(supplementaryView)
                tagView.tag = viewTag
                configure?(tagView)
            }
        }
    }

    @available(iOS 14.0, *)
    public func generateDataSource<I: Hashable, M: Hashable>(
        cell: UICollectionView.CellRegistration<some UICollectionViewCell, M>,
        header: UICollectionView.SupplementaryRegistration<UICollectionReusableView>? = nil,
        footer: UICollectionView.SupplementaryRegistration<UICollectionReusableView>? = nil)
        -> UICollectionViewDiffableDataSource<I, M>
    {
        let cell = cell
        let header = header
        let footer = footer

        let dataSource = UICollectionViewDiffableDataSource<I, M>(collectionView: base) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: cell,
                for: indexPath,
                item: item)
        }

        setSupplementaryView(dataSource, header: header, footer: footer)

        return dataSource
    }

    @available(iOS 14.0, *)
    public func generateDataSource<I: Hashable, M: Hashable>(
        cellProvider: @escaping (UICollectionView, IndexPath, M) -> UICollectionViewCell?,
        header: UICollectionView.SupplementaryRegistration<UICollectionReusableView>? = nil,
        footer: UICollectionView.SupplementaryRegistration<UICollectionReusableView>? = nil)
        -> UICollectionViewDiffableDataSource<I, M>
    {
        let header = header
        let footer = footer

        let dataSource = UICollectionViewDiffableDataSource<I, M>(collectionView: base, cellProvider: cellProvider)

        setSupplementaryView(dataSource, header: header, footer: footer)

        return dataSource
    }

    @available(iOS 14.0, *)
    private func setSupplementaryView(
        _ dataSource: UICollectionViewDiffableDataSource<some Hashable, some Hashable>,
        header: UICollectionView.SupplementaryRegistration<UICollectionReusableView>? = nil,
        footer: UICollectionView.SupplementaryRegistration<UICollectionReusableView>? = nil)
    {
        guard header != nil || footer != nil
        else { return }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                guard let header else { return .init() }
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: header,
                    for: indexPath)

            case UICollectionView.elementKindSectionFooter:
                guard let footer else { return .init() }
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: footer,
                    for: indexPath)
            default:
                return .init()
            }
        }
    }
}
