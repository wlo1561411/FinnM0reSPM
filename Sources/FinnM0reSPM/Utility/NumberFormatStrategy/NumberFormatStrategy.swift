import Foundation

/// 專案通用的最大小數位數
let generalMaximumFractionDigits = 8

private let formatter = NumberFormatter()

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
        format(value: value, strategy: self)
    }
}

// MARK: - Format

extension NumberFormatStrategy {
    /// workaround
    ///
    /// 避免 NumberFormatter 原生行為把小數自己丟掉
    var digitsForPrecision: Int {
        14
    }

    func format(value: any Numeric, strategy: NumberFormatStrategy) -> String {
        let scale = strategy.maximumOption.digits(value: value)

        var converted: Decimal = 0

        switch value {
        case let decimal as Decimal:
            converted = PrecisionHandler.precision(decimal, scale: scale)
        case let double as Double:
            converted = PrecisionHandler.precision(Decimal(double), scale: scale)
        case let int as Int:
            converted = Decimal(int)
        default:
            return "\(value)"
        }

        return format(decimal: converted, strategy: strategy)
    }

    private func format(decimal: Decimal, strategy: NumberFormatStrategy) -> String {
        formatter.apply(decimal: decimal, strategy: self)

        guard let digitCount = "\(decimal)".digits
        else {
            return formatter.string(from: decimal as NSDecimalNumber) ?? "0"
        }

        if digitCount > digitsForPrecision, digitCount >= formatter.maximumFractionDigits {
            return PrecisionHandler.trim(value: decimal as Decimal, formatter: formatter)
        } else {
            return formatter.string(from: decimal as NSDecimalNumber) ?? "0"
        }
    }
}

// MARK: - NumberFormatter

extension NumberFormatter {
    fileprivate func apply(decimal: Decimal, strategy: NumberFormatStrategy) {
        roundingMode = strategy.roundingMode
        locale = .init(identifier: "zh_CN")

        minimumFractionDigits = strategy.minimumFractionDigits
        maximumFractionDigits = max(strategy.maximumOption.digits(value: decimal), minimumFractionDigits)

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
