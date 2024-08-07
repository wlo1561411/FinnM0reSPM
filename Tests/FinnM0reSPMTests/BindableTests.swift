import XCTest

@testable import FinnM0reSPM

final class BindableTests: XCTestCase { 
    class MockObject {
        @Bindable
        var text: String = ""
    }

    func testOnChange() {
        let expectation = XCTestExpectation()

        let mock = MockObject()

        mock.$text.observe {
            let actual = $0
            let expect = "testing"
            XCTAssertEqual(actual, expect)
            expectation.fulfill()
        }

        mock.text = "testing"

        wait(for: [expectation], timeout: 0.1)
    }

    func testWithoutEvent() {
        let expectation = XCTestExpectation()
        expectation.isInverted = true

        let mock = MockObject()

        mock.$text.observe { _ in
            expectation.fulfill()
        }

        mock.$text.setWithoutEvent("testing")

        wait(for: [expectation], timeout: 0.1)
    }

    func testShouldTriggerChange() {
        let expectation = XCTestExpectation()
        expectation.isInverted = true

        @Bindable(shouldTriggerChange: { $0 != $1 })
        var mock = "testing"

        $mock.observe { _ in
            expectation.fulfill()
        }

        mock = "testing"

        wait(for: [expectation], timeout: 0.1)
    }

    func testBindable_Destroyed() {
        let expectation = XCTestExpectation()

        var mock: MockObject? = MockObject()

        mock?.$text.observe {
            let actual = $0
            let expect = "testing"
            
            XCTAssertEqual(actual, expect)

            mock = nil
            XCTAssertNil(mock)
            expectation.fulfill()
        }

        mock?.text = "testing"

        wait(for: [expectation], timeout: 2)
    }
}
