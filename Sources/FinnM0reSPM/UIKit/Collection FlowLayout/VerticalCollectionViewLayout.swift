import UIKit

@available(iOS 13.0, *)
open class VerticalCollectionViewLayout: BaseCollectionViewFlowLayout {
  public var numberOfItemsPerColumn = 2
  public var itemLayoutSize: NSCollectionLayoutSize = .init(widthDimension: .absolute(0), heightDimension: .absolute(0))
  public var spacing: CGFloat = 0

  public init(
    numberOfItemsPerColumn: Int,
    itemLayoutSize: NSCollectionLayoutSize,
    spacing: CGFloat = 0)
  {
    super.init()
    self.numberOfItemsPerColumn = numberOfItemsPerColumn
    self.itemLayoutSize = itemLayoutSize
    self.spacing = spacing
  }

  public required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func prepare() {
    super.prepare()
    setupItemsAttributes()
  }

  private func setupItemsAttributes() {
    (0..<itemsCount).forEach {
      let indexPath = IndexPath(row: $0, section: 0)
      let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)

      let column = indexPath.row % numberOfItemsPerColumn
      let row = indexPath.row / numberOfItemsPerColumn

      let width = itemLayoutSize.widthDimension.value(collectionView)
      let height = itemLayoutSize.heightDimension.value(collectionView)

      let x = CGFloat(row) * (width + spacing)
      let y = CGFloat(column) * (height + spacing)

      attributes.frame = CGRect(x: x, y: y, width: width, height: height)

      itemAttributes[indexPath] = attributes
    }
  }
}

@available(iOS 13.0, *)
extension NSCollectionLayoutDimension {
  public func value(_ collectionView: UICollectionView?) -> CGFloat {
    guard let collectionView else { return 0 }

    if isAbsolute || isEstimated {
      return dimension
    }
    else if isFractionalWidth {
      return collectionView.frame.size.width * dimension
    }
    else if isFractionalHeight {
      return collectionView.frame.size.height * dimension
    }
    else {
      return 0
    }
  }
}
