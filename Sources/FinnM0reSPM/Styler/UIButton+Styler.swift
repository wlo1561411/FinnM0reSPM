import UIKit

extension Styler where Base: UIButton {
  @discardableResult
  public func font(_ font: UIFont) -> Self {
    base.titleLabel?.font = font
    return self
  }

  @discardableResult
  public func textColor(_ color: UIColor, state: UIControl.State = .normal) -> Self {
    base.setTitleColor(color, for: state)
    return self
  }

  @discardableResult
  public func text(_ text: String?, state: UIControl.State = .normal) -> Self {
    base.setTitle(text, for: state)
    return self
  }
}
