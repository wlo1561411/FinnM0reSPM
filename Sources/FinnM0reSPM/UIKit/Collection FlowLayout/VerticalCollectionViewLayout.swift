import UIKit

@available(iOS 13.0, *)
// Only support one section
public class VerticalCollectionViewLayout: UICollectionViewFlowLayout {
  private var numberOfItemsPerColumn = 2
  private var spacing: CGFloat = 0

  private var contentSize = CGSize.zero
  private var itemAttributes = [IndexPath: UICollectionViewLayoutAttributes]()

  private var itemLayoutSizeFactory: (IndexPath) -> NSCollectionLayoutSize

  public init(
    numberOfItemsPerColumn: Int,
    itemLayoutSize: NSCollectionLayoutSize,
    spacing: CGFloat = 0)
  {
    self.itemLayoutSizeFactory = { _ in itemLayoutSize }
    super.init()
    self.numberOfItemsPerColumn = numberOfItemsPerColumn
    self.spacing = spacing
  }

  public init(
    numberOfItemsPerColumn: Int,
    spacing: CGFloat = 0,
    itemLayoutSizeFactory: @escaping (IndexPath) -> NSCollectionLayoutSize)
  {
    self.itemLayoutSizeFactory = itemLayoutSizeFactory
    super.init()
    self.numberOfItemsPerColumn = numberOfItemsPerColumn
    self.spacing = spacing
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func prepare() {
    itemAttributes.removeAll()
    contentSize = .zero

    super.prepare()

    contentSize = calculateContentSize()
  }

  override public var collectionViewContentSize: CGSize {
    contentSize
  }

  override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    guard itemAttributes[indexPath] == nil
    else {
      return itemAttributes[indexPath]
    }

    return getItemAttributes(at: indexPath)
  }

  override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard let originalAttributes = super.layoutAttributesForElements(in: rect)
    else { return nil }

    let attributesCopy = originalAttributes
      .compactMap { $0.copy() as? UICollectionViewLayoutAttributes }

    attributesCopy.forEach {
      guard
        $0.representedElementKind == nil,
        let newAttributes = layoutAttributesForItem(at: $0.indexPath)
      else { return }

      $0.frame = newAttributes.frame
    }

    return attributesCopy
  }
}

// MARK: - Data Handle

@available(iOS 13.0, *)
extension VerticalCollectionViewLayout {
  private var itemsCount: Int {
    collectionView?.numberOfItems(inSection: 0) ?? 0
  }

  private func itemWidth(at index: IndexPath) -> CGFloat {
    getLayoutValue(
      itemLayoutSizeFactory(index).widthDimension,
      parentViewSize: collectionView?.frame.size ?? .zero)
  }

  private func itemHeight(at index: IndexPath) -> CGFloat {
    getLayoutValue(
      itemLayoutSizeFactory(index).heightDimension,
      parentViewSize: collectionView?.frame.size ?? .zero)
  }

  private func getItemAttributes(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)

    let column = indexPath.row % numberOfItemsPerColumn
    let row = indexPath.row / numberOfItemsPerColumn

    let itemWidth = itemWidth(at: indexPath)
    let itemHeight = itemHeight(at: indexPath)

    let x = CGFloat(row) * (itemWidth + spacing)
    let y = CGFloat(column) * (itemHeight + spacing)

    attributes.frame = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)

    itemAttributes[indexPath] = attributes

    return attributes
  }

  private func calculateContentSize() -> CGSize {
      let rows = ceil(CGFloat(itemsCount) / CGFloat(numberOfItemsPerColumn))
      let totalWidth = (0 ..< Int(rows))
          .map {
              itemWidth(at: [0, $0]) + spacing
          }
          .reduce(0, +) - spacing

      let columns = numberOfItemsPerColumn
      let totalHeight = (0 ..< columns)
          .map {
              itemHeight(at: [0, $0]) + spacing
          }
          .reduce(0, +) - spacing
      
      return CGSize(width: totalWidth, height: totalHeight)
  }

  private func getLayoutValue(_ layout: NSCollectionLayoutDimension, parentViewSize: CGSize) -> CGFloat {
    if layout.isAbsolute || layout.isEstimated {
      return layout.dimension
    }
    else if layout.isFractionalWidth {
      return parentViewSize.width * layout.dimension
    }
    else if layout.isFractionalHeight {
      return parentViewSize.height * layout.dimension
    }
    else {
      return 0
    }
  }
}
