import UIKit

public class CycleBannerScaledFlowLayout: UICollectionViewFlowLayout {
    private var boundsSize: CGSize = .zero
    private var midX: CGFloat = 0

    var scale: CGFloat = 0.9

    public override init() {
        super.init()
        self.scrollDirection = .horizontal
        self.minimumLineSpacing = 0
        self.minimumInteritemSpacing = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        true
    }

    public override func prepare() {
        super.prepare()
        boundsSize = collectionView?.bounds.size ?? .zero
        midX = boundsSize.width / 2.0
    }

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // 複製原始佈局屬性以進行修改
        guard let array = super.layoutAttributesForElements(in: rect)?.map({ $0.copy() as! UICollectionViewLayoutAttributes }) else {
            return nil
        }

        for attributes in array {
            attributes.transform = .identity

            // 跳過不在範圍內的元素
            if !attributes.frame.intersects(rect) {
                continue
            }

            guard let collectionView = collectionView else { continue }
            let contentOffset = collectionView.contentOffset
            let itemCenter = CGPoint(x: attributes.center.x - contentOffset.x, y: attributes.center.y - contentOffset.y)
            let distance = abs(midX - itemCenter.x)

            // 計算縮放比例
            // 將 item 與 中點 的距離正規化為 [0, 1] 的範圍
            // 0 表示完全位於中點, 1 表示位於邊緣
            let normalized = distance / midX

            let zoom = scale + (1 - scale) * (1 - normalized)

            // 設置縮放效果
            attributes.transform = CGAffineTransform(scaleX: zoom, y: zoom)
        }

        return array
    }

    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }
        let targetRect = CGRect(x: collectionView.contentOffset.x, y: 0, width: boundsSize.width, height: boundsSize.height)

        guard let array = super.layoutAttributesForElements(in: targetRect) else {
            return proposedContentOffset
        }

        var offsetAdjustment: CGFloat = 10000

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
