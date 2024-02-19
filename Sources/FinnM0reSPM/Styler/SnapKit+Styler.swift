import SnapKit
import UIKit

public extension Styler where Base: UIView {
    @discardableResult
    func makeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) -> Self {
        base.snp.makeConstraints(closure)
        return self
    }

    @discardableResult
    func updateConstraints(_ closure: (_ make: ConstraintMaker) -> Void) -> Self {
        base.snp.updateConstraints(closure)
        return self
    }

    @discardableResult
    func remakeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) -> Self {
        base.snp.remakeConstraints(closure)
        return self
    }

    @discardableResult
    func removeConstraints(_ closure: ((_ make: ConstraintMaker) -> Void)? = nil) -> Self {
        if let closure {
            base.snp.remakeConstraints(closure)
        } else {
            base.snp.removeConstraints()
        }
        return self
    }
}
