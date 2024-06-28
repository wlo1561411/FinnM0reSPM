import Foundation

/// 專案通用的最大小數位數
let generalMaximumFractionDigits = 8

protocol NumberFormatStrategy {
    /// 預設為 .down
    var roundingMode: NumberFormatter.RoundingMode { get }
    /// 預設為 .decimal
    var numberStyle: NumberFormatter.Style { get }
    /// 只要設定 numberStyle 就會自動設定為 .currency
    var currencyConfiguration: CurrencyNumberConfiguration? { get }

    var minimumFractionDigits: Int { get }
    var maximumOption: NumberFormattingOption { get }

    func format(value: any Numeric) -> String
}

// MARK: - Default Implement

extension NumberFormatStrategy {
    var roundingMode: NumberFormatter.RoundingMode {
        .down
    }

    var numberStyle: NumberFormatter.Style {
        .decimal
    }

    var currencyConfiguration: CurrencyNumberConfiguration? {
        nil
    }

    func format(value: any Numeric) -> String {
        defaultFormat(value: value)
    }
}

// MARK: - Format

extension NumberFormatStrategy {
    /// 避免 NumberFormatter 原生行為把小數自己丟掉
    var digitsForPrecision: Int {
        14
    }

    func defaultFormat(value: any Numeric, configure: ((NumberFormatter) -> Void)? = nil) -> String {
        if let decimal = value as? Decimal {
            return defaultFormat(value: decimal, configure: configure)
        } else if let double = value as? Double {
            return defaultFormat(value: double, configure: configure)
        } else if let int = value as? Int {
            return defaultFormat(value: Double(int), configure: configure)
        }
        return "0"
    }

    /// 精度較低
    func defaultFormat(value: Double, configure: ((NumberFormatter) -> Void)? = nil) -> String {
        let formatter = NumberFormatter()
        formatter.apply(value: Decimal(value), strategy: self)
        configure?(formatter)
        return formatter.string(from: .init(value: value)) ?? "0"
    }

    /// 精度較高
    func defaultFormat(value: Decimal, configure: ((NumberFormatter) -> Void)? = nil) -> String {
        guard let digits = "\(value)".digits
        else { return "0" }

        let formatter = NumberFormatter()
        formatter.apply(value: value, strategy: self)
        configure?(formatter)

        let formattedString = formatter.string(from: value as NSDecimalNumber) ?? "0"

        if digits > digitsForPrecision, digits >= formatter.maximumFractionDigits {
            return processPrecision(value: value, formatter: formatter)
        } else {
            return formattedString
        }
    }

    // NumberFormatter 只用於分组(如果有)，不處理小數
    private func processPrecision(value: Decimal, formatter: NumberFormatter) -> String {
        let originalString = "\(value)"
        let components = originalString.components(separatedBy: ".")

        if components.count == 2 {
            let integerPart = components[0]
            let fullDecimalPart = components[1]

            let limitedDecimalPart = String(fullDecimalPart.prefix(formatter.maximumFractionDigits))

            if let intValue = Int(integerPart),
               let formattedInteger = formatter.string(from: NSNumber(value: intValue)) {
                return "\(formattedInteger).\(limitedDecimalPart)"
            } else {
                return originalString
            }
        } else {
            return originalString
        }
    }
}

// MARK: - NumberFormatter

extension NumberFormatter {
    fileprivate func apply(value: Decimal, strategy: NumberFormatStrategy) {
        roundingMode = strategy.roundingMode
        locale = .init(identifier: "zh_CN")

        minimumFractionDigits = strategy.minimumFractionDigits
        maximumFractionDigits = max(strategy.maximumOption.digits(value: value), minimumFractionDigits)

        if let configuration = strategy.currencyConfiguration {
            numberStyle = .currency
            currencySymbol = configuration.symbol
            currencyGroupingSeparator = configuration.groupingSeparator
            groupingSize = configuration.groupingSize
            usesGroupingSeparator = true
        } else {
            numberStyle = strategy.numberStyle
            currencySymbol = ""
            usesGroupingSeparator = false
        }
    }
}

// MARK: - Numeric

extension Numeric {
    func formatted(strategy: NumberFormatStrategy) -> String {
        strategy.format(value: self)
    }
}

// MARK: - String

extension String {
    func formatted(strategy: NumberFormatStrategy) -> String? {
        let extraNumber = match("-?[0-9]*+(?:\\.[0-9]+)?").joined()
        return Decimal(string: extraNumber)?.formatted(strategy: strategy)
    }
}
