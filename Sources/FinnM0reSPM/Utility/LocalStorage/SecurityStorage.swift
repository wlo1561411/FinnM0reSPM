import Foundation
import Security

struct KeychainStorage {
    struct Service: RawRepresentable {
        let rawValue: String

        fileprivate var name: String {
            var name: [String] = []
            if let bundleId = Bundle.main.bundleIdentifier {
                name.append(bundleId)
            }
            if rawValue.isEmpty == false {
                name.append(rawValue)
            }
            return name.joined(separator: ".")
        }
    }

    enum OperateError: Error {
        case unknown
        case fail(String)

        init(_ prefix: String, status: OSStatus) {
            if let message = SecCopyErrorMessageString(status, nil) as? String {
                self = .fail(prefix + message)
            } else {
                self = .unknown
            }
        }
    }

    static func save(_ object: some Codable, account: String, service: Service) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(object)
        try save(data, account: account, service: service)
    }

    static func read<T: Codable>(account: String, service: Service) throws -> T? {
        guard let data = try read(account: account, service: service) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    static func save(_ data: Data, account: String, service: Service) throws {
        let query = [
            kSecAttrAccount: account,
            kSecAttrService: service.name,
            kSecClass: kSecClassGenericPassword,
            kSecValueData: data
        ] as CFDictionary

        let status: OSStatus
        switch SecItemCopyMatching(query, nil) {
        case errSecItemNotFound:
            status = SecItemAdd(query, nil)
        case errSecSuccess:
            status = SecItemUpdate(query, [kSecValueData: data] as CFDictionary)
        default:
            throw OperateError.unknown
        }
        guard status == noErr else {
            throw OperateError("save failed, ", status: status)
        }
    }

    static func read(account: String, service: Service) throws -> Data? {
        let query = [
            kSecAttrAccount: account,
            kSecAttrService: service.name,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary

        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)

        switch status {
        case errSecItemNotFound:
            return nil
        case errSecSuccess:
            guard let data = result as? Data else {
                throw OperateError("read failed, ", status: status)
            }
            return data
        default:
            throw OperateError.unknown
        }
    }

    static func update(account: String, newAccount: String, service: Service) throws {
        let query = [
            kSecAttrAccount: account,
            kSecAttrService: service.name,
            kSecClass: kSecClassGenericPassword
        ] as CFDictionary

        let update = [
            kSecAttrAccount: newAccount
        ] as CFDictionary

        let status = SecItemUpdate(query, update)
        guard status == noErr
        else {
            throw OperateError("update failed, ", status: status)
        }
    }

    static func delete(account: String, service: Service) throws {
        let query = [
            kSecAttrAccount: account,
            kSecAttrService: service.name,
            kSecClass: kSecClassGenericPassword
        ] as CFDictionary

        let status = SecItemDelete(query)
        guard status == noErr
        else {
            throw OperateError("delete failed, ", status: status)
        }
    }
}
