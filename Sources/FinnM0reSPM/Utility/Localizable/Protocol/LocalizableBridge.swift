import Combine

protocol LocalizableBridge {
    var onLanguageChanged: AnyPublisher<Void, Never> { get }

    func localized(key: String, arguments: any CVarArg) -> String
}

// MARK: - Mock

final class MockLocalizableBridge: LocalizableBridge {
    static let shared = MockLocalizableBridge()

    @Published
    private var language = "en"

    var onLanguageChanged: AnyPublisher<Void, Never> {
        $language
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    func localized(key: String, arguments: any CVarArg) -> String {
        assertionFailure("Need to implement this.")
        return ""
    }
}
