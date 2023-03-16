import Foundation
import SnapKit

extension Constraint {
  public var constant: CGFloat? {
    layoutConstraints.first?.constant
  }
}
