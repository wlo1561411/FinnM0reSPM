import Foundation

extension Bool {
  struct Custom: DefaultCodableValue {
    static var defaultValue = false
    
    init (_ customValue: Bool) {
      Self.defaultValue = customValue
    }
  }
  
  static let `false` = Custom(false)
}

extension String {
  struct Custom: DefaultCodableValue {
    static var defaultValue = ""
    
    init (_ customValue: String) {
      Self.defaultValue = customValue
    }
  }
}
