import Foundation

extension MessagePopoverView {
    class ViewModel {
        private var texts = [String?]()

        private var didUpdatedData: (() -> Void)?

        var currentIndex: IndexPath?
        var currentCellRect: CGRect?

        func bind(didUpdatedData: (() -> Void)?) {
            self.didUpdatedData = didUpdatedData
        }

        func update(texts: [String]) {
            self.texts = adjustSource(texts)
            didUpdatedData?()
        }
    }
}

// MARK: - Data Handle

extension MessagePopoverView.ViewModel {
    /// 插入分隔線
    private func adjustSource(_ texts: [String]) -> [String?] {
        var insertedSeparator: [String?] = [nil]

        texts.enumerated().forEach {
            insertedSeparator.append($0.element)

            // 代表分隔線
            if $0.offset < texts.count - 1 {
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
        texts.count
    }

    func getText(at indexPath: IndexPath) -> String? {
        guard let text = texts[safe: indexPath.row] else { return nil }
        return text
    }
}
