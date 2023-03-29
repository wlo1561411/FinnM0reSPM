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

// MARK: - Rx

extension Styler where Base: UICollectionView {
  @discardableResult
  public func observe<Observable, Sequence>(
    from elements: Observable,
    factory: @escaping (UICollectionView, Int, Sequence.Element) -> UICollectionViewCell,
    dispose: DisposeBag)
    -> Self
    where
    Observable: ObservableType,
    Sequence: Swift.Sequence,
    Observable.Element == Sequence
  {
    elements
      .bind(to: base.rx.items)(factory)
      .disposed(by: dispose)
    return self
  }

  @discardableResult
  public func observe<
    Observable: ObservableType,
    Sequence: Swift.Sequence,
    Cell: UICollectionViewCell
  >(
    from elements: Observable,
    identify: String = "\(Cell.self)",
    type: Cell.Type,
    configure: @escaping (Int, Sequence.Element, Cell) -> Void,
    dispose: DisposeBag)
    -> Self
    where Observable.Element == Sequence
  {
    elements
      .bind(to: base.rx.items(cellIdentifier: identify, cellType: type.self))(configure)
      .disposed(by: dispose)
    return self
  }

  @discardableResult
  public func observe<
    Observable: ObservableType,
    Sequence: Swift.Sequence,
    DataSource: RxCollectionViewDataSourceType & UICollectionViewDataSource
  >(
    from elements: Observable,
    dataSource: DataSource,
    dispose: DisposeBag)
    -> Self
    where
    Observable.Element == Sequence,
    DataSource.Element == Sequence
  {
    elements
      .bind(to: base.rx.items(dataSource: dataSource))
      .disposed(by: dispose)
    return self
  }
}
