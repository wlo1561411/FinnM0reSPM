import UIKit
import SnapKit

extension Styler where Base: UIView {
  
  @discardableResult
  public func makeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) -> Self {
    self.base.snp.makeConstraints(closure)
    return self
  }
}
