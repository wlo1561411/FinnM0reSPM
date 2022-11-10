import UIKit

public extension UIFont {
    static func pingFangTcRegular(_ size: CGFloat) -> UIFont {
        .init(name: "PingFangTC-Regular", size: size) ?? .systemFont(ofSize: 16)
    }
    
    static func pingFangTcSemibold(_ size: CGFloat) -> UIFont {
        .init(name: "PingFangTC-Semibold", size: size) ?? .systemFont(ofSize: 16)
    }
}
