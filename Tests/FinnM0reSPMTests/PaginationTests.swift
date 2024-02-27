import RxSwift
import XCTest

@testable import FinnM0reSPM

final class PaginationTests: XCTestCase {
    func dummyObservable(_ page: Int, delay: TimeInterval = 0) -> Observable<[Int]> {
        let minimum = page == 1 ? 0 : (page - 1) * 10
        let maximum = page * 10

        let result = (minimum..<maximum).map { $0 }

        if delay == 0 {
            return .just(result)
        }
        else {
            return .create { o in
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    o.onNext(result)
                    o.onCompleted()
                }
                return Disposables.create { }
            }
        }
    }

    func waitFetchData(
        _ stubPagination: Pagination<Int>,
        _ path: KeyPath<Pagination<Int>, PublishSubject<Void>>,
        completion: () -> Void)
    {
        let first = expectation(description: "")
        
        _ = stubPagination.elements
            .skip(1)
            .first()
            .subscribe(onSuccess: { _ in
                first.fulfill()
            })
        
        stubPagination[keyPath: path].onNext(())
        
        wait(for: [first], timeout: 1)
        
        completion()
    }
    
    func test_RefreshFirstTime() {
        let stubPagination = Pagination<Int>(observable: {
            self.dummyObservable($0)
        })

        waitFetchData(stubPagination, \.refreshTrigger) {
            let expect = (0..<10).map { $0 }
            XCTAssertEqual(expect, stubPagination.elements.value)
        }
    }

    func test_LoadNextPage() {
        let stubPagination = Pagination<Int>(observable: {
            self.dummyObservable($0, delay: 0.1)
        })
        
        let first = expectation(description: "First poll")

        waitFetchData(stubPagination, \.refreshTrigger) {
            first.fulfill()
        }
        
        wait(for: [first], timeout: 1)
        
        waitFetchData(stubPagination, \.loadNextPageTrigger) {
            let expect = (0..<20).map { $0 }
            XCTAssertEqual(expect, stubPagination.elements.value)
        }
    }

    func test_RefreshWhenPageGreaterThen1() {
        let stubPagination = Pagination<Int>(observable: {
            self.dummyObservable($0, delay: 0.1)
        })
        
        let first = expectation(description: "First poll")

        waitFetchData(stubPagination, \.refreshTrigger) {
            first.fulfill()
        }
        
        wait(for: [first], timeout: 1)
        
        let next = expectation(description: "Next poll")
        
        waitFetchData(stubPagination, \.loadNextPageTrigger) {
            next.fulfill()
        }

        wait(for: [next], timeout: 1)
        
        waitFetchData(stubPagination, \.refreshTrigger) {
            let expect = (0..<20).map { $0 }
            XCTAssertEqual(expect, stubPagination.elements.value)
        }
    }

    func test_IsLoading() {
        let stubPagination = Pagination<Int>(observable: {
            self.dummyObservable($0, delay: 1)
        })

        stubPagination.refreshTrigger.onNext(())
        stubPagination.loadNextPageTrigger.onNext(())

        XCTAssertTrue(stubPagination.loading.value)
    }
}
