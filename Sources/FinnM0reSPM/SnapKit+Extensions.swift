import SnapKit
import Foundation

extension Constraint {
    
    var constant: CGFloat? {
        layoutConstraints.first?.constant
    }
}
