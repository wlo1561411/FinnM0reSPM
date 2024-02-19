import Combine
import UIKit

@available(iOS 14.0, *)
public protocol MultipleTabViewModel: AnyObject {
    associatedtype Tab: Hashable

    var tabsSubject: CurrentValueSubject<[Tab], Never> { get }
    var currentTab: Tab? { get set }

    func selectTab(at index: Int)
}

@available(iOS 14.0, *)
extension MultipleTabViewModel {
    public var tabsPublisher: AnyPublisher<[Tab], Never> {
        tabsSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public var displayTabs: [Tab] {
        tabsSubject.value
    }

    public var currentTabIndex: Int {
        displayTabs.firstIndex(where: { $0 == currentTab }) ?? 0
    }

    public func updateTabs(_ tabs: [Tab], force: Bool = false) {
        if force {
            tabsSubject.send([])
        }
        tabsSubject.send(tabs)
    }

    public func selectTab(at index: Int) {
        guard let new = displayTabs[safe: index] else { return }
        currentTab = new
    }
}
