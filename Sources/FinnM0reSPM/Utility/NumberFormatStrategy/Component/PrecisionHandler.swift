import Foundation

struct PrecisionHandler {
    static func precision(_ value: Decimal, scale: Int) -> Decimal {
        NSDecimalNumber(decimal: value)
            .rounding(accordingToBehavior: NSDecimalNumberHandler(
                roundingMode: (value.sign == .plus) ? .down : .up,
                scale: Int16(scale),
                raiseOnExactness: false,
                raiseOnOverflow: false,
                raiseOnUnderflow: false,
                raiseOnDivideByZero: false)) as Decimal
    }

    /// 處理 NumberFormatter 過多小數位會遺失精度的問題
    /// - Parameters:
    ///   - formatter: 只用來處理整數位
    static func trim(value: Decimal, formatter: NumberFormatter) -> String {
        let components = "\(value)".components(separatedBy: ".")

        guard components.count == 2
        else {
            return "\(value)"
        }

        let integerPart = components[0]
        let fullDecimalPart = components[1]
        let limitedDecimalPart = String(fullDecimalPart.prefix(formatter.maximumFractionDigits))

        let integerDecimal = Decimal(string: integerPart)
        let formattedInteger = integerDecimal
            .flatMap {
                formatter.string(from: $0 as NSDecimalNumber)
            } ?? integerPart

        return "\(formattedInteger).\(limitedDecimalPart)"
    }
}
