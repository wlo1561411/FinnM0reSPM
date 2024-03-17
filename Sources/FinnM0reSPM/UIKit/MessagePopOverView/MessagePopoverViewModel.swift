import Foundation

extension MessagePopoverView {
    class ViewModel {
        typealias Style = MessagePopoverView.Style

        private var styles = [Style?]()

        private var didUpdatedData: (() -> Void)?

        var currentIndex: IndexPath?
        var currentCellRect: CGRect?

        func bind(didUpdatedData: (() -> Void)?) {
            self.didUpdatedData = didUpdatedData
        }

        func update(styles: [Style]) {
            self.styles = adjustStyleSource(styles)
            didUpdatedData?()
        }
    }
}

// MARK: - Data Handle

extension MessagePopoverView.ViewModel {
    /// 插入分隔線
    private func adjustStyleSource(_ _styles: [Style]) -> [Style?] {
        var insertedSeparator = [Style?]()

        _styles.enumerated().forEach {
            insertedSeparator.append($0.element)

            // 代表分隔線
            if $0.offset < _styles.count - 1 {
                insertedSeparator.append(nil)
            }
        }

        return insertedSeparator
    }

    func isAllowPopOver(at indexPath: IndexPath) -> Bool {
        if currentIndex == indexPath {
            return false
        }
        return true
    }

    func isHitCurrentCell(in point: CGPoint) -> Bool {
        if let currentCellRect {
            return currentCellRect.contains(point)
        }
        return false
    }

    func getNumberOfItems() -> Int {
        styles.count
    }

    func getStyle(at indexPath: IndexPath) -> Style? {
        guard let style = styles[safe: indexPath.row] else { return nil }
        return style
    }
}
