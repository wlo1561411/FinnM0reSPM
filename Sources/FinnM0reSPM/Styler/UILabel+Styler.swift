import UIKit

extension Styler where Base: UILabel {
  @discardableResult
  public func font(_ font: UIFont) -> Self {
    base.font = font
    return self
  }

  @discardableResult
  public func textColor(_ color: UIColor) -> Self {
    base.textColor = color
    return self
  }

  @discardableResult
  public func text(_ text: String?) -> Self {
    base.text = text
    return self
  }
  
  @discardableResult
  public func textAlignment(_ textAlignment: NSTextAlignment) -> Self {
    base.textAlignment = textAlignment
    return self
  }
}
