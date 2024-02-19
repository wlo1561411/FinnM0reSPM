import RxCocoa
import RxSwift
import UIKit

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
