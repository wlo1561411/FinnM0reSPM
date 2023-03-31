import UIKit

extension UIApplication {
  public var keyWindow: UIWindow? {
    UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.windows.first
  }

  public var safeAreaInsets: UIEdgeInsets {
    keyWindow?.safeAreaInsets ?? .zero
  }

  public var appName: String? {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
      Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
  }

  public var releaseVersion: String? {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
  }

  public var buildVersion: String? {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
  }
}
