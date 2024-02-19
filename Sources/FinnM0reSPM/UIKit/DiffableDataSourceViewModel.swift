import Combine
import UIKit

@available(iOS 14.0, *)
public protocol DiffableDataSourceViewModel {
    associatedtype Section: Hashable
    associatedtype Element: Hashable

    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Element>

    var snapshotSubject: CurrentValueSubject<Snapshot?, Never> { get }
}

@available(iOS 14.0, *)
public extension DiffableDataSourceViewModel {
    var snapshotPublisher: AnyPublisher<Snapshot, Never> {
        snapshotSubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}
