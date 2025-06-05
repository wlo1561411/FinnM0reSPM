import Foundation

@testable import FinnM0reSPM

extension PaginationTests {
    struct PagedList<ListItem: AutoCodable>: AutoCodable, CountablePaged {
        @DecodableDefault(0)
        var pageNum: Int
        @DecodableDefault(false)
        var isLastPage: Bool
        @DecodableDefault([], path: "list")
        var items: [ListItem]

        init() { }
    }

    struct Item: AutoCodable { }

    typealias Response = PagedList<Item>

    class MockService {
        var page: Int
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

        func fetchingMock(pageSize: Int, completion: @escaping (Result<Response, Error>) -> Void) {
            spyCount += 1

            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self else { return }

                let response = Response()
                response.items = (1...pageSize).map { _ in Item() }

                if let testReload {
                    if testReload {
                        response.pageNum = page + 1
                        self.testReload = false
                    }
                    else {
                        response.pageNum = page
                    }
                }

                if testLast != nil {
                    response.isLastPage = true
                }
                else {
                    response.isLastPage = false
                }

                if let testNext {
                    if testNext {
                        response.pageNum = page
                        self.testNext = false
                    }
                    else {
                        response.pageNum = page + 1
                    }
                }

                completion(.success(response))
            }
        }
    }
}
