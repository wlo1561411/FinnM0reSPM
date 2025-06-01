import UIKit

public class LeftCollectionFlowLayout: UICollectionViewFlowLayout {
    /// 強制指定 layoutAttributesForElements 的高度範圍
    ///
    /// 預設情況下 UICollectionViewFlowLayout 只會針對可見範圍 layout
    ///
    /// 強制 layout 更多元素，以支援自適應高度等需求
    var estimatedLayoutHeight: CGFloat?

    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var rect = rect

        if let estimatedLayoutHeight {
            rect.size.height = estimatedLayoutHeight
        }

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

