import UIKit

open class BaseCollectionViewFlowLayout: UICollectionViewFlowLayout {
    public var itemAttributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    public var supplementaryAttributes: [String: UICollectionViewLayoutAttributes] = [:]
    public var decorationAttributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]

    override open func prepare() {
        itemAttributes.removeAll()
        supplementaryAttributes.removeAll()
        decorationAttributes.removeAll()
        super.prepare()
    }

    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        collectionView?.bounds.size != newBounds.size
    }

    override public var collectionViewContentSize: CGSize {
        .init(
            width: allAttributes
                .map(\.frame.maxX)
                .max() ?? 0,
            height: allAttributes
                .map(\.frame.maxY)
                .max() ?? 0)
    }

    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        itemAttributes[indexPath]
    }

    override public func layoutAttributesForDecorationView(
        ofKind _: String,
        at indexPath: IndexPath)
        -> UICollectionViewLayoutAttributes?
    {
        decorationAttributes[indexPath]
    }

    override public func layoutAttributesForSupplementaryView(
        ofKind elementKind: String,
        at _: IndexPath)
        -> UICollectionViewLayoutAttributes?
    {
        supplementaryAttributes[elementKind]
    }

    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        allAttributes.filter { $0.frame.intersects(rect) }
    }
}

// MARK: - Data Handle

extension BaseCollectionViewFlowLayout {
    public var collectionViewSize: CGSize {
        collectionView?.frame.size ?? .zero
    }

    public var itemsCount: Int {
        collectionView?.numberOfItems(inSection: 0) ?? 0
    }

    public var allAttributes: [UICollectionViewLayoutAttributes] {
        Array(itemAttributes.values) +
            Array(supplementaryAttributes.values) +
            Array(decorationAttributes.values)
    }

    public func getFractionalWidth(
        numberOfColumn: Int,
        spacing: CGFloat)
        -> CGFloat
    {
        // Remove leading, trailing, items spacing
        (
            collectionViewSize.width -
                (spacing * CGFloat(numberOfColumn - 1))) / CGFloat(numberOfColumn)
    }
}
