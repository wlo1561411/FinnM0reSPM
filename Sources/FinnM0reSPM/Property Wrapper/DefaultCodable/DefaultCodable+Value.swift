import Foundation

extension Bool {
  struct Custom: DefaultValue {
    static var defaultValue = false
    
    init (_ customValue: Bool) {
      Self.defaultValue = customValue
    }
  }
  
  static let `false` = Custom(false)
}

extension String {
  struct Custom: DefaultValue {
    static var defaultValue = ""
    
    init (_ customValue: String) {
      Self.defaultValue = customValue
    }
  }
}

extension DefaultValue where Self == Bool.Custom {
    static var `false`: Bool.Custom { .init(false) }
}

// MARK: - Example

struct Model_Example {
    @Default(.false) var a: Bool
    @Default(String.Custom("test")) var s: String
}
