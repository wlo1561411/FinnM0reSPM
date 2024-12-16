import Foundation

public protocol CountablePaged {
    associatedtype Item
    var pageNum: Int { get }
    var isLastPage: Bool { get }
    var items: [Item] { get }
}

public class Pagination<T: AutoCodable & CountablePaged> {
    private let initPage: Int

    private(set) var currentPage = 0
    private(set) var pageSize: Int
    private(set) var isLastPage = false
    private(set) var isLoading = false
    private(set) var latestResponse: T?
    private(set) var allItems: [T.Item] = []

    private var fetching: ((Int, Int, @escaping (Result<T, Error>) -> Void) -> Void)?
    private var onSuccess: ((_ latestResponse: T, _ allItems: [T.Item]) -> Void)?
    private var onError: ((Error) -> Void)?

    public init(
        page: Int = 1,
        pageSize: Int = 20)
    {
        self.pageSize = pageSize
        self.initPage = page
    }

    public func setup(
        fetching: ((Int, Int, @escaping (Result<T, Error>) -> Void) -> Void)?,
        onSuccess: ((_ latestResponse: T, _ allItems: [T.Item]) -> Void)?,
        onError: ((Error) -> Void)?)
    {
        self.fetching = fetching
        self.onSuccess = onSuccess
        self.onError = onError
    }

    public func reload() {
        guard !isLoading
        else {
            print("\(self) 正在請求")
            return
        }

        latestResponse = nil
        allItems.removeAll()

        currentPage = initPage

        loadPage(page: currentPage)
    }

    public func next() {
        guard !isLoading
        else {
            print("\(self) 正在請求")
            return
        }

        guard !isLastPage
        else {
            print("\(self) 已經是最後一頁了 page: \(currentPage)")
            return
        }

        let page: Int

        if currentPage == 0 {
            page = initPage
        }
        else {
            page = currentPage + 1
        }

        loadPage(page: page)
    }

    private func loadPage(page: Int) {
        isLoading = true

        fetching?(page, pageSize) { [weak self] result in
            guard let self else { return }

            isLoading = false

            switch result {
            case .success(let response):
                self.latestResponse = response
                currentPage = response.pageNum
                isLastPage = response.isLastPage
                allItems += response.items
                onSuccess?(response, allItems)

            case .failure(let error):
                onError?(error)
            }
        }
    }
}
