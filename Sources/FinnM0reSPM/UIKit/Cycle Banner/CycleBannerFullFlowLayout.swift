import UIKit

public class CycleBannerFullFlowLayout: UICollectionViewFlowLayout {
    private var boundsSize: CGSize = .zero
    private var midX: CGFloat = 0

    public override init() {
        super.init()
        self.scrollDirection = .horizontal
        self.minimumLineSpacing = 0
        self.minimumInteritemSpacing = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 檢查佈局是否需要因邊界變化而重新計算
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    // 準備佈局，計算中點和邊界大小
    public override func prepare() {
        super.prepare()
        boundsSize = collectionView?.bounds.size ?? .zero
        midX = boundsSize.width / 2.0
    }

    // 計算滾動停止後的目標偏移量
    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude

        guard let collectionView = collectionView else { return proposedContentOffset }
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
