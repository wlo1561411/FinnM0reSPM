import Foundation

@propertyWrapper
struct UserDefault<T> {
    private let key: String
    private let defaultValue: T
    private let userDefaults: UserDefaults

    init(_ suffixKey: String, defaultValue: T, userDefaults: UserDefaults = .standard, structName: String = #function) {
        self.key = [structName, suffixKey].joined(separator: "_")
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }

    var wrappedValue: T {
        get {
            return userDefaults.object(forKey: key) as? T ?? defaultValue
        }
        set {
            let mirror = Mirror(reflecting: newValue)
            if mirror.displayStyle == .optional && mirror.children.isEmpty {
                userDefaults.removeObject(forKey: key)
            } else {
                userDefaults.set(newValue, forKey: key)
            }
        }
    }
}
