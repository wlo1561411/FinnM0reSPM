import UIKit

#warning("Section header footer is not include")
@available(iOS 13.0, *)
public class VerticalCollectionViewLayout: UICollectionViewFlowLayout {
  private var numberOfItemsPerColumn = 2
  private var spacing: CGFloat = 0

  private var itemLayoutSizeFactory: (IndexPath) -> NSCollectionLayoutSize

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

  override public var collectionViewContentSize: CGSize {
    var totalWidth: CGFloat = 0
    var totalHeight: CGFloat = 0

    let numberOfSections = collectionView?.numberOfSections ?? 0

    for section in 0..<numberOfSections {
      let numberOfRows =
        ceil(CGFloat(collectionView?.numberOfItems(inSection: section) ?? 0) / CGFloat(numberOfItemsPerColumn))

      var rowWidths: [CGFloat] = Array(repeating: 0, count: Int(numberOfRows))

      for row in 0..<Int(numberOfRows) {
        for column in 0..<numberOfItemsPerColumn {
          let item = row * numberOfItemsPerColumn + column

          if item < collectionView?.numberOfItems(inSection: section) ?? 0 {
            let indexPath = IndexPath(item: item, section: section)
            let width = itemWidth(at: indexPath)
            rowWidths[row] += width + spacing
          }
        }
      }

      // Subtract the spacing of the last item
      totalWidth = max(totalWidth, rowWidths.reduce(0, +) - spacing)

      var maxHeightInColumn: CGFloat = 0

      for column in 0..<numberOfItemsPerColumn {
        let indexPath = IndexPath(item: column, section: section)
        let height = itemHeight(at: indexPath)

        maxHeightInColumn = max(maxHeightInColumn, height)
      }

      // Subtract the spacing of the last item
      totalHeight += CGFloat(numberOfItemsPerColumn) * (maxHeightInColumn + spacing) - spacing
    }

    return CGSize(width: totalWidth, height: totalHeight)
  }

  override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)

    let column = indexPath.row % numberOfItemsPerColumn
    let row = indexPath.row / numberOfItemsPerColumn

    let itemWidth = itemWidth(at: indexPath)
    let itemHeight = itemHeight(at: indexPath)

    let x = CGFloat(row) * (itemWidth + spacing)
    let y = CGFloat(column) * (itemHeight + spacing)

    attributes.frame = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)

    return attributes
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
