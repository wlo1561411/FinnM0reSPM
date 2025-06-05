import Combine
import XCTest

@testable import FinnM0reSPM

final class LocalizationTests: XCTestCase {
    final class MockProvider: LocalizationProvider {
        let languageChanged = PassthroughSubject<Void, Never>()

        var localizedMap: [String: String] = [:]

        init(localizedMap: [String: String]) {
            self.localizedMap = localizedMap
        }

        func updateLocalizedMap(key: String, value: String) {
            localizedMap[key] = value
            languageChanged.send()
        }

        var onLanguageChanged: AnyPublisher<Void, Never> {
            languageChanged.eraseToAnyPublisher()
        }

        func localized(key: String, arguments: [CVarArg]) -> String {
            .init(format: localizedMap[key] ?? "", arguments: arguments)
        }
    }

    func testLocalizerUpdateLocalization() {
        let mockProvider = MockProvider(localizedMap: [
            "greeting": "Hello"
        ])

        LocalizationServiceContext.register(mockProvider)

        let localizer = Localizer(wrappedValue: UILabel(), key: "greeting")

        XCTAssertEqual(localizer.wrappedValue.text, "Hello")

        mockProvider.updateLocalizedMap(key: "greeting", value: "你好")

        XCTAssertEqual(localizer.wrappedValue.text, "你好")
    }

    func testReplaceableLocalizerReplacesText() {
        let mockProvider = MockProvider(localizedMap: [
            "hello": "Hello"
        ])

        LocalizationServiceContext.register(mockProvider)

        let localizer = ReplaceableLocalizer(wrappedValue: UILabel(), key: "hello")

        localizer.wrappedValue.text = "\(mockProvider.localized(key: "hello")) World"

        XCTAssertEqual(localizer.wrappedValue.text, "Hello World")

        mockProvider.updateLocalizedMap(key: "hello", value: "你好")

        XCTAssertEqual(localizer.wrappedValue.text, "你好 World")
    }

    func testLocalizerWithArgumentsUpdates() {
        let mockProvider = MockProvider(localizedMap: [
            "welcome": "Welcome, %@"
        ])

        LocalizationServiceContext.register(mockProvider)

        let localizer = Localizer(
            wrappedValue: UILabel(),
            key: "welcome",
            arguments: ["Finn"])

        XCTAssertEqual(localizer.wrappedValue.text, "Welcome, Finn")

        mockProvider.updateLocalizedMap(key: "welcome", value: "歡迎, %@")

        XCTAssertEqual(localizer.wrappedValue.text, "歡迎, Finn")
    }

    func testReplaceableLocalizerWithArgumentsReplaces() {
        let mockProvider = MockProvider(localizedMap: [
            "greet": "Hello, %@"
        ])

        LocalizationServiceContext.register(mockProvider)

        let localizer = ReplaceableLocalizer(
            wrappedValue: UILabel(),
            key: "greet",
            arguments: ["Finn"])

        localizer.wrappedValue.text = "Hello, Finn!"

        XCTAssertEqual(localizer.wrappedValue.text, "Hello, Finn!")

        mockProvider.updateLocalizedMap(key: "greet", value: "你好, %@")

        XCTAssertEqual(localizer.wrappedValue.text, "你好, Finn!")
    }

    func testUIButtonLocalizerWithStatefulContent() {
        let mockProvider = MockProvider(localizedMap: [
            "enabled": "Tap me",
            "disabled": "Unavailable"
        ])

        LocalizationServiceContext.register(mockProvider)

        let localizer = Localizer(
            wrappedValue: UIButton(),
            contents:
            LocalizationContentBuilder(provider: mockProvider)
                .enabled("enabled")
                .disabled("disabled")
                .contents)

        XCTAssertEqual(localizer.wrappedValue.title(for: .normal), "Tap me")
        XCTAssertEqual(localizer.wrappedValue.title(for: .disabled), "Unavailable")

        mockProvider.updateLocalizedMap(key: "enabled", value: "點我")
        mockProvider.updateLocalizedMap(key: "disabled", value: "無法使用")

        XCTAssertEqual(localizer.wrappedValue.title(for: .normal), "點我")
        XCTAssertEqual(localizer.wrappedValue.title(for: .disabled), "無法使用")
    }

    func testUIButtonReplaceableLocalizerWithArguments() {
        let mockProvider = MockProvider(localizedMap: [
            "welcome": "Welcome, %@"
        ])

        LocalizationServiceContext.register(mockProvider)

        let localizer = ReplaceableLocalizer(
            wrappedValue: UIButton(),
            contents: LocalizationContentBuilder(provider: mockProvider)
                .enabled("welcome", arguments: ["Finn"])
                .contents)

        localizer.wrappedValue.setTitle("Welcome, Finn", for: .normal)

        XCTAssertEqual(localizer.wrappedValue.title(for: .normal), "Welcome, Finn")

        mockProvider.updateLocalizedMap(key: "welcome", value: "歡迎, %@")

        XCTAssertEqual(localizer.wrappedValue.title(for: .normal), "歡迎, Finn")
    }
}
