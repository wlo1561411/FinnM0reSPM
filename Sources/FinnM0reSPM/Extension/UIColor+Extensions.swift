import UIKit

public extension UIColor {
    convenience init(red: Int = 0xFF, green: Int = 0xFF, blue: Int = 0xFF, a: Int = 0xFF) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }

    convenience init?(hex: String?) {
        guard let hex else { return nil }

        let r, g, b, a: CGFloat
        var hexString = hex

        if hexString.hasPrefix("#") {
            hexString = hexString.replacingOccurrences(of: "#", with: "")
        }

        let scanner = Scanner(string: hexString)
        var hexNumber: UInt64 = 0

        switch hexString.count {
        case 6: // rgb with alpha 1.0
            guard scanner.scanHexInt64(&hexNumber) else { return nil }
            r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255
            g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255
            b = CGFloat(hexNumber & 0x0000FF) / 255
            a = 1.0
            self.init(red: r, green: g, blue: b, alpha: a)
        case 8: // rgba
            guard scanner.scanHexInt64(&hexNumber) else { return nil }
            r = CGFloat((hexNumber & 0xFF00_0000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00FF_0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000_FF00) >> 8) / 255
            a = CGFloat(hexNumber & 0x0000_00FF) / 255
            self.init(red: r, green: g, blue: b, alpha: a)
        default:
            return nil
        }
    }
}
