import XCTest

@testable import FinnM0reSPM

final class DefaultCodableTests: XCTestCase {
    private enum Status: String, Codable {
        case open
        case closed
        case pending

        struct Pending: DefaultValue {
            static let defaultValue: Status = .pending
        }
    }

    private struct TestModel: Codable {
        @Default<Status.Pending>
        var status: Status
    }

    func testDecoding() {
        let jsonData = #"{"status": "open"}"#.data(using: .utf8)!

        do {
            let model = try JSONDecoder().decode(TestModel.self, from: jsonData)
            XCTAssertEqual(model.status, Status.open)
        }
        catch {
            XCTFail("Decoding failed: \(error)")
        }
    }

    func testDecodingMissingKey() {
        let jsonData = #"{}"#.data(using: .utf8)!

        do {
            let model = try JSONDecoder().decode(TestModel.self, from: jsonData)
            XCTAssertEqual(model.status, .pending)
        }
        catch {
            XCTFail("Decoding failed: \(error)")
        }
    }

    func testEncoding() {
        let model = TestModel(status: DefaultCodableTests.Status.closed)
        do {
            let jsonData = try JSONEncoder().encode(model)
            let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
            XCTAssertEqual(jsonDict?["status"] as? String, Status.closed.rawValue)
        }
        catch {
            XCTFail("Encoding failed: \(error)")
        }
    }
}
