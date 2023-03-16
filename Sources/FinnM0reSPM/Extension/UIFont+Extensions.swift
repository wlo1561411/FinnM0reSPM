import UIKit

extension UIFont {
  public static func pingFangTcRegular(_ size: CGFloat) -> UIFont {
    .init(name: "PingFangTC-Regular", size: size) ?? .systemFont(ofSize: 16)
  }

  public static func pingFangTcSemibold(_ size: CGFloat) -> UIFont {
    .init(name: "PingFangTC-Semibold", size: size) ?? .systemFont(ofSize: 16)
  }
}
