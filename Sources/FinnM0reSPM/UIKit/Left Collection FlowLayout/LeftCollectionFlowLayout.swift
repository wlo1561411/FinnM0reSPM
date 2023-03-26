import UIKit

class LeftCollectionFlowLayout: UICollectionViewFlowLayout {
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    let attributes = super.layoutAttributesForElements(in: rect)

    var leftMargin = sectionInset.left
    var maxY: CGFloat = -1.0

    attributes?.forEach { layoutAttribute in
      if
        layoutAttribute.representedElementKind == UICollectionView.elementKindSectionFooter ||
        layoutAttribute.representedElementKind == UICollectionView.elementKindSectionHeader
      {
        return
      }

      if layoutAttribute.frame.origin.y >= maxY {
        leftMargin = sectionInset.left
      }

      layoutAttribute.frame.origin.x = leftMargin
      leftMargin += layoutAttribute.frame.width + minimumLineSpacing
      maxY = max(layoutAttribute.frame.maxY, maxY)
    }

    /// Fix scroll to end will disappear
    return attributes?.filter {
      rect.intersects($0.frame)
    }
  }
}
