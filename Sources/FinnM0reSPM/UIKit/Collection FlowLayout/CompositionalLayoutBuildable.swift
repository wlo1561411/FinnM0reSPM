import UIKit

public protocol CompositionalLayoutBuildable { }

extension CompositionalLayoutBuildable {
    public func layoutSize(
        width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension)
        -> NSCollectionLayoutSize
    {
        .init(widthDimension: width, heightDimension: height)
    }

    public func item(
        width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension,
        supplementaryItems: [NSCollectionLayoutSupplementaryItem] = [],
        contentInset: NSDirectionalEdgeInsets? = nil)
        -> NSCollectionLayoutItem
    {
        let item = NSCollectionLayoutItem(
            layoutSize: layoutSize(width: width, height: height),
            supplementaryItems: supplementaryItems)

        if let contentInset {
            item.contentInsets = contentInset
        }

        return item
    }

    public func group(
        axis: NSLayoutConstraint.Axis,
        width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension,
        subitems: [NSCollectionLayoutItem],
        spacing: NSCollectionLayoutSpacing? = nil,
        contentInset: NSDirectionalEdgeInsets? = nil)
        -> NSCollectionLayoutGroup
    {
        let group: NSCollectionLayoutGroup

        switch axis {
        case .horizontal:
            group = .horizontal(layoutSize: layoutSize(width: width, height: height), subitems: subitems)
            group.interItemSpacing = spacing
        case .vertical:
            group = .vertical(layoutSize: layoutSize(width: width, height: height), subitems: subitems)
            group.interItemSpacing = spacing
        @unknown default:
            fatalError()
        }

        if let contentInset {
            group.contentInsets = contentInset
        }

        return group
    }

    public func group(
        axis: NSLayoutConstraint.Axis,
        width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension,
        repeatingSubitem: NSCollectionLayoutItem,
        count: Int,
        spacing: NSCollectionLayoutSpacing? = nil,
        contentInset: NSDirectionalEdgeInsets? = nil)
        -> NSCollectionLayoutGroup
    {
        let group: NSCollectionLayoutGroup
        switch axis {
        case .horizontal:
            group = .horizontal(layoutSize: layoutSize(width: width, height: height), subitem: repeatingSubitem, count: count)
        case .vertical:
            group = .vertical(layoutSize: layoutSize(width: width, height: height), subitem: repeatingSubitem, count: count)
        @unknown default:
            fatalError()
        }

        group.interItemSpacing = spacing

        if let contentInset {
            group.contentInsets = contentInset
        }

        return group
    }

    public func supplementaryItem(
        width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension,
        elementKind: String,
        alignment: NSRectAlignment = .top,
        absoluteOffset: CGPoint = .zero)
        -> NSCollectionLayoutBoundarySupplementaryItem
    {
        .init(
            layoutSize: layoutSize(width: width, height: height),
            elementKind: elementKind,
            alignment: alignment,
            absoluteOffset: absoluteOffset)
    }

    public func section(
        group: NSCollectionLayoutGroup,
        spacing: CGFloat? = nil,
        contentInset: NSDirectionalEdgeInsets? = nil)
        -> NSCollectionLayoutSection
    {
        let section = NSCollectionLayoutSection(group: group)

        if let spacing {
            section.interGroupSpacing = spacing
        }

        if let contentInset {
            section.contentInsets = contentInset
        }

        return section
    }
}
