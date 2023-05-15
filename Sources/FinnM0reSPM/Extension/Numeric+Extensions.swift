import Foundation

extension Numeric {
    public func currencyFormatted(minimum: Int = 0, maximum: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        formatter.decimalSeparator = "."
        formatter.minimumFractionDigits = minimum
        formatter.maximumFractionDigits = maximum
        formatter.roundingMode = .down
        return formatter.string(for: self) ?? ""
    }
}
