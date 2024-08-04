import Foundation

@testable import FinnM0reSPM

extension PaginationTests {
    struct PagedList<ListItem: AutoCodable>: AutoCodable {
        @DecodableDefault(0) var pageNum: Int
        @DecodableDefault(false) var isLastPage: Bool
        @DecodableDefault([], path: .init(type: .key("list"))) var items: [ListItem]
        init() { }
    }

    struct Response: AutoCodable, CountablePaged {
        struct Result: AutoCodable {
            @DecodableDefault("")
            var name: String

            init() { }

            init(name: String) {
                self.name = name
            }
        }

        @DecodableDefault(.init())
        var results: PagedList<Result>

        @DecodableDefault("")
        var otherValue: String

        var pageNum: Int {
            results.pageNum
        }

        var isLastPage: Bool {
            results.isLastPage
        }

        init() { }

        init(results: PagedList<Result>, otherValue: String) {
            self.results = results
            self.otherValue = otherValue
        }
    }

    class MockService {
        var page = 1
        var testNext: Bool?
        var testLast: Bool?
        var testReload: Bool?
        var spyCount = 0

        init(page: Int = 1, testNext: Bool? = nil, testLast: Bool? = nil, testReload: Bool? = nil, spyCount: Int = 0) {
            self.page = page
            self.testNext = testNext
            self.testLast = testLast
            self.testReload = testReload
            self.spyCount = spyCount
        }

        func fetchingMock(completion: @escaping (Result<Response, Error>) -> Void) {
            spyCount += 1

            DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let self else { return }

                let pagedList = PagedList<Response.Result>()

                if let testReload {
                    if testReload {
                        pagedList.pageNum = page + 1
                        self.testReload = false
                    }
                    else {
                        pagedList.pageNum = page
                    }
                }

                if testLast != nil {
                    pagedList.isLastPage = true
                }
                else {
                    pagedList.isLastPage = false
                }

                if let testNext {
                    if testNext {
                        pagedList.pageNum = page
                        self.testNext = false
                    }
                    else {
                        pagedList.pageNum = page + 1
                    }
                }

                let response = Response(results: pagedList, otherValue: "test")

                completion(.success(response))
            }
        }
    }
}
