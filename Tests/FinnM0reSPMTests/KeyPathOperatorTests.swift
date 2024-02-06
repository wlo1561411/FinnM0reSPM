import XCTest

@testable import FinnM0reSPM

final class KeyPathOperatorTests: XCTestCase {
    struct Person {
        var name: String
        var age: Int
    }
    
    let people = [
        Person(name: "Alice", age: 30),
        Person(name: "Bob", age: 25),
        Person(name: "Charlie", age: 35),
        Person(name: "Diana", age: 28)
    ]
    
    // Test for '=='
    func testEqualityFilter() {
        let filtered = people.filter(\.age == 30)
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.name, "Alice")
    }
    
    // Test for '>='
    func testGreaterThanOrEqualFilter() {
        let filtered = people.filter(\.age >= 30)
        XCTAssertEqual(filtered.count, 2)
        XCTAssertTrue(filtered.contains(where: \.name == "Alice"))
        XCTAssertTrue(filtered.contains(where: \.name == "Charlie"))
    }
    
    // Test for '<='
    func testLessThanOrEqualFilter() {
        let filtered = people.filter(\.age <= 28)
        XCTAssertEqual(filtered.count, 2)
        XCTAssertTrue(filtered.contains(where: \.name == "Bob"))
        XCTAssertTrue(filtered.contains(where: \.name == "Diana"))
    }
    
    // Test for '>'
    func testGreaterThanFilter() {
        let filtered = people.filter(\.age > 28)
        XCTAssertEqual(filtered.count, 2)
        XCTAssertTrue(filtered.contains(where: \.name == "Alice"))
        XCTAssertTrue(filtered.contains(where: \.name == "Charlie"))
    }
    
    // Test for '<'
    func testLessThanFilter() {
        let filtered = people.filter(\.age < 30)
        XCTAssertEqual(filtered.count, 2)
        XCTAssertTrue(filtered.contains(where: \.name == "Bob"))
        XCTAssertTrue(filtered.contains(where: \.name == "Diana"))
    }
    
    // Test for '~='
    func testBetweenOperator() {
        let filtered = people.filter(\.age ~= (20, 30))
        XCTAssertEqual(filtered.count, 3)
        XCTAssertTrue(filtered.contains(where: \.name == "Alice"))
        XCTAssertTrue(filtered.contains(where: \.name == "Bob"))
        XCTAssertTrue(filtered.contains(where: \.name == "Diana"))
    }
}
