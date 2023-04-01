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

  func test_RefreshFirstTime() {
    let stubPagination = Pagination<Int>(observable: {
      self.dummyObservable($0)
    })

    stubPagination.refreshTrigger.onNext(())

    let expect = (0..<10).map { $0 }
    XCTAssertEqual(expect, stubPagination.elements.value)
  }

  func test_LoadNextPage() {
    let stubPagination = Pagination<Int>(observable: {
      self.dummyObservable($0)
    })

    stubPagination.refreshTrigger.onNext(())
    stubPagination.loadNextPageTrigger.onNext(())

    delay(for: 0.1) {
      let expect = (0..<20).map { $0 }
      XCTAssertEqual(expect, stubPagination.elements.value)
    }
  }

  func test_RefreshWhenPageGreaterThen1() {
    let stubPagination = Pagination<Int>(observable: {
      self.dummyObservable($0)
    })

    stubPagination.refreshTrigger.onNext(())
    stubPagination.loadNextPageTrigger.onNext(())

    let expect = (0..<20).map { $0 }

    delay(for: 0.1) {
      XCTAssertEqual(expect, stubPagination.elements.value)
    }

    stubPagination.refreshTrigger.onNext(())

    delay(for: 0.1) {
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
