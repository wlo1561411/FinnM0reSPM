import Foundation
import SwiftUI
import UIKit

@available(iOS 14, *)
public protocol InputType: AnyObject {
  associatedtype T: InputRegex

  var regex: T { get }
  var keyboardType: UIKeyboardType { get }
  var disablePaste: Bool { get }

  func format(_ oldText: String, _ newText: String, _ text: Binding<String>)
  func onEditEnd(_ text: Binding<String>)
}

@available(iOS 14, *)
public extension InputType {
  var functionalConfig: (PasteableTextField) -> Void {
    { [weak self] textField in
      guard let self else { return }

      textField.keyboardType = self.keyboardType
      textField.disablePaste = self.disablePaste
    }
  }
}
