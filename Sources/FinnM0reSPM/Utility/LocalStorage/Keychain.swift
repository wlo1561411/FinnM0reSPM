import Combine

/// 封裝的 Keychain 存取工具。
///
///     - 自動快取記憶體中的值以避免重複存取 Keychain
///     - 寫入時自動觸發 Publisher 以供 UI 或邏輯綁定
///     - 初始值會從 Keychain 中讀取, 若無則使用提供的預設值
@propertyWrapper
final class Keychain<T: Codable> {
    private let account: String
    private let service: KeychainStorage.Service
    private let defaultValue: T

    /// 緩存一份，降低 Keychain 存取次數
    private let subject: CurrentValueSubject<T, Never>

    init(wrappedValue: T, account: String, service: KeychainStorage.Service) {
        self.account = account
        self.service = service
        self.defaultValue = wrappedValue

        let initial: T
        do {
            initial = try KeychainStorage.read(account: account, service: service) ?? wrappedValue
        } catch {
            print("Keychain \(service.rawValue) \(account) init error: \(error)")
            initial = wrappedValue
        }

        self.subject = CurrentValueSubject(initial)
    }

    var wrappedValue: T {
        get {
            subject.value
        }
        set {
            do {
                try KeychainStorage.save(newValue, account: account, service: service)
                subject.send(newValue)
            } catch {
                print("Keychain \(service.rawValue) \(account) save error: \(error)")
            }
        }
    }

    var projectedValue: AnyPublisher<T, Never> {
        subject.eraseToAnyPublisher()
    }

    func delete() {
        subject.send(defaultValue)

        do {
            try KeychainStorage.delete(account: account, service: service)
        } catch {
            print("Keychain \(service.rawValue) \(account) delete error: \(error)")
        }
    }
}
