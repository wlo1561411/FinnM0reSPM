import XCTest

@testable import FinnM0reSPM

final class PaginationTests: XCTestCase {
    func testReload() {
        let expectation = XCTestExpectation(description: "Reload API call")

        let mockService = MockService(page: 10, testReload: true)

        let pagination = Pagination<Response>(page: 10)

        pagination.setup(
            fetching: { page, _, completion in
                mockService.fetchingMock(completion: completion)
                if mockService.spyCount == 2 {
                    XCTAssertEqual(page, 10)
                }
            },
            onSuccess: { response in
                if response.pageNum == 11 {
                    pagination.reload()
                }
                else {
                    XCTAssertEqual(response.pageNum, 10)
                    expectation.fulfill()
                }
            },
            onError: { error in
                XCTFail("API call failed: \(error)")
            })

        pagination.next()

        wait(for: [expectation], timeout: 3)
    }

    func testNextPage() {
        let expectation = XCTestExpectation(description: "Next page API call")

        let mockService = MockService(testNext: true)

        let pagination = Pagination<Response>()

        pagination.setup(
            fetching: { page, _, completion in
                if mockService.spyCount == 1 {
                    XCTAssertEqual(page, 2)
                }
                mockService.fetchingMock(completion: completion)
            },
            onSuccess: { response in
                if response.pageNum == 1 {
                    XCTAssertFalse(response.isLastPage)
                    pagination.next()
                }
                else {
                    XCTAssertEqual(response.pageNum, 2)
                    expectation.fulfill()
                }
            },
            onError: { error in
                XCTFail("API call failed: \(error)")
            })

        pagination.next()

        wait(for: [expectation], timeout: 3)
    }

    func testNoNextPageIfLastPage() {
        let expectation = XCTestExpectation(description: "Last page API call")
        
        let unExpectation = XCTestExpectation(description: "Last page should not return")
        unExpectation.isInverted = true
        
        let mockService = MockService(testLast: true)

        let pagination = Pagination<Response>()

        pagination.setup(
            fetching: { _, _, completion in
                mockService.fetchingMock(completion: completion)
            },
            onSuccess: { response in
                if mockService.spyCount == 2 {
                    unExpectation.fulfill()
                }
                else if response.isLastPage {
                    pagination.next()
                    expectation.fulfill()
                }

            },
            onError: { error in
                XCTFail("API call failed: \(error)")
            })

        pagination.next()

        wait(for: [expectation, unExpectation], timeout: 3)
    }

    func testLoadingState() {
        let expectation = XCTestExpectation(description: "Loading state")

        let mockService = MockService()

        let pagination = Pagination<Response>()

        pagination.setup(
            fetching: { _, _, completion in
                mockService.fetchingMock(completion: completion)
            },
            onSuccess: { _ in
                XCTAssertFalse(pagination.isLoading)
                expectation.fulfill()
            },
            onError: { error in
                XCTFail("API call failed: \(error)")
            })

        pagination.next()

        XCTAssertTrue(pagination.isLoading)

        wait(for: [expectation], timeout: 2)
    }

    func testAlreadyLoading() {
        let mockService = MockService()

        let pagination = Pagination<Response>()

        pagination.setup(
            fetching: { _, _, completion in
                mockService.fetchingMock(completion: completion)
            },
            onSuccess: { _ in
                XCTFail("Should not succeed while loading")
            },
            onError: { _ in
                XCTFail("Should not fail while loading")
            })

        pagination.next()
        pagination.next()
    }
}
