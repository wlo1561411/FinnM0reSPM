import XCTest

@testable import FinnM0reSPM

final class DecodableDefaultTests: XCTestCase {
    struct Mock: AutoCodable {
        @DecodableDefault("test")
        var stringValue: String

        @DecodableDefault(0)
        var intValue: Int

        @DecodableDefault(false)
        var boolValue: Bool

        @DecodableDefault(0.0)
        var doubleValue: Double

        @DecodableDefault([])
        var arrayValue: [String]

        @DecodableDefault([:])
        var dictValue: [String: Int]
    }

    func testDefaultValues() throws {
        let json = "{}"
        let data = try XCTUnwrap(json.data(using: .utf8))
        let mock = try JSONDecoder().decode(Mock.self, from: data)

        XCTAssertEqual(mock.stringValue, "test")
        XCTAssertEqual(mock.intValue, 0)
        XCTAssertEqual(mock.boolValue, false)
        XCTAssertEqual(mock.doubleValue, 0.0)
        XCTAssertEqual(mock.arrayValue, [])
        XCTAssertEqual(mock.dictValue, [:])
    }

    func testOverriddenValues() throws {
        let json = """
        {
            "stringValue": "hello",
            "intValue": 999,
            "boolValue": true,
            "doubleValue": 3.14,
            "arrayValue": ["a", "b"],
            "dictValue": { "x": 1 }
        }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let mock = try JSONDecoder().decode(Mock.self, from: data)

        XCTAssertEqual(mock.stringValue, "hello")
        XCTAssertEqual(mock.intValue, 999)
        XCTAssertEqual(mock.boolValue, true)
        XCTAssertEqual(mock.doubleValue, 3.14)
        XCTAssertEqual(mock.arrayValue, ["a", "b"])
        XCTAssertEqual(mock.dictValue, ["x": 1])
    }

    func testBackendReturnIntButNeedString() throws {
        let json = """
        {
            "stringValue": 1
        }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let mock = try JSONDecoder().decode(Mock.self, from: data)

        XCTAssertEqual(mock.stringValue, "1")
    }

    func testBackendReturnStringButNeedInt() throws {
        let json = """
        {
            "intValue": "999"
        }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let mock = try JSONDecoder().decode(Mock.self, from: data)

        XCTAssertEqual(mock.intValue, 999)
    }
}
