import Foundation

extension Bool {
  struct False: DefaultCodableValue {
    static let defaultValue = false
  }
}

extension Double {
  struct Zero: DefaultCodableValue {
    static let defaultValue: Double = 0
  }
}
