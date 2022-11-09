import SnapKit
import Foundation

public extension Constraint {
    
    var constant: CGFloat? {
        layoutConstraints.first?.constant
    }
}
