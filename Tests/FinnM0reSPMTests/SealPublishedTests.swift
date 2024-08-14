import Combine
import XCTest

@testable import FinnM0reSPM

class SealPublishedTests: XCTestCase {
    private class TestClass {
        @SealPublished
        var testValue = "Initial Value"
        
        @SealPublished(
            modifyPublisher: {
                $0.map { _ in "Mapped" }.eraseToAnyPublisher()
            })
        var mappedValue: String = "Initial Value"

        func sendValue() {
            testValue = "New Value"
            mappedValue = "New Value"
        }
        
        func async(completion: @escaping () -> Void) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completion()
            }
        }
    }
    
    var cancellables: Set<AnyCancellable> = []
    
    func testModifyPublisher() {
        let expectation = XCTestExpectation()
        
        let testObject = TestClass()
        
        testObject
            .$mappedValue
            .sealSink(dropFirst: false) {
                expectation.fulfill()
                XCTAssertEqual($0, "Mapped")
            }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testSealPublishedSinkAndCancel() {
        let expectation = XCTestExpectation(description: "Subscription should not receive values after cancellation")
        expectation.isInverted = true // Expectation should not be fulfilled
        
        let testObject = TestClass()
        
        testObject
            .$testValue
            .sealSink { _ in
                expectation.fulfill()
            }
        
        testObject.$testValue.cancelSealedSubscription()
        
        // Try send value
        testObject.sendValue()
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testSealPublishedNoMemoryLeak() {
        let expectation = XCTestExpectation(description: "TestClass should be deallocated after async operation")
        
        var testClassInstance: TestClass? = TestClass()
        
        // For check is been released
        weak var weakTestClassInstance = testClassInstance
        
        // Simulate different queue access
        testClassInstance?.async { [weak testClassInstance] in
            XCTAssertNil(testClassInstance, "TestClass instance should be nil, indicating it was deallocated.")
            expectation.fulfill()
        }
        
        testClassInstance = nil
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertNil(weakTestClassInstance, "TestClass instance should have been dealalled. Potential memory leak.")
    }
}
