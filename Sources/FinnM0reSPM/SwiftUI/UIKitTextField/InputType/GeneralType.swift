import Foundation
import SwiftUI

@available(iOS 14, *)
public class GeneralType: InputType {
  private let maxLength: Int?

  public let regex: GeneralRegex
  public let keyboardType: UIKeyboardType
  public let disablePaste: Bool

  public init(
    regex: GeneralRegex = .all,
    keyboardType: UIKeyboardType = .default,
    disablePaste: Bool = false,
    maxLength: Int? = nil)
  {
    self.regex = regex
    self.keyboardType = keyboardType
    self.disablePaste = disablePaste
    self.maxLength = maxLength
  }

  public func format(_ oldText: String, _ newText: String, _ text: Binding<String>) {
    var newText = newText

    guard newText ~= regex.pattern
    else {
      text.wrappedValue = oldText
      return
    }

    if
      let maxLength,
      newText.count >= maxLength
    {
      newText = String(newText[..<newText.index(newText.startIndex, offsetBy: maxLength)])
    }

    text.wrappedValue = newText
  }

  public func onEditEnd(_: Binding<String>) { }
}
