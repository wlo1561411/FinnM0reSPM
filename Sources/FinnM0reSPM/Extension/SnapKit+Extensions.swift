import Foundation
import SnapKit

public extension Constraint {
    var constant: CGFloat? {
        layoutConstraints.first?.constant
    }
}
