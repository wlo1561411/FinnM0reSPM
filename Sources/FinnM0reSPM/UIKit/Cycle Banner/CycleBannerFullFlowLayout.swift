import UIKit

public class CycleBannerFullFlowLayout: 
    UICollectionViewFlowLayout,
    CycleBannerFlowLayout
{
    private var boundsSize: CGSize = .zero
    private var midX: CGFloat = 0

    public init(itemSize: CGSize) {
        super.init()
        self.scrollDirection = .horizontal
        self.minimumLineSpacing = 0
        self.minimumInteritemSpacing = 0
        self.itemSize = itemSize
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func shouldInvalidateLayout(forBoundsChange _: CGRect) -> Bool {
        true
    }

    override public func prepare() {
        super.prepare()
        boundsSize = collectionView?.bounds.size ?? .zero
        midX = boundsSize.width / 2.0
    }

    // 計算滾動停止後的目標偏移量
    override public func targetContentOffset(
        forProposedContentOffset proposedContentOffset: CGPoint,
        withScrollingVelocity _: CGPoint)
        -> CGPoint
    {
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude

        guard let collectionView else { return proposedContentOffset }
        let targetRect = CGRect(x: collectionView.contentOffset.x, y: 0.0, width: boundsSize.width, height: boundsSize.height)

        guard let array = super.layoutAttributesForElements(in: targetRect) else {
            return proposedContentOffset
        }

        let proposedCenterX = proposedContentOffset.x + midX

        // 找到最接近中心點的元素
        for attributes in array {
            let distance = attributes.center.x - proposedCenterX
            if abs(distance) < abs(offsetAdjustment) {
                offsetAdjustment = distance
            }
        }

        // 計算調整後的偏移量
        let desiredPoint = CGPoint(x: max(0.0, proposedContentOffset.x + offsetAdjustment), y: proposedContentOffset.y)

        return desiredPoint
    }
}
