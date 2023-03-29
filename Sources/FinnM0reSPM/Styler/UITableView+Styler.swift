import RxCocoa
import RxSwift
import UIKit

extension Styler where Base: UITableView {
  @discardableResult
  public func register<Cell: UITableViewCell>(
    _ cell: Cell.Type,
    identifier: String = "\(Cell.self)")
    -> Self
  {
    base.register(cell.self, forCellReuseIdentifier: identifier)
    return self
  }

  @discardableResult
  public func register<Supplementary: UITableViewHeaderFooterView>(
    _ supplementary: Supplementary.Type,
    identifier: String = "\(Supplementary.self)")
    -> Self
  {
    base.register(supplementary.self, forHeaderFooterViewReuseIdentifier: identifier)
    return self
  }
}

// MARK: - Rx

extension Styler where Base: UITableView {
  @discardableResult
  public func observe<Observable, Sequence>(
    from elements: Observable,
    factory: @escaping (UITableView, Int, Sequence.Element) -> UITableViewCell,
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
    Cell: UITableViewCell
  >(
    from elements: Observable,
    identifier: String = "\(Cell.self)",
    type: Cell.Type,
    configure: @escaping (Int, Sequence.Element, Cell) -> Void,
    dispose: DisposeBag)
    -> Self
    where Observable.Element == Sequence
  {
    elements
      .bind(to: base.rx.items(cellIdentifier: identifier, cellType: type.self))(configure)
      .disposed(by: dispose)
    return self
  }

  @discardableResult
  public func observe<
    Observable: ObservableType,
    Sequence: Swift.Sequence,
    DataSource: RxTableViewDataSourceType & UITableViewDataSource
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
