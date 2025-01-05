import UIKit

public protocol CycleBannerDataSource: AnyObject {
    func item(collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell
    func numberOfItems() -> Int
}
