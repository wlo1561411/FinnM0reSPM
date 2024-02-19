import Foundation

public extension Array {
    subscript(safe index: Int?) -> Element? {
        guard let index else { return nil }

        if index < 0 || index > count - 1 {
            return nil
        } else {
            return self[index]
        }
    }

    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

public extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
