import RxCocoa
import RxSwift
import UIKit

extension Styler where Base: UICollectionView {
  public enum SupplementType {
    case header
    case footer

    var kind: String {
      switch self {
      case .header:
        return UICollectionView.elementKindSectionHeader
      case .footer:
        return UICollectionView.elementKindSectionFooter
      }
    }
  }

  @discardableResult
  public func register<Cell: UICollectionViewCell>(
    _ cell: Cell.Type,
    identifier: String = "\(Cell.self)")
    -> Self
  {
    base.register(cell.self, forCellWithReuseIdentifier: identifier)
    return self
  }

  @discardableResult
  public func register<Supplementary: UICollectionReusableView>(
    _ supplementary: Supplementary.Type,
    type: SupplementType,
    identifier: String = "\(Supplementary.self)")
    -> Self
  {
    base.register(
      supplementary.self,
      forSupplementaryViewOfKind: type.kind,
      withReuseIdentifier: type.kind + identifier)
    return self
  }
}
