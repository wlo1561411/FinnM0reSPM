import Foundation

protocol DynamicSelectable: Equatable { }

enum DynamicSelectResult {
    case existed
    case changed
    /// Empty array
    case unexpected
}

extension Array where Element: DynamicSelectable {
    @discardableResult
    mutating func dynamicSet(_ elements: [Element], current: inout Element?) -> DynamicSelectResult {
        self = elements
        
        if let current = current, elements.contains(current) {
            return .existed
        }
        
        current = elements.first
        return current == nil ? .unexpected : .changed
    }
    
    @discardableResult
    mutating func dynamicSet(_ elements: [Element], current: inout Element) -> DynamicSelectResult {
        self = elements
        
        if !elements.contains(current) {
            current = elements.first ?? current
            return elements.first == nil ? .unexpected : .changed
        }
        
        return .existed
    }
}
