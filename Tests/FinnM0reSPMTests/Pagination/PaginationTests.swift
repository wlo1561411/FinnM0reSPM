import XCTest

@testable import FinnM0reSPM

final class PaginationTests: XCTestCase {
    func testReload() {
        let reloadExpectation = XCTestExpectation(description: "Start Reload")
        let finalExpectation = XCTestExpectation(description: "Reload API call")

        let mockService = MockService(page: 10, testReload: true)

        let pagination = Pagination<Response>(page: 10)

        pagination.setup(
            fetching: { page, size, completion in
                mockService.fetchingMock(pageSize: size, completion: completion)
                if mockService.spyCount == 2 {
                    XCTAssertEqual(page, 10)
                }
            },
            onSuccess: { response, _ in
                if response.pageNum == 11 {
                    pagination.reload()
                    reloadExpectation.fulfill()
                }
                else {
                    XCTAssertEqual(response.pageNum, 10)
                    finalExpectation.fulfill()
                }
            },
            onError: { error in
                XCTFail("API call failed: \(error)")
            })

        pagination.next()

        wait(for: [reloadExpectation, finalExpectation], timeout: 1)
    }

    func testNextPage() {
        let expectation = XCTestExpectation(description: "Next page API call")

        let mockService = MockService(testNext: true)

        let pagination = Pagination<Response>(pageSize: 10)

        pagination.setup(
            fetching: { page, size, completion in
                if mockService.spyCount == 1 {
                    XCTAssertEqual(page, 2)
                }
                mockService.fetchingMock(pageSize: size, completion: completion)
            },
            onSuccess: { response, allItems in
                if response.pageNum == 1 {
                    XCTAssertFalse(response.isLastPage)
                    XCTAssertEqual(allItems.count, 10)
                    pagination.next()
                }
                else {
                    XCTAssertEqual(response.pageNum, 2)
                    XCTAssertEqual(allItems.count, 20)
                    expectation.fulfill()
                }
            },
            onError: { error in
                XCTFail("API call failed: \(error)")
            })

        pagination.next()

        wait(for: [expectation], timeout: 1)
    }

    func testNoNextPageIfLastPage() {
        let expectation = XCTestExpectation(description: "Last page API call")
        
        let unExpectation = XCTestExpectation(description: "Last page should not return")
        unExpectation.isInverted = true
        
        let mockService = MockService(testLast: true)

        let pagination = Pagination<Response>()

        pagination.setup(
            fetching: { _, size, completion in
                mockService.fetchingMock(pageSize: size, completion: completion)
            },
            onSuccess: { response, _ in
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

        wait(for: [expectation, unExpectation], timeout: 1)
    }

    func testLoadingState() {
        let expectation = XCTestExpectation(description: "Loading state")

        let mockService = MockService()

        let pagination = Pagination<Response>()

        pagination.setup(
            fetching: { _, size, completion in
                mockService.fetchingMock(pageSize: size, completion: completion)
            },
            onSuccess: { _, _ in
                XCTAssertFalse(pagination.isLoading)
                expectation.fulfill()
            },
            onError: { error in
                XCTFail("API call failed: \(error)")
            })

        pagination.next()

        XCTAssertTrue(pagination.isLoading)

        wait(for: [expectation], timeout: 1)
    }

    func testAlreadyLoading() {
        let mockService = MockService()

        let pagination = Pagination<Response>()

        pagination.setup(
            fetching: { _, size, completion in
                mockService.fetchingMock(pageSize: size, completion: completion)
            },
            onSuccess: { _, _ in
                XCTFail("Should not succeed while loading")
            },
            onError: { _ in
                XCTFail("Should not fail while loading")
            })

        pagination.next()
        pagination.next()
    }
}
