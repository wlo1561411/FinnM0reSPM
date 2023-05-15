import UIKit

struct SlideCalculator {
    static func color(by percentage: CGFloat, between color1: UIColor, _ color2: UIColor) -> UIColor {
        func calculate(first: CGFloat, second: CGFloat, percentage: CGFloat) -> CGFloat {
            let fixed = first * percentage + second * (1 - percentage) > 1 ?
                1 : first * percentage + second * (1 - percentage)
            return fixed
        }
        let components1 = self.colorRGB(color1)
        let components2 = self.colorRGB(color2)
        return UIColor(
            red: calculate(first: components1[0], second: components2[0], percentage: percentage),
            green: calculate(first: components1[1], second: components2[1], percentage: percentage),
            blue: calculate(first: components1[2], second: components2[2], percentage: percentage),
            alpha: 1)
    }

    /// R, G, B ,Alpha
    static func colorRGB(_ color: UIColor) -> [CGFloat] {
        guard var components = color.cgColor.components else { return [] }
        if components.count == 2 {
            for _ in 0...1 {
                components.insert(components[0], at: 0)
            }
        }
        return components
    }

    static func textWidth(with font: UIFont, by text: String) -> CGFloat {
        NSString(string: text)
            .boundingRect(
                with: CGSize(
                    width: CGFloat.greatestFiniteMagnitude,
                    height: font.lineHeight),
                options: .usesLineFragmentOrigin,
                attributes: [NSAttributedString.Key.font: font],
                context: nil).size.width
    }

    static func textHeight(with font: UIFont, from width: CGFloat, by text: String) -> CGFloat {
        NSString(string: text)
            .boundingRect(
                with: CGSize(
                    width: width,
                    height: CGFloat.greatestFiniteMagnitude),
                options: .usesLineFragmentOrigin,
                attributes: [NSAttributedString.Key.font: font],
                context: nil).size.height
    }
}
