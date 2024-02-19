import Foundation

public protocol InputRegex {
    var pattern: String { get }
}

public enum GeneralRegex: InputRegex {
    case all
    case email
    case number
    case numberAndEnglish

    public var pattern: String {
        switch self {
        case .all:
            return "^[\\s\\S]*$"
        case .email:
            return "^[0-9a-zA-Z_@\\-.\\/]*$"
        case .number:
            return "^[0-9]*$"
        case .numberAndEnglish:
            return "^[0-9a-zA-Z]*$"
        }
    }
}

public enum CurrencyRegex: InputRegex, Equatable {
    case noDecimal
    case withDecimal(Int)

    public var pattern: String {
        switch self {
        case .noDecimal:
            return "^[0-9,]*$"
        case .withDecimal(let maxDigits):
            return "^[0-9,]*([.][0-9]{0,\(maxDigits)})?$"
        }
    }

    public var maxDigits: Int? {
        switch self {
        case .noDecimal:
            return nil
        case .withDecimal(let maxDigits):
            return maxDigits
        }
    }
}
