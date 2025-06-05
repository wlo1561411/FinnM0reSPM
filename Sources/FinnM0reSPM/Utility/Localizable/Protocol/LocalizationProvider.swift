import Combine

protocol LocalizationProvider {
    var onLanguageChanged: AnyPublisher<Void, Never> { get }

    func localized(key: String, arguments: [CVarArg]) -> String
}

extension LocalizationProvider {
    func localized(key: String) -> String {
        localized(key: key, arguments: [])
    }
}

final class LocalizationServiceContext {
    private static var instance: LocalizationProvider?

    private init() { }

    static func register(_ instance: LocalizationProvider) {
        self.instance = instance
    }

    static var shared: LocalizationProvider {
        guard let instance else {
            fatalError("LocalizationProvider not registered")
        }

        return instance
    }
}
